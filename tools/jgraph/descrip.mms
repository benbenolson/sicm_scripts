# VMS MMS makefile
#
# In the link you will get a warning because of the multiple definition
# of exit(). This may be ignored; in order to get MMS completing without
# trouble you will have to call MMS as follows:
#	$ MMS/IGNORE
#
.ifdef DEBUG
CFLAGS=/INCLUDE=(SYS$DISK:[],SYS$SHARE:)/noopt/debug
LFLAGS=/debug
.else
CFLAGS=/INCLUDE=(SYS$DISK:[],SYS$SHARE:)
LFLAGS=
.endif

OBJS = draw.obj, \
		edit.obj, \
		jgraph.obj, \
		list.obj, \
		printline.obj, \
		prio_list.obj, \
		process.obj, \
		show.obj, \
		token.obj, \
		exit.obj

all :	jgraph.exe
	! done

# Do not link against the shareable image VAXCRTL.EXE, or you will
# miss the reference to the local exit() routine.
# EXIT will be reported as being multiply defined - ignore that.
jgraph.exe : $(OBJS)
	link $(LFLAGS) /exe=jgraph $(OBJS),sys$library:vaxcrtl/libr

###
draw.obj :	draw.c jgraph.h list.h prio_list.h
edit.obj :	edit.c jgraph.h list.h prio_list.h
jgraph.obj :	jgraph.c jgraph.h list.h prio_list.h
list.obj :	list.c list.h
printline.obj :	printline.c jgraph.h list.h prio_list.h
prio_list.obj :	prio_list.c list.h prio_list.h
process.obj :	process.c jgraph.h list.h prio_list.h
show.obj :	show.c jgraph.h list.h prio_list.h
token.obj :	token.c list.h
exit.obj :	exit.c
