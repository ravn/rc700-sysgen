# rc700-gensmedet

"Gensmedet" (Danish for "Reforged") is a project to recreate full sources
for the Danish RC700 CP/M system from Regnecentralen .  (https://datamuseum.dk/wiki/RC700_Piccolo)

Work in progress!  


---

2026-03-21:  AUTOLOAD and BIOS now in pure C with inline assembly and boots in MAME.  Initial support for working in CLion (non-commercial version).

All reasonable optimizations and clarifications are now done!

There is a bug when running ID-COMAL but CP/M boots fine on Maxi systems. (Minis have less space on the floppies so waiting with those).  

2026-03-22:  Sources now compile with both experimental z88dk clang backend, and zsdcc.  Binary identical size with zsdcc. Switched to port_in/port_out to get clean C sources.  

----

## Old text


Recreating byte exact source for RC702 adapted SYSGEN.COM

For backward compatibility the RC702 system had multiple densities on the 8" floppy 
disks.   This in turn required the SYSGEN utility to be modified to handle this. 

Michael Ringgård mentions on http://www.jbox.dk/rc702/cpm.shtm that this was 
one of the sources he did not find when working on his RC702 emulator.

At init time I checked in SYSGEN.ASM from http://www.cpm.z80.de/source.html
http://www.cpm.z80.de/download/cpm2-plm.zip as SYSGEN.ORG, and used
IDA37FW to investigate 
SYSGEN.COM to get a rough disassembly of the code.

Use

    MAC SYSGEN
    LOAD SYSGEN

under e.g. RunCMD to create a new SYSGEN.COM.  See http://www.cpm.z80.de/manuals/mac.pdf for documentation.

If zmac is available on the host system, use

    zmac -z --dri SYSGEN.ASM

to create zout/SYSGEN.cim which is binary identical to SYSGEN.COM generated above.  See http://48k.ca/zmac.html for details.

**Note**: Use `-z` flag for Z80 assembly (not `-8` which is for 8080 mode).


Use 

    grep -q '04EF SIGNON' SYSGEN.SYM && dhex RCSYSGEN.COM SYSGEN.COM

to view the binary differences.  The grep ensures that the byte alignment is correct.

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

## Providing PDF content to Claude Code

Claude Code can read PDF files directly with the Read tool (max 20 pages per
request). For PDFs that fail to parse (scanned images, DRM, unusual encoding):

1. **Copy-paste the relevant section** into the chat message prefixed with
   `pdf says:` or similar context.
2. **Use a PDF-to-text tool** first, then paste: `pdftotext file.pdf - | pbcopy`
3. **Screenshot a page** and provide the image path — Claude Code can read images.
4. **For large reference docs**, extract only the relevant pages:
   `pdftk input.pdf cat 42-45 output extract.pdf`

