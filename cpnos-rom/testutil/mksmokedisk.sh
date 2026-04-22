#!/bin/sh
# Stage the cpnet-smoke test disk.
#
# MP/M's CP/NET server (z80pack mpm-net2) exposes its drive A: only,
# regardless of which slave drive letter the request carries.  So we
# can't put the test source on a separate disk — it must live on
# MP/M's A: drive alongside M80.COM/L80.COM/LOAD.COM.
#
# This script takes mpm-net2-1.dsk as a template, injects sumtest.asm
# into it, and writes the result as cpnetsmk-1.dsk in the library.
# The mpm-net2 launcher stages cpnetsmk-1.dsk as drivea.dsk when it
# exists, falling back to the stock mpm-net2-1.dsk otherwise.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
PARENT=$(cd "$HERE/../.." && pwd)
LIB="$PARENT/z80pack/cpmsim/disks/library"
SRC_DISK="$LIB/mpm-net2-1.dsk"
OUT_DISK="$LIB/cpnetsmk-1.dsk"

if [ ! -f "$HERE/sumtest.asm" ]; then
    echo "regenerating sumtest.asm" >&2
    python3 "$HERE/mksmokeasm.py"
fi

cp "$SRC_DISK" "$OUT_DISK"

# mpm-net2-1 is ~2 KB free out of 241 KB; sumtest.asm for N=1000 is
# ~42 KB, so we delete MP/M-native .PRL tools the slave can't run
# anyway (PRL is Page-Relocatable, MP/M-only).  .SUB and .PRL are
# both safe to drop — the slave never executes them.  Also clear
# out MAIL/SCHED/SPOOL support which is MP/M-only.
for name in \
    ABORT.PRL ASM.PRL CONSOLE.PRL DIR.PRL DSKRESET.PRL DUMP.PRL \
    ED.PRL ERA.PRL ERAQ.PRL MPMSTAT.PRL PIP.PRL PRINTER.PRL \
    PRLCOM.PRL RDT.PRL REN.PRL SCHED.PRL SDIR.PRL SET.PRL \
    SETTOD.PRL SHOW.PRL SPOOL.PRL STAT.PRL STOPSPLR.PRL \
    SUBMIT.PRL TOD.PRL TYPE.PRL USER.PRL \
    $$$.SUB MAIL.COM
do
    cpmrm -f ibm-3740 "$OUT_DISK" "0:$name" 2>/dev/null || true
done

cpmrm -f ibm-3740 "$OUT_DISK" 0:SUMTEST.ASM 2>/dev/null || true
cpmcp -f ibm-3740 "$OUT_DISK" "$HERE/sumtest.asm" 0:SUMTEST.ASM

# Replace the stock CPNOS.IMG (z80pack generic slave) with our RC702-
# retargeted cpnos.com.  Without this, netboot fetches z80pack's image
# that drives ports the RC702 doesn't have.  Rebuild cpnos-build first
# if not already current.
CPNOS_COM="$PARENT/cpnos-rom/cpnos-build/d/cpnos.com"
if [ ! -f "$CPNOS_COM" ]; then
    echo "error: $CPNOS_COM not found — run 'make -C cpnos-rom/cpnos-build' first" >&2
    exit 1
fi
cpmrm -f ibm-3740 "$OUT_DISK" 0:CPNOS.IMG 2>/dev/null || true
cpmcp -f ibm-3740 "$OUT_DISK" "$CPNOS_COM" 0:CPNOS.IMG

echo "wrote $OUT_DISK"
echo "cpnetsmk-1.dsk free space + contents:"
cpmls -f ibm-3740 -D "$OUT_DISK" | tail -3
