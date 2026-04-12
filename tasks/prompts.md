
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
