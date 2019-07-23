/* printline.c
 * James S. Plank
 
Jgraph - A program for plotting graphs in postscript.

 * $Source: /Users/plank/src/jgraph/RCS/printline.c,v $
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

#include "jgraph.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void gsave();
void grestore();
void setfont();
void setfill();
void setgray();
void printline();
void print_ebar();
void start_line();
void cont_line();
void end_line();
void bezier_control();
void bezier_end();
void start_poly();
void cont_poly();
void end_poly();
void printellipse();
void set_comment();
void comment();
void printline_c();
void print_label();
void setlinewidth();
void setlinestyle();


#define LINEWIDTHFACTOR 0.700
#define MAX(a, b) ((a > b) ? (a) : (b))

typedef struct fontlist {
  struct fontlist *flink;
  struct fontlist *blink;
  int level;
  float s;
  char *f;
} *Fontlist;

static Fontlist Jgraph_fonts;
static int Jgraph_gsave_level = -100;
static int Jgraph_comment;

void gsave()
{
  if (Jgraph_gsave_level == -100) {
    Jgraph_gsave_level = 0;
    Jgraph_fonts = (Fontlist) make_list(sizeof(struct fontlist));
  } 
  Jgraph_gsave_level++;
  printf(" gsave ");
}

void grestore()
{
  Fontlist l;

  if (last(Jgraph_fonts) != nil(Jgraph_fonts)) {
    l = last(Jgraph_fonts);
    if (l->level == Jgraph_gsave_level) {
      delete_item((List) l);
      free_node((List) l, (List) Jgraph_fonts);
    }
  }
  Jgraph_gsave_level--;
  printf(" grestore ");
}

void setfont(f, s)
char *f;
float s;
{
  Fontlist l;
  int ins;

  if (last(Jgraph_fonts) != nil(Jgraph_fonts)) {
    l = last(Jgraph_fonts);
    ins = (strcmp(l->f, f) != 0 || s != l->s);
    if (ins) {
      delete_item((List) l);
      free_node((List) l, (List) Jgraph_fonts);
    }
  } else {
    ins = 1;
  }
  if (ins) {
    l = (Fontlist) get_node((List) Jgraph_fonts);
    l->level = Jgraph_gsave_level;
    l->s = s;
    l->f = f;
    insert((List) l, (List) Jgraph_fonts);
    printf("/%s findfont %f scalefont setfont\n", f, s);
  }
}
  
void setfill( x, y, t, f, p, a)
char t, p ;
float x, y;
float f[], a ;
{
/*   fprintf(stderr, "Hello?  %c %f %c %f\n", t, f[0], p, a); */
  if (t == 'g' && f[0] < 0.0) return;
  printf("gsave ");

  if ( t == 'g' )  {
    if( f[0] >= 0.0 ) printf("%f setgray ", f[0] );
  } else if ( t == 'c' )  {
    printf("%f %f %f setrgbcolor ", f[0], f[1], f[2] );
  }

  if (p == 's') {
    printf(" fill");
  } else if (p == '/') {
    printf(" 6.1 10 %f %f %f 1 JSTR", a, x, y);
  } else if (p == 'e') {
    printf(" 6.1 10 %f %f %f 0 JSTR", a, x, y);
  }
  printf(" grestore\n");
}

void setgray( t, f)
char t ;
float f[] ;
{
    if ( t == 'g' )  {
       if( f[0] >= 0.0 ) printf("%f setgray\n", f[0] );
    } else if ( t == 'c' )  {
       printf("%f %f %f setrgbcolor\n", f[0], f[1], f[2] );
    }
}

void printline(x1, y1,x2, y2, orientation)
float x1, y1, x2, y2;
char orientation;
{
  if (orientation == 'x') 
    printf("newpath %f %f moveto %f %f lineto stroke\n", x1, y1, x2, y2);
  else
    printf("newpath %f %f moveto %f %f lineto stroke\n", y1, x1, y2, x2);
  fflush(stdout);
} 

void print_ebar(x1, y1, x2, ms, orientation)
float x1, y1, x2, ms;
char orientation;
{
  printline(x1, y1, x2, y1, orientation);
  printline(x2, y1-ms, x2, y1+ms, orientation);
}

void start_line(x1, y1, c)
float x1, y1;
Curve c;
{
  setlinewidth(c->linethick);
  setlinestyle(c->linetype, c->gen_linetype);
  printf("%f %f moveto ", x1, y1);
}

void cont_line(x1, y1)
float x1, y1;
{
  printf("  %f %f lineto\n", x1, y1);
}

void end_line()
{
  printf("stroke\n");
  setlinewidth(1.0);
  setlinestyle('s', (Flist) 0);
  fflush(stdout);

}

void bezier_control(x1, y1)
float x1, y1;
{
  printf("  %f %f ", x1, y1);
}

void bezier_end(x1, y1)
float x1, y1;
{
  printf("  %f %f curveto\n", x1, y1);
}


void start_poly(x1, y1)
float x1, y1;
{
  printf(" newpath %f %f moveto", x1, y1);
}

void cont_poly(x1, y1)
float x1, y1;
{
  printf("  %f %f lineto\n", x1, y1);
}

void end_poly(x, y, ftype, fill, pattern, parg)
float x, y;
char  ftype, pattern ;
float fill[], parg;
{
  printf("closepath ");
  setfill( x, y, ftype, fill, pattern, parg );
  printf("stroke\n");
  fflush(stdout);
}

/* Ellipse at 0, 0 -- assumes that you've already translated to x, y */

void printellipse(x, y, radius1, radius2, ftype, fill, pattern, parg)
char ftype, pattern;
float x, y, radius1, radius2, fill[], parg;
{
  printf("newpath %f %f JDE\n", radius1, radius2);
  setfill( x, y, ftype, fill, pattern, parg );
  printf("stroke\n");
  fflush(stdout);
}

void set_comment(c)
int c;
{
  Jgraph_comment = c;
}

void comment(s)
char *s;
{
  if (Jgraph_comment) printf("%% %s\n", s);
}

void printline_c(x1, y1, x2, y2, g)
float x1, y1, x2, y2;
Graph g;
{
  printline(ctop(x1, g->x_axis), ctop(y1, g->y_axis),
            ctop(x2, g->x_axis), ctop(y2, g->y_axis), 'x');
}

void print_label(l)
Label l;
{
  int f, i, nlines;
  float fnl;
  char *s;

  if (l->label == CNULL) return;

  nlines = 0;
  for (i = 0; l->label[i] != '\0'; i++) {
    if (l->label[i] == '\n') {
      l->label[i] = '\0';
      nlines++;
    }
  }
  fnl = (float) nlines;

  setfont(l->font, l->fontsize);
  printf("gsave %f %f translate %f rotate\n", l->x, l->y, l->rotate);
  if (l->graytype == 'g') {
    printf("  %f setgray\n", l->gray[0]);
  } else if (l->graytype == 'c') {
    printf("  %f %f %f setrgbcolor\n", l->gray[0], l->gray[1], 
           l->gray[2]);
  }

  if (l->vj == 'b') {
    printf("0 %f translate ", fnl * (l->fontsize + l->linesep) * FCPI / FPPI);
  } else if (l->vj == 'c') {
    if (nlines % 2 == 0) {
      printf("0 %f translate ", 
             (fnl/2.0*(l->fontsize + l->linesep) - l->fontsize/2.0)
              * FCPI / FPPI);
    } else {
      printf("0 %f translate ", 
             ((fnl-1.0)/2.0*(l->fontsize + l->linesep) + l->linesep/2.0)
              * FCPI / FPPI);
    }
  } else {
    printf("0 %f translate ", -l->fontsize * FCPI / FPPI);
  }

  s = l->label;
  for (i = 0; i <= nlines; i++) {
    printf("(%s) dup stringwidth pop ", s);
    if (l->hj == 'c') {
      printf("2 div neg 0 moveto\n");
    } else if (l->hj == 'r') {
      printf("neg 0 moveto\n");
    } else {
      printf("pop 0 0 moveto\n");
    }
    /* I would put string blanking in here if I had the time... */
 
    if (i != nlines) {
      f = strlen(s);
      s[f] = '\n';
      s = &(s[f+1]);
      printf("show 0 %f translate\n", 
              - (l->fontsize + l->linesep) * FCPI / FPPI);
    } else {
      printf("show\n");
    }
  }
  printf("grestore\n");
}

void setlinewidth(size)
float size;
{
  printf("%f setlinewidth ", size * LINEWIDTHFACTOR);
}

void setlinestyle(style, glist)
char style;
Flist glist;
{
  Flist fl;

  switch(style) {
    case '0': printf(" [0 2] setdash\n"); break;
    case 's': printf(" [] 0 setdash\n"); break;
    case '.': printf(" [1 3.200000] 0 setdash\n"); break;
    case '-': printf(" [4.00000] 0 setdash\n"); break;
    case 'l': printf(" [7 2] 0 setdash\n"); break;
    case 'd': printf(" [5 3 1 3] 0 setdash\n"); break;
    case 'D': printf(" [5 3 1 2 1 3] 0 setdash\n"); break;
    case '2': printf(" [5 3 5 3 1 2 1 3] 0 setdash\n"); break;
    case 'g': 
      printf(" [");
      for (fl = first(glist); fl != nil(glist); fl = next(fl))
        printf("%f ", fl->f);
      printf("] 0 setdash\n");
      break;
    default: fprintf(stderr, "Error: Unknown line type: %c\n", style);
             exit(1);
             break;
  }
}

