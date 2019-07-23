/* token.c
 * James S. Plank
 
Jgraph - A program for plotting graphs in postscript.

 * $Source: /Users/plank/src/jgraph/RCS/token.c,v $
 * $Revision: 8.5 $
 * $Date: 2017/11/28 17:33:27 $
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

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#ifdef VMS 
#include <stdlib.h>
#include <redexp.VMS>
#endif

/* I'm not sure why I have to do this. */
extern FILE *popen(const char *x, const char *y);

#include "list.h"

void set_input_file();
void error_header();
void ungettokenchar();
void get_comment();
static void push_iostack();
static void pop_iostack();
static void nexttoken();
void rejecttoken();

#define CNULL ((char *)0)

typedef struct iostack {
  struct iostack *flink;
  struct iostack *blink;
  char *filename;
  FILE *stream;
  int oldcharvalid;
  char oldchar;
  char pipe;
  int line;
} *Iostack;

static char INPUT[1000];
static int getnew = 1;
static char oldchar = '\0';
static oldcharvalid = 0;
static char pipe = 0;
static int eof = 0;
static int init = 0;
static Iostack stack;
static char real_eof = EOF;

static FILE *IOSTREAM;
static char FILENAME[300];
static int line = 1;

#ifdef VMS
/* On VMS, there are no popen() and pclose(), so we provide dummies here. */
FILE *popen(command, type)
char *command, *type;
{
    return(NULL);
}
int pclose(stream)
FILE *stream;
{
    return(-1);
}
#endif /*VMS*/

void set_input_file(char *s)
{
  FILE *f;
  Iostack n;

  if (init == 0) {
    stack = (Iostack) make_list(sizeof(struct iostack));
    if (s == CNULL) {
      IOSTREAM = stdin;
      strcpy(FILENAME, "<stdin>");
    } else {
      IOSTREAM = fopen(s, "r");
      if (IOSTREAM == NULL) {
        fprintf(stderr, "Error: cannot open file \"%s\"\n", s);
        exit(1);
      }
      strcpy(FILENAME, s);
    }
    init = 1;
  } else {
    n = (Iostack) get_node((List) stack);
    n->stream = NULL;
    n->filename = (char *) malloc (sizeof(char)*(strlen(s)+2));
    strcpy(n->filename, s);
    n->oldchar = oldchar;
    n->oldcharvalid = oldcharvalid;
    n->pipe = pipe;
    n->line = line;
    insert((List) n, (List) stack->flink);
  }
}

void error_header()
{
  fprintf(stderr, "%s,%d: ", FILENAME, line);
}
  
int gettokenchar()
{
  if (oldcharvalid == 0) oldchar = getc(IOSTREAM);
  oldcharvalid = 0;
  if (oldchar == '\n') line++;
  return oldchar;
}

void ungettokenchar()
{
  oldcharvalid = 1;
  if (oldchar == '\n') line--;
}

int gettoken(s)
char *s;
{
  int i;
  char c;

  for (c = gettokenchar(); 
       c == ' ' || c == '\t' || c == '\n';
       c = gettokenchar()) ;
  for (i = 0;
       c != real_eof && c != ' ' && c != '\t' && c != '\n';
       c = gettokenchar()) {
    s[i++] = c;
  }
  s[i] = '\0';
  ungettokenchar();
  return i;
}

void get_comment()
{
  if (eof) return;
  while (1) {
    if (gettoken(INPUT) == 0) return;
    else if (strcmp(INPUT, "(*") == 0)
      get_comment();
    else if (strcmp(INPUT, "*)") == 0) 
      return;
  }
}

static int iostackempty()
{
  return (first(stack) == nil(stack));
}

static void push_iostack(p)
int p;
{
  Iostack n;

  n = (Iostack) get_node((List) stack);
  n->stream = IOSTREAM;
  n->filename = (char *) malloc (sizeof(char)*(strlen(FILENAME)+2));
  n->oldchar = oldchar;
  n->oldcharvalid = oldcharvalid;
  n->pipe = pipe;
  n->line = line;
  strcpy(n->filename, FILENAME);
  insert((List) n, (List) stack);
  if (p) {
    IOSTREAM = popen(INPUT, "r");
  } else {
    IOSTREAM = fopen(INPUT, "r");
  }
  pipe = p;
  line = 1;
  if (IOSTREAM == NULL) {
    error_header();
    fprintf(stderr, "Include file \"%s\" does not exist\n", INPUT);
    exit(1);
  }
  strcpy(FILENAME, INPUT);
}

static void pop_iostack()
{
  Iostack n;

  fflush(IOSTREAM);
  if (pipe) {
    if (pclose(IOSTREAM)) {
      /*error_header();
      fprintf(stderr, "\n\nPipe returned a non-zero error code.\n");
      exit(1); */
    }
  } else {
    fclose(IOSTREAM);
  }
  n = last(stack);
  if (n->stream == NULL) {
    n->stream = fopen(n->filename, "r");
    if (n->stream == NULL) {
      fprintf(stderr, "Error: cannot open file \"%s\"\n", n->filename);
      exit(1);
    }
  }
  IOSTREAM = n->stream;
  strcpy(FILENAME, n->filename);
  free(n->filename);
  pipe = n->pipe;
  line = n->line;
  oldchar = n->oldchar;
  oldcharvalid = n->oldcharvalid;
  delete_item((List) n);
  free_node((List) n, (List) stack);
}

static void nexttoken()
{
  if (eof) return;
  if (getnew) {
    while (1) {
      if (gettoken(INPUT) == 0) {
        if (iostackempty()) {
          eof = 1;
          getnew = 0;
          return;
        } else {
          pop_iostack();
        }
      } else if (strcmp(INPUT, "(*") == 0) {
        get_comment();
      } else if (strcmp(INPUT, "include") == 0) {
        if (gettoken(INPUT) == 0) {
          error_header();
          fprintf(stderr, "Empty include statement\n");
          exit(1);
        } else {
          push_iostack(0);
        }
      } else if (strcmp(INPUT, "shell") == 0) {
#ifdef VMS 
        fprintf(stderr, "No shell option on VMS, sorry.\n");
        exit(1);
#endif /*VMS*/	
        if (gettoken(INPUT) == 0 || strcmp(INPUT, ":") != 0) {
          error_header();
          fprintf(stderr, "'shell' must be followed by ':'\n");
          exit(1);
        } 
        if (getsystemstring() == 0) {
          fprintf(stderr, "Empty shell statement\n");
          exit(1);
        }
        push_iostack(1);
      } else {
        getnew = 1;
        return;
      }
    }
  }
  getnew = 1;
  return;
}

int getstring(s)
char *s;
{
  nexttoken();
  if (eof) return 0;
  strcpy(s, INPUT);
  return 1;
}

int getint(i)
int *i;
{
  int j;

  nexttoken();
  if (eof) return 0;
  *i = atoi(INPUT);
  if (*i == 0) {
    for (j = 0; INPUT[j] != '\0'; j++)
      if (INPUT[j] != '0') return 0;
  }
  return 1;
}

int getfloat(f)
float *f;
{
  int j;

  nexttoken();
  if (eof) return 0;
  *f = (float) atof(INPUT);
  if (*f == 0.0) {
    for (j = 0; INPUT[j] == '-'; j++);
    while (INPUT[j] == '0') j++;
    if (INPUT[j] == '.') j++;
    while (INPUT[j] == '0') j++;
    if (INPUT[j] == 'e' || INPUT[j] == 'E') {
      j++;
      if (INPUT[j] == '+' || INPUT[j] == '-') j++;
      while (INPUT[j] == '0') j++;
    }
    return (INPUT[j] == '\0');
  } else return 1;
}

static char *new_printable_text(s)
char *s;
{
  char *new_s;
  int to_pad, i, j;

  to_pad = 0;
  for (i = 0; s[i] != '\0'; i++) {
    if (s[i] == '\\' || s[i] == ')' || s[i] == '(') {
       to_pad++;
    }
  }

  j = sizeof(char) * (i + to_pad + 2);
  if ((j % 8) != 0) j += 8 - j % 8;
  new_s = (char *) malloc (j);
  j = 0;
  for (i = 0; s[i] != '\0'; i++) {
    if (s[i] == '\\' || s[i] == ')' || s[i] == '(') {
      new_s[j++] = '\\';
    }
    new_s[j++] = s[i];
  }
  new_s[j] = '\0';		/* added: tie off -hdd */
  return new_s;
}

char *getmultiline()
{
  char c;
  int i, j, done, len, started;
  char *out_str;

  if (getnew == 0) return CNULL;
  
  c = gettokenchar();
  if (c == real_eof) {
    ungettokenchar();
    return CNULL;
  }
  done = 0;
  started = 0;
  while (!done) {
    i = 0;
    for (c = gettokenchar(); c != real_eof && c != '\n';  c = gettokenchar()) {
      INPUT[i++] = c;
    }
    INPUT[i] = '\0';
    if (!started) {
      out_str = (char *) malloc (sizeof(char)*(i+1));
      strcpy(out_str, INPUT);
      len = i;
      started = 1;
    } else {
      out_str = (char *) realloc(out_str, (len + i + 3) * sizeof(char));
      sprintf(&(out_str[len]), "\n%s", INPUT);
      len += i+1;
    }
    if (c == '\n' && len != 0 && out_str[len-1] == '\\') {
      len--;
    } else {
      done = 1;
    }
  }
  ungettokenchar();
  return out_str;
}

char *getlabel()
{
  char c;
  char *txt, *new;
  int i;

  txt = getmultiline();
  if (txt == CNULL) return CNULL;
  new = new_printable_text(txt);
  free(txt);
  return new;
}

int getsystemstring()
{
  char c;
  int i;
  int done;

  if (getnew == 0) return 0;
  
  c = gettokenchar();
  if (c == real_eof) {
    ungettokenchar();
    return 0;
  }
  i = 0;
  done = 0;
  while (!done) {
    for (c = gettokenchar(); c != real_eof && c != '\n';  c = gettokenchar()) {
      INPUT[i++] = c;
    }
    if (c == '\n' && i > 0 && INPUT[i-1] == '\\') {
      INPUT[i++] = '\n';
    } else {
      done = 1;
    }
  }
  ungettokenchar();
  INPUT[i] = '\0';
  return 1;
}

void rejecttoken()
{
  getnew = 0;
}
