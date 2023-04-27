# rc700-sysgen
Recreating byte exact source for RC702 adapted SYSGEN.COM

For backward compatibility the RC702 system had multiple formats on the 8" floppy 
disks.   This in turn required the SYSGEN utility to be modified to handle this. 

Michael Ringgård mentions on http://www.jbox.dk/rc702/cpm.shtm that this was 
one of the sources he did not find when working on his RC702 emulator.

At init time I checked in SYSGEN.ASM from http://www.cpm.z80.de/source.html
http://www.cpm.z80.de/download/cpm2-plm.zip, and used IDA37FW to investigate 
SYSGEN.COM to get a rough disassembly of the code.



/ravn 2023-04-28

