/*
**++
**  FUNCTIONAL DESCRIPTION:
**
**      Exit is a VMS replacement for the standard Unix exit function
**
**  FORMAL PARAMETERS:
**
**      error_code	integer passed by value (optional)
**
**  SIDE EFFECTS:
**
**      Exit will never return to calling program
**	VMS exit status ($STATUS) will be set
**--
**/
#include <varargs.h>

exit(va_alist)
va_dcl
{
	int		nargs;
	va_list		va;
	int		exit_code = 0;
	/*
	 * Pick up the argument, if present
	 */
	va_count(nargs);
	va_start(va);
	if (nargs > 0) exit_code = va_arg(va,int);
	/*
	 * Set the VMS $STATUS to the appropriate value:
	 *	if exit_code == 0 then $STATUS := success
	 *	if exit_code >  0 then $STATUS := error
	 *	if exit_code <  0 then $STATUS := severe_error
	 * and perform exit.
	 *
	 * Note:
	 *	the %X10000000 added to the actual success/error indicator
	 *	will prevent DCL from printing a message.
	 *	A 'on error' will be obeyed however.
	 */
	if (exit_code == 0)		/* success	*/
		sys$exit(0x10000001);
	else if (exit_code > 0)		/* error	*/
		sys$exit(0x10000002);
	else				/* severe error	*/
		sys$exit(0x10000004);
}
