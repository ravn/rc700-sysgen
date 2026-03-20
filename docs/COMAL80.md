# COMAL80 on RC702 — Findings

## Test disk
`~/Downloads/CPM_med_COMAL80.imd` — CP/M rel.2.1 + COMAL80.COM (5.25" mini, 1-based sectors)

## Launching COMAL80
At the CP/M prompt type `COMAL80` (runs `COMAL80.COM`).

Title line on startup:
```
RcComal80   - testversion C -        1/$SAVE
```
The label "testversion C" is part of the version string in this particular binary.

## Hello World session (confirmed working)

```
A>COMAL80

RcComal80   - testversion C -        1/$SAVE
NEW
10 PRINT "HELLO WORLD"
20 END
RUN
HELLO WORLD
END.
AT 0020
BYE
A>
```

## Key commands

| Command                     | Description                                |
|-----------------------------|--------------------------------------------|
| `NEW`                       | Clear program from memory                  |
| `10 PRINT "HELLO WORLD"`    | Enter line 10 (line numbers required)      |
| `RUN`                       | Execute program                            |
| `LIST`                      | Display program (with auto-indentation)    |
| `SAVE "name"`               | Save program to disk                       |
| `LOAD "name"`               | Load program from disk                     |
| `LOOKUP`                    | Directory listing (like CP/M DIR)          |
| `BYE`                       | Exit COMAL80 and return to CP/M            |

## COMAL80 output format after RUN
After `RUN`, COMAL80 prints program output followed by:
- `END.` — end-of-program marker (the `.` may be a non-printable char at runtime)
- `AT nnnn` — line number where execution ended (`AT 0020` = line 20 END)

## Program syntax
Line numbers are required. COMAL-80 is structured (unlike BASIC):

```comal
10 PRINT "HELLO WORLD"
20 END
```

Structured constructs use block-end keywords:
```comal
FOR I := 1 TO 10 DO
  PRINT I
ENDFOR
```

## COMAL80 disk files on CPM_med_COMAL80.imd
```
A: BACKUP   COM : CAT      COM : FORMAT   COM : VERIFY   COM
A: PIP      COM : SELECT   COM : STAT     COM : SYSGEN   COM
A: TRANSFER COM : CONFI    COM : AUTOEXEC COM : RC8000
A: GENERR2      : SYSTEXT  C80 : C80MODE  COM : GENERR
A: DDT      COM : CONVTAB  C80 : COMAL80  COM : TEST
A: COMAL80S COM : KL           : FILEX    COM : COMAL-80 1
A: PRINT    CML
```
Note: `COMAL80S COM` may be a COMAL80 system/support file; `SYSTEXT C80`,
`CONVTAB C80` are COMAL80 support files; `PRINT CML` may be a saved COMAL
program.  `COMAL-80 1` may be a README or manual file.

## Test automation
The COMAL80 hello world test was verified using the rc700-vt100 emulator's
built-in test automation (rc700.c `test_phases[]`). The test:
1. Waits for CP/M boot (PC >= 0xC000)
2. Injects `COMAL80\r` via PIO Port A (the keyboard interface)
3. Waits 8s for COMAL80 to load from disk (400 frames at 50 Hz)
4. Injects program lines and `RUN`
5. Dumps screen to stderr before `BYE` (AFTER RUN) and after exit (FINAL)
