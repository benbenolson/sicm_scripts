/* list.c
 * James S. Plank
 
Jgraph - A program for plotting graphs in postscript.

 * $Source: /Users/plank/src/jgraph/RCS/list.c,v $
 * $Revision: 8.4 $
 * $Date: 2012/10/15 15:54:18 $
 * $Author: plank $

James S. Plank
Department of Electrical Engineering and Computer Science
University of Tennessee
Knoxville, TN 37996
plank@cs.utk.edu

Copyright (c) 2011, James S. Plank
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

 - Neither the name of the University of Tennessee nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*/

#include <stdio.h>    /* Basic includes and definitions */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"

#define boolean int
#define TRUE 1
#define FALSE 0


/*---------------------------------------------------------------------*
 * PROCEDURES FOR MANIPULATING DOUBLY LINKED LISTS 
 * Each list contains a sentinal node, so that     
 * the first item in list l is l->flink.  If l is  
 * empty, then l->flink = l->blink = l.            
 * The sentinal contains extra information so that these operations
 * can work on lists of any size and type.
 * Memory management is done explicitly to avoid the slowness of
 * malloc and free.  The node size and the free list are contained
 * in the sentinal node.
 *---------------------------------------------------------------------*/

typedef struct int_list {  /* Information held in the sentinal node */
  struct int_list *flink;
  struct int_list *blink;
  int size;
  List free_list;
} *Int_list;

void insert(List item, List list)	/* Inserts to the end of a list */
{
  List last_node;

  last_node = list->blink;

  list->blink = item;
  last_node->flink = item;
  item->blink = last_node;
  item->flink = list;
}

void delete_item(List item)		/* Deletes an arbitrary iterm */
{
  item->flink->blink = item->blink;
  item->blink->flink = item->flink;
}

List make_list(int size)
{
  Int_list l;

  l = (Int_list) malloc(sizeof(struct int_list));
  l->flink = l;
  l->blink = l;
  l->size = size;
  l->free_list = (List) malloc (sizeof(struct list));
  l->free_list->flink = l->free_list;
  return (List) l;
}
  
List get_node(List list)   /* Allocates a node to be inserted into the list */
{
  Int_list l;
  List to_return;

  l = (Int_list) list;
  if (l->free_list->flink == l->free_list) {
    return (List) malloc(l->size);
  } else {
    to_return = l->free_list;
    l->free_list = to_return->flink;
    return to_return;
  }
}

void free_node(List node, List list)    /* Deallocates a node from the list */
{
  Int_list l;
  
  l = (Int_list) list;
  node->flink = l->free_list;
  l->free_list = node;
}
