# zmac for this project

zmac is used to assemble the DRI CP/M 2.2 sources in `../cpm/`
(OS2CCP.ASM, OS3BDOS.ASM) into byte-exact CCP+BDOS binaries.

## Build procedure (after fresh checkout or zmac.zip update)

```
cd zmac
unzip -o download/zmac.zip -d download/
cd download/src
patch -p2 < ../../zmac_dri_fixes.patch   # apply DRI-compat fixes (below)
make
cp zmac ../../bin/zmac
```

The rebuilt `bin/zmac` is used by the CCP/BDOS build targets.

## Why the patch is needed

Stock zmac 18oct2022 with `--dri` mode has two bugs that cause
silent byte drift when assembling DRI CP/M 2.2 sources:

### 1. `!` inside a comment

DRI MAC treats `!` as always terminating a comment and starting
a new statement. zmac was treating `!` after `;` as comment
content, silently dropping statements like

    nosub:  ;no submit file! call del$sub

on line 229 of OS2CCP.ASM.  The dropped `call del$sub` accumulated
byte-count drift across the rest of the file.

### 2. Column-0 after a `!` split

When `!` splits a line into two statements, the continuation can
end up at column 0 if the source has no whitespace after the `!`
(e.g. `cmp b!inx h`).  zmac then parses `inx` as a label rather
than a mnemonic and errors out.

OS3BDOS.ASM line 1688 triggers this:

    lda blkmsk! mov b,a! ana l! cmp b!inx h

The patch prepends a space to continuation lines in `--dri` mode
so the column-0 problem never arises.

## Result after patching

- OS2CCP.ASM assembles to a CCP byte-identical to SW1711-I8.imd
  except for the 6-byte `serial:` field at 0xC728.
- OS3BDOS.ASM (with `patch1 equ on`) assembles to a BDOS
  byte-identical to SW1711-I8.imd except for the 6-byte serial
  stamp at 0xCC00.

## Upstream

These fixes are specific to `--dri` mode (gated on `driopt`) and
don't affect non-DRI assembly.  Worth submitting upstream to
zmac if the maintainer is receptive.
