# Before installing, you should change the string "JGRAPH_DIR" in 
# jgraph.1 to be the directory containing the example jgraphs.

CC = gcc -ansi -pedantic

OBJS = draw.o \
		edit.o \
		jgraph.o \
		list.o \
		printline.o \
		prio_list.o \
		process.o \
		show.o \
		token.o

EXAMPLES = \
	acc.jps		\
	acc.eps		\
	alb.jps		\
	ad.jps		\
	bailey.jps	\
	ebars.jps	\
	ex1.jps		\
	ex2.jps		\
	g8.jps		\
	g8col.jps	\
	g9n10.jps	\
	gpaper.jps	\
	hypercube.jps	\
	mab2.jps	\
	nr.jps	\
	sin.jps		\
	sin1.jps	\
	sin2.jps	\
	sin3.jps	\
	tree1.jps	\
	tree2.jps	\
	wortman.jps


all: jgraph

examples: $(EXAMPLES)

.SUFFIXES: .c .o .h .jgr .jps .eps .tex .dvi

.jgr.jps:
	jgraph -P < $*.jgr > $*.jps

.jgr.eps:
	jgraph < $*.jgr > $*.eps

.tex.dvi:
	latex $*.tex
.c.o: 
	$(CC)  -c -g $*.c


jgraph: $(OBJS)
	$(CC) -g $(OBJS) -lm -o jgraph

sin:	sin.o
	cc -o sin sin.o -lm

ad.jps: cube.eps disk.eps
bailey.jps: bailey.pts
ex2.jps: data.txt
mab2.jps: mab2.times
sin.jps: sin
sin2.jps: sin2.pts
sin3.jps: sin3.pts
tree1.jps: tree.awk
	( echo "4 3" | nawk -f tree.awk ; echo "xaxis size 5.4" ) | \
           jgraph -P > tree1.jps
tree2.jps: tree.awk
	( echo "5 2" | nawk -f tree.awk ; echo "xaxis size 5.4" ) | \
           jgraph -P > tree2.jps


###
draw.o: draw.c jgraph.h list.h prio_list.h
edit.o: edit.c jgraph.h list.h prio_list.h
jgraph.o: jgraph.c jgraph.h list.h prio_list.h 
list.o: list.c list.h
printline.o: printline.c jgraph.h list.h prio_list.h 
prio_list.o: prio_list.c list.h prio_list.h
process.o: process.c jgraph.h list.h prio_list.h 
show.o: show.c jgraph.h list.h prio_list.h 
token.o: token.c list.h
clean: 
	rm -f *.o a.out *.jps
