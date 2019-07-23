$!  JGRAPH.COM: Execute jgraph on VMS.
$   SAVE_VER = 'F$VERIFY( F$TRNLNM( "JGRAPH_VERIFY"))'
$ ! How to use this procedure:
$ ! (1) define a symbol to execute the command file
$ !      $ JGRAPH :== @dev:[directory]JGRAPH.COM
$ !	 We will assume that both this jgraph.com and jgraph.exe reside
$ !	 in dev:[directory].
$ ! (2) Then, to run the program with say the HYPERCUBE.JGR file,
$ !      $ JGRAPH HYPERCUBE      ! (Yes you can leave off the .JGR extension)
$ !     To generate a stand-alone PostScript file that can be sent directly
$ !	to the printer, use:
$ !      $ JGRAPH HYPERCUBE "-P"
$ !	or simply
$ !      $ JGRAPH HYPERCUBE -P
$ !     If you really want lowercase to reprint input in expanded form:
$ !      $ JGRAPH HYPERCUBE "-p"
$ !	The resulting output file will have a ".jps" extension.
$!
$   ON   ERROR   THEN GOTO EXIT
$   ON CONTROL_Y THEN GOTO EXIT
$!
$L1:
$   P1 = F$SEARCH( F$PARSE( P1, ".JGR"))
$   IF P1 .NES. "" THEN GOTO L2
$   INQUIRE /LOCAL P1 "Input File : "
$   GOTO L1
$L2:
$   JPS_FILE  = F$PARSE( P1,,, "NAME") + ".JPS"
$   THIS_FILE = F$ENVIRONMENT("PROCEDURE")
$   HERE = F$PARSE(THIS_FILE,,,"DEVICE",) + F$PARSE(THIS_FILE,,,"DIRECTORY",)
$   RUN_JGRAPH := $'HERE'JGRAPH
$!
$   TMP = F$VERIFY( 1)
$   RUN_JGRAPH <'p1' >'jps_file' "''P2'"
$   $status = $STATUS
$   TMP = 'F$VERIFY( TMP)
$!
$EXIT:
$   EXIT $status + 0*F$VERIFY( SAVE_VER)
