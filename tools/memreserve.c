/* Memreserve simply uses a number of threads to allocate
 * and reserve memory to a NUMA node for all eternity.
 * Intended to reserve memory on a NUMA node so that it can't
 * be used by another application.
 */

#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <sys/sysinfo.h>
#include <errno.h>

/* This function writes a character into every address from
   arg[0] to arg[1], which are pointers. */
void *fill_pages(void *arg)
{
  char *i, **range;
  range = arg;

  i = (char *) range[0];
  while(i != range[1]) {
    *i = 'a';
    i++;
  }
}

void parallel_memset(char *data, size_t num_pages) {
  pthread_t *threads;
  char *ptr, ***ranges;
  size_t pages_per_thread,
         runoff, first_runoff_page;
  int pagesize, num_threads, i, num_runoff_threads;

  pagesize = getpagesize();
  num_threads = get_nprocs();

  /* Allocate the array of threads and arguments */
  threads = malloc(sizeof(pthread_t) * num_threads);
  ranges = malloc(sizeof(char **) * num_threads);

  runoff = num_pages % num_threads; /* Number of pages that don't fit */
  first_runoff_page = num_pages - runoff;

  /* Determine how many pages should go to each thread */
  pages_per_thread = num_pages / num_threads;

  printf("===== BEGIN PARALLEL_MEMSET =====\n");
  printf("Pages: %zu\n", num_pages);
  printf("Data: %p\n", data);
  printf("Last byte of data: %p\n", data + (num_pages * pagesize));
  printf("Threads: %d\n", num_threads);
  printf("Pages per thread: %zu\n", pages_per_thread);
  printf("Runoff pages: %zu\n", runoff);
  printf("First runoff page: %zu\n", first_runoff_page);

  ptr = data;
  num_runoff_threads = 0;
  for(i = 0; i < num_threads; i++) {
    ranges[i] = malloc(sizeof(char *) * 2);
    ranges[i][0] = ptr;

    if(i >= num_threads - runoff) { /* This thread gets one extra page */
      ptr += ((pages_per_thread + 1) * pagesize);
      num_runoff_threads++;
    } else {
      ptr += (pages_per_thread * pagesize);
    }
    ranges[i][1] = ptr - 1;

    pthread_create(&(threads[i]), NULL, fill_pages, (void *) ranges[i]);
  }

  /* Wait for the threads to finish up, clean up */
  for(i = 0; i < num_threads; i++) {
    pthread_join(threads[i], NULL);
    free(ranges[i]);
  }
  free(ranges);
  free(threads);

  printf("Runoff threads: %d\n", num_runoff_threads);

  printf("===== END PARALLEL_MEMSET =====\n");
}

/* This function returns the number of pages that can't be allocated on a given
   NUMA node, whether it be because they're reserved by the operating system or
   otherwise show up as "free", but NUMA allocations can't be fulfilled from them.
   To do this, it first allocates the amount of free memory on the node. Then,
   using `move_pages` to determine which pages are actually being physically backed
   by that node, it returns the number of pages that were successfully allocated,
   but simply remain on one of the other nodes. */
size_t get_num_reserved_pages(int node) {
  /* Arguments to move_pages */
  void **pages;
  int *nodes;
  int *status;

  /* Arguments to mbind */
  struct bitmask *bitmask;

  /* Locals */
  size_t i, num_pages;
  long long freemem;
  int pagesize;
  char *data, *ptr;
  long ret;

  /* Status counts */
  size_t status_failed;
  size_t status_other;
  size_t status_succeed;
  size_t status_wrongnode;

  pagesize = getpagesize();

  /* Allocate all of the free memory on the node first */
  numa_node_size64(node, &freemem);
  if((freemem % pagesize) != 0) {
    fprintf(stderr, "WARNING: The amount of free memory on the node isn't a multiple of the pagesize. Not sure what to do here, so continuing.\n");
    //exit(1);
  }
  num_pages = freemem / pagesize;
  data = valloc(freemem);
  if(data == NULL) {
    fprintf(stderr, "We failed to allocate the data. Aborting.\n");
    exit(1);
  }

  /* Bind the pages to the specified node, and physically back them */
  bitmask = numa_bitmask_alloc(sizeof(unsigned long));
  bitmask = numa_bitmask_setbit(bitmask, node);
  ret = mbind(data, freemem, MPOL_PREFERRED, (unsigned long *) bitmask->maskp, sizeof(unsigned long), MPOL_MF_MOVE);
  if(ret != 0) {
    fprintf(stderr, "Couldn't mbind: %s\n", strerror(errno));
    exit(1);
  }
  parallel_memset(data, num_pages);

  /* Set up the arguments for move_pages */
  pages = malloc(sizeof(void *) * num_pages);
  ptr = data;
  for(i = 0; i < num_pages; i++) {
    pages[i] = (void *) ptr;
    ptr += pagesize;
  }
  nodes = NULL;
  status = malloc(sizeof(int) * num_pages);
  for(i = 0; i < num_pages; i++) {
    /* Set each to some canary value to make sure they're written */
    status[i] = -42;
  }

  /* Now look to see how many of the pages made it */
  ret = move_pages(0, (unsigned long) num_pages, pages, nodes, status, MPOL_MF_MOVE);
  if(ret != 0) {
    fprintf(stderr, "Couldn't move pages: %s\n", strerror(errno));
    exit(1);
  }
  status_failed = 0;
  status_other = 0;
  status_succeed = 0;
  status_wrongnode = 0;
  for(i = 0; i < num_pages; i++) {
    if(status[i] == -14) {
      status_failed++;
    } else if(status[i] < 0) {
      status_other++;
    } else if(status[i] == node) {
      status_succeed++;
    } else {
      /* Not negative, but not the right NUMA node */
      status_wrongnode++;
    }
  }

  /* Clean up */
  free(data);
  free(pages);
  free(status);

  /* Verbose, but who cares? If `status_failed` or
     `status_other` show anything but zero, evil's afoot. */
  printf("===== BEGIN GET_NUM_RESERVED_PAGES =====\n");
  printf("Succeeded: %zu\n", status_succeed);
  printf("Wrong node: %zu\n", status_wrongnode);
  printf("Failed: %zu\n", status_failed);
  printf("Other failed: %zu\n", status_other);
  printf("===== END GET_NUM_RESERVED_PAGES =====\n");

  return status_wrongnode;
}

int main(int argc, char **argv)
{
  /* Arguments */
  int arg_node;
  size_t arg_num_pages;

  /* Locals */
  long long freemem;
  size_t num_pages_to_allocate, num_reserved_pages, num_free_pages;
  char *data, *freemem_ptr;
  int pagesize;
  struct bitmask *bitmask;
  long ret;

  if(argc != 3) {
    fprintf(stderr, "USAGE: ./memreserve [node] [num_pages]\n");
    fprintf(stderr, "node: the node to reserve memory on\n");
    fprintf(stderr, "num_pages: the number of pages that should be left on the node.\n");
    exit(1);
  }

  /* Read in arguments */
  arg_node = (int) strtol(argv[1], NULL, 0);
  arg_num_pages = (size_t) strtoumax(argv[2], NULL, 0);

  pagesize = getpagesize();
  num_reserved_pages = get_num_reserved_pages(arg_node);

  /* We need to make sure that, once we're finished, we can
     allocate exactly `arg_num_pages` pages on the node. */
  numa_node_size64(arg_node, &freemem);
  num_free_pages = freemem / pagesize;
  num_pages_to_allocate = num_free_pages - num_reserved_pages - arg_num_pages;
  data = valloc(num_pages_to_allocate * pagesize);
  printf("Reserving %zu pages (%zu megabytes).\n", num_pages_to_allocate, num_pages_to_allocate * pagesize / 1024 / 1024);
  if(data == NULL) {
    fprintf(stderr, "Failed to allocate memory to reserve. Aborting.\n");
    exit(1);
  }
  bitmask = numa_bitmask_alloc(sizeof(unsigned long));
  bitmask = numa_bitmask_setbit(bitmask, arg_node);
  ret = mbind(data,
              num_pages_to_allocate * pagesize,
              MPOL_PREFERRED,
              (unsigned long *) bitmask->maskp,
              sizeof(unsigned long),
              MPOL_MF_MOVE);
  if(ret != 0) {
    fprintf(stderr, "Couldn't mbind: %s\n", strerror(errno));
    exit(1);
  }
  parallel_memset(data, num_pages_to_allocate);
  numa_node_size64(arg_node, &freemem);
  num_free_pages = freemem / pagesize;
  
  printf("===== BEGIN MEMRESERVE =====\n");
  printf("Requested pages: %zu\n", arg_num_pages);
  printf("Reserved pages: %zu\n", num_reserved_pages);
  printf("Final free pages: %zu\n", num_free_pages);
  printf("Estimated allocatable pages: %zu\n", num_free_pages - num_reserved_pages);
  printf("===== END MEMRESERVE =====\n");
  fflush(stdout);
  
  /* Wait until told to stop */
  pause();
  
  free(data);
  numa_bitmask_free(bitmask);
  return 0;
}
