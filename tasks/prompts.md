
## Session 18 (2026-04-13/15) — Clean room BIOS Q&A + CP/NET roadmap

- Answer FDC driver questions for another Claude instance doing clean room reimplementation
- Do not provide code, only behavioral descriptions
- Questions covered: MSR polling, SEEK vs implied seek, CTC Ch.3 interrupt delivery,
  DMA flip-flop race condition (root cause of intermittent hangs), ISR register saves
  (AF/BC/DE/HL only, not IX/IY), DPB/DPH layout, deblocking parameters, MAME config
- Key finding: DMA byte-pointer flip-flop is global — display ISR clearing it during
  mainline FDC DMA programming corrupts channel 1 address/count.  Fix: DI/EI around
  all DMA programming.
- Analyze SPECIFICATION_FEEDBACK.md — identified errors: CTC Ch.3 doesn't need
  re-arming (auto-reload works), __critical __interrupt(N) is fine with the N parameter,
  ISR doesn't read DMA status register
- Create docs/CLEAN_ROOM_IMPLEMENTATION_GUIDE.md with verified answers and corrections
- Clean room reimplementation on hold
- New plan: CP/NET on SIO-A (data) with console on SIO-B, test against z80pack MP/M
  server via TCP in MAME, then physical hardware, then parallel port, then CP/NOS in PROM
- z80pack already forked at ravn/z80pack with NETWRKIF bug fixes
- Created tasks/cpnet-next-steps.md with phased plan (A through E)

## Session 17 (2026-04-11/12) — SIO-B receive + baud rate experiments

- do sio-b in mame
- you have made this work before for sio-a. Perhaps you can find it in your memory?
- explain "case discriminant"
- please add a test for this bug
- fact: Whenever you identify a bug in the compiler, always add a test
- add an issue to ravn/mame
- enable issues on ravn/mame
- now what?
- 2 (commit)
- now what?
- 1 in my own repo (file llvm-z80 issue)
- now do 2. You've seen something similar on SIO-A and fixed it. You may consider looking back in history to see what you did then.
- you have previously found that a lot of nulls could be sent at start
- now look into faster baudrates
- we cannot do dma transfers as there is no dreq from the sio
- what would synchronous mode imply
- i have full control of the other end of the serial connection. Currently it is a FDTI usb device. Can my current cable work with this?
- automatically investigate problems in session found creating tasks and issues as necessary. summarize your work and findings in the project, and commit

## Session 19 (2026-04-12) — Compiler fix #69 + warmboot memset

- 4 (fix clang switch codegen)
- never ever search my home directory! Why did you do that???
- i dont know, search your memory (where is ninja)
- found it. On page 89 (labelled 85) two 74ls393 are cascaded... (baud clock source)
- please summarize your findings in the project
- new task: why is this section necessary if bss is zeroed at start? (warm boot vars)
- when compiled, A is repeatedly set to zero even if it already is. Why? (redundant XOR A,A)
- yes (add to upstream bug list)
- can you group variables together that needs to be set to zero at warm boot so they can be just memset?
- do this in a branch
- i think all the entries might need to be volatile. what do you think?
- i want the serial port a routines to be suffixed with _a
- i saw "rxtail_a_b" did you catch that?
- test
- there are now three queues... can the code be made more generic and still be compact?
- but if the struct is constant and the index is constant wouldn't it resolve to an absolute address?
- is there a faster way to add an 8 bit value to hl?
- it should be only the "increment pointer" that needs to know the size of the buffer
- todo later: Collect all bugs found and prepare them as issues with thorough tests against upstream llvm-z80
- automatically investigate problems in session found creating tasks and issues as necessary

## Session 22 (2026-04-19) — Adapter procurement + project sync

- what now?
- i've done work on another machine. please update your memory
- USB-COM232-PLUS2 is expected back in stock in three months at farnell. can you locate another reseller?
- or another adapter by a european reseller
- appears amazon.de AYA FT2232H is out of stock
- i can also use a single port adapter - perhaps a different chip?
- what is MPSSE?
- us shipping is very expensive with taxes and vat
- ebay.co.uk listing is ended
- i want eu resellers
- please investigate a suitable MAX3232 module to pair with the Adafruit FT232H
- i have db 9 cables
- yes (record in project)
- please add farnell dk link to project
- put the sdlc work aside, and set the speed at 38400 8n1 for both ports
- analyse, raise issues and tasks, summarize and commit

## Session 21 (2026-04-18) — SDLC decoder follow-up + FT2232H sourcing

- what was the result of the serial speed investigation
- please continue looking at the SDLC-mode
- while we wait for a ft2232h cable, please run a new test
- what is the problem with the current fdti device. Is the usb cable too slow?
- please have a closer look
- what are your findings
- is a FTDI FT232RL usable?
- i need you to help me find a retailer for at ft2232h adapter?
- i need you to help me find a retailer for at ft2232h rs232 adapter usable here?
- looks like digikey send from the us, i'd prefer a european retailer
- please analyze and create tasks and issues as needed, then summarize in project and commit.

## Session 19 continued — SIO role swap + DCD detection

- i want to revert serial port a back to the old behavior of only being rdr: and pun:...
- where is BAT behavior defined?
- this looks good. please implement in a new branch
- does clang support -fverbose-asm?
- file an issue about adding this
- can the .loc lines be postprocessed to include the c source
- does clion support this?
- does the test need extra time to detect?
- i want the baud calculated at compile time, not boot time
- please add that 614400 is generated in hardware by dividing memclock by 32
- rename IOBYTE_DEFAULT to something indicating the mapping, and make 0x95 a constant
- todo later: Make this a switch indicator
- i have not seen the print statement, please rerun mame and let me see
- i want you to change the test when a serial connection is present (future task)
- can llvm-objdump keep the source references and resolve them too?
- rebuild bios.lis
- what is bios.c.lis and what is bios.lis
- so sdcc generates a list file for each input file, and clang for the whole program?
- can sdcc generate the same?
- does the asm file association in clion support hyperlinks?
- are there any editors in clion that support hyperlinks?
- undo the -l but keep a note
- console output is slowed by serial output by default. Can we see at boot time if a remote host is attached...
- does the test need extra time to detect?
- i want an extra line added to the boot banner if so
- the bios is old
