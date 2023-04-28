# rc700-sysgen
Recreating byte exact source for RC702 adapted SYSGEN.COM

For backward compatibility the RC702 system had multiple formats on the 8" floppy 
disks.   This in turn required the SYSGEN utility to be modified to handle this. 

Michael Ringgård mentions on http://www.jbox.dk/rc702/cpm.shtm that this was 
one of the sources he did not find when working on his RC702 emulator.

At init time I checked in SYSGEN.ASM from http://www.cpm.z80.de/source.html
http://www.cpm.z80.de/download/cpm2-plm.zip, and used IDA37FW to investigate 
SYSGEN.COM to get a rough disassembly of the code.

Use

    MAC SYSGEN
    MLOAD SYSGEN

to compile.  See http://www.cpm.z80.de/manuals/mac.pdf for documentation.

Use 

    grep -q '04EF SIGNON' SYSGEN.SYM && dhex RCSYSGEN.COM SYSGEN.COM

to view the binary differences.

Before committing to git, remove CP/M ^Z EOF characters so git will recognize the file as
ascii:

    perl -i -pe 's/\032//g' SYSGEN.SYM




##  MAC error codes

13. ERROR MESSAGES
When errors occur within the assembly language program, they are listed as
single character flags in the leftmost position of the source listing. The line in error
is also echoed at the console so that the source listing need not be examined to
determine if errors are present. The single character error codes are:
* B Balance error: macro doesn't terminate properly, or conditional assembly
operation is ill-formed.
* C Comma error: expression was encountered, but not delimited properly
from the next item by a comma.
* D Data error: element in a data statement (DB or DW) cannot be placed
in the specified data area.
* E Expression error: expression is ill-formed and cannot be computed at
assembly time.
* I Invalid character error: a non graphic character has been found in the
line (not a carriage return, line feed, tab, or end of file); re-edit the file, delete the
line with the I error, and retype the line.
* L Label error: label cannot appear in this context (may be a duplicate
label).
* M Macro overflow error: internal macro expansion table overflow; may be
due to too many nested invocations or infinite recursion.
* N Not implemented error: features which will appear in future MAC versions
(e.g., relocation) are recognized, but flagged in this version.
* O Overflow error: expression is too complicated (i.e., too many pending
operators), string is too long, or too many successive substitutions of a formal parameter
by its actual value in a macro expansion. This error will also occur if the number
of LOCAL labels exceeds 9999.
* P Phase error: label does not have the same value on two subsequent passes
through the program, or the order of macro definition differs between two successive
passes; may be due to MACLIB which follows a mainline macro (if so, move the
MACLIB to the top of the program).
* R Register error: the value specified as a register is not compatible with
the operation code.
* S Syntax error: the fields of this statement are ill-formed and cannot be
processed properly; may be due to invalid characters or delimiters which are out of
place.
* U Undefined Symbol: a label operand in this statement has not been defined
elsewhere in the program.
* V Value error: operand encountered in an expression is improperly formed;
may be due to delimiter out of place or non-numeric operand.

/ravn 2023-04-28

