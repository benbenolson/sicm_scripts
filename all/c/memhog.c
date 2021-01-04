/* Memhog simply uses a number of threads to allocate
 * and reserve memory to a NUMA node for all eternity.
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

int main(int argc, char **argv)
{
  /* Arguments */
  int arg_node;
  size_t arg_num_pages;

  /* Locals */
  long long freemem;
  size_t num_pages_to_allocate, num_free_pages;
  char *data, *freemem_ptr;
  int pagesize;
  struct bitmask *bitmask;
  long ret;

  if(argc != 3) {
    fprintf(stderr, "USAGE: ./memreserve [node] [num_pages]\n");
    fprintf(stderr, "node: the node to reserve memory on\n");
    fprintf(stderr, "num_pages: the number of pages that should be allocated on the node.\n");
    exit(1);
  }

  /* Read in arguments */
  arg_node = (int) strtol(argv[1], NULL, 0);
  arg_num_pages = (size_t) strtoumax(argv[2], NULL, 0);

  pagesize = getpagesize();

  /* We need to make sure that, once we're finished, we can
     allocate exactly `arg_num_pages` pages on the node. */
  numa_node_size64(arg_node, &freemem);
  num_free_pages = freemem / pagesize;
  num_pages_to_allocate = arg_num_pages;
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
  printf("Final free pages: %zu\n", num_free_pages);
  printf("===== END MEMRESERVE =====\n");
  fflush(stdout);
  
  /* Wait until told to stop */
  pause();
  
  free(data);
  numa_bitmask_free(bitmask);
  return 0;
}
