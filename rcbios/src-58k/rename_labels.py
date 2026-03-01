#!/usr/bin/env python3
"""Rename auto-generated z80dasm labels to meaningful names in 58K BIOS sources.

Applies simultaneous word-boundary replacement to avoid rename chain conflicts.
Handles both BIOS_58K.MAC (rel.1.3) and BIOS_58K_14.MAC (rel.1.4).
"""

import re
import sys

# ============================================================
# Label rename mappings for rel.1.3 (BIOS_58K.MAC)
# ============================================================

REL13_RENAMES = {
    # --- Fix wrongly-assigned labels from mkbios_rel13.py ---
    # These were assigned to wrong addresses in the original CODE_LABELS
    'SECTRAN': 'XREAD',     # EEB7: is XREAD code (READOP=1, JP RWOPER)
    'READ':    'XWRITE',    # EEC7: is XWRITE code (READOP=0)
    'WRITE':   'STLIST',    # E3A8: is list status (LD A,(PRTFLG)/RET)
    'LISTST':  'SECTRA',    # EEB4: is sector translate (LD HL,BC/RET)
    'EXIT':    'LINSEL',    # E2C0: is line selector (DTR/RTS via SIO)
    'CLOCK':   'EXIT',      # E29F: is exit routine (store JP+addr+count)
    'INTFN5':  'CLOCK',     # E2AC: is real time clock read/set
    'LINSEL':  'RDSTAT',    # E3EB: is SIO reader status (LD A,(RDRFLG)/RET)
    'READS':   'WFITR',     # F201: is floppy wait+read result

    # --- INIT section ---
    'le0a4h':     'INITIO',    # I/O initialization (PIO, CTC, SIO, DMA, CRT)
    'le12eh':     'INITFDC',   # FDC initialization loop
    'le139h':     'INITLP',    # FDC init byte send loop
    'le13ah':     'INITWT',    # FDC init wait for ready

    # --- Jump table config ---
    'le203h':     'WBOTE',     # Warm boot entry (JP WBOOT)
    'le234h':     'WR5A',      # SIO Write Register 5 Ch.A config
    'le235h':     'WR5B',      # SIO Write Register 5 Ch.B config
    'le237h':     'FD0',       # Floppy disk format array start

    # --- Boot/system ---
    'le289h':     'PRMSG',     # Print message (LD A,(HL)/OR A/RET Z/...)
    'le296h':     'BOTERR',    # Boot error handler
    'le29ch':     'BOPLP',     # Boot error infinite loop
    'le2b8h':     'CLOCK1',    # Clock set branch (inside CLOCK)
    'le2e9h':     'LINSEL_2',  # LINSEL: check CTS result
    'sub_e2f1h':  'SETSIG',    # Set SIO signal (DTR/RTS out)
    'le325h':     'BOOT1',     # Boot: done checking drives
    'le353h':     'RDSEC',     # Read sector loop (warm boot)
    'le39bh':     'GOCPM',     # Go to CP/M (EI, JP CCP)

    # --- SIO variables ---
    'le39fh':     'PRTFLG',    # Printer busy flag (0xFF=ready)
    'le3a0h':     'RDRFLG',    # Reader busy flag
    'le3a1h':     'PTPFLG',    # Punch busy flag
    'le3a2h':     'CHARA',     # SIO Ch.A receive buffer
    'le3a3h':     'CHARB',     # SIO Ch.B receive buffer
    'le3a4h':     'RR0_A',     # SIO Ch.A Read Register 0
    'le3a5h':     'RR1_A',     # SIO Ch.A Read Register 1
    'le3a6h':     'RR0_B',     # SIO Ch.B Read Register 0
    'le3a7h':     'RR1_B',     # SIO Ch.B Read Register 1

    # --- SIO functions ---
    'sub_e3d1h':  'READI',     # Start reader (enable SIO Ch.A receive)
    'le424h':     'TXB',       # SIO Ch.B transmit ISR

    # --- SIO ISR labels (unlabeled in z80dasm, only labeled ones here) ---
    'sub_e44ah':  'SPECB',     # SIO Ch.B special receive ISR
    'sub_e46ah':  'EXTSTA',    # SIO Ch.A external status ISR
    'sub_e487h':  'SPECA',     # SIO Ch.A special receive ISR

    # --- PIO ---
    'le499h':     'KEYFLG',    # Keyboard ready flag
    'le49ah':     'PARFLG',    # Parallel port flag
    'le4b6h':     'KEYIT',     # Keyboard interrupt handler

    # --- Display variables ---
    'le4cah':     'GRAPH',     # Graphics mode flag
    'le4cbh':     'LINTEM',    # Line temp save area (2 bytes)

    # --- Display utility functions ---
    'sub_e4cdh':  'CPLHL',     # Complement HL
    'sub_e4d4h':  'NEGHL',     # Negate HL (complement + increment)
    'sub_e4d9h':  'TSTLROW',   # Test if at last row (row=1920)
    'sub_e4e4h':  'CONV',      # Convert character (check GRAPH mode)
    'sub_e4eah':  'CON1',      # Convert char via table lookup
    'le4efh':     'WP75',      # Cursor position (8275 load cursor)
    'le500h':     'ROWDN',     # Row down (ROW+=80, CURSY++)
    'le511h':     'ROWUP',     # Row up (ROW-=80, CURSY--)
    'sub_e522h':  'ES0H',      # Cursor home (ROW=0, COL=0, CURSY=0)
    'le530h':     'CHKDC',     # A mod B
    'le536h':     'FILL',      # Fill line with spaces
    'le557h':     'SCROLL',    # Scroll screen up one line
    'sub_e584h':  'ADDOFF',    # Background address calculation
    'le588h':     'ADDOF1',    # ADDOFF shift loop
    'le596h':     'ADDOF2',    # ADDOFF rotate loop
    'sub_e59ch':  'CLRBIT',    # Clear background bits
    'le5abh':     'CLRBI1',    # CLRBIT shift-and-mask loop
    'le5b4h':     'MOVUP',     # Move bytes up (LDIR with BC check)
    'le5bah':     'MOVUP1',    # MOVUP: do LDIR
    'le5bdh':     'MOVUP2',    # MOVUP: check if BC=0
    'sub_e5c2h':  'MOVDWN',    # Move bytes down (LDDR with BC check)
    'le5c8h':     'MOVDWN1',   # MOVDWN: do LDDR
    'le5cbh':     'MOVDWN2',   # MOVDWN: check if BC=0

    # --- Display control char handlers ---
    'le6b5h':     'ESCD1',     # Cursor left: wrap to prev line
    'sub_e6d0h':  'ESCC',      # Cursor right
    'le6dfh':     'ESCC1',     # Cursor right: wrap to next line
    'le7d9h':     'ESCCF1',    # Clear foreground: byte loop
    'le7e1h':     'ESCCF2',    # Clear foreground: zero fill loop
    'le7ebh':     'ESCCF3',    # Clear foreground: bit check loop
    'le7f1h':     'ESCCF4',    # Clear foreground: skip bit
    'le7f6h':     'ESCCF5',    # Clear foreground: next byte

    # --- Display character/XY/CONOUT internals ---
    'sub_e853h':  'XYADD',     # XY address processing
    'le865h':     'XYADD1',    # XYADD: second byte received
    'le872h':     'XYADD2',    # XYADD: compute position
    'le88eh':     'XYADD3',    # XYADD: row multiply loop
    'sub_e899h':  'DISPL',     # Display normal character
    'le8b0h':     'DISPL1',    # DISPL: check char < 128
    'le8bfh':     'DISPL2',    # DISPL: convert via table
    'le8c5h':     'DISPL3',    # DISPL: store char to screen
    'le8ebh':     'DISPL4',    # DISPL: set background bit
    'le912h':     'CONOU1',    # CONOUT: not XY, check if control
    'le920h':     'CONOU2',    # CONOUT: normal char branch
    'le923h':     'CONOU3',    # CONOUT: restore and return

    # --- Display ISR (RTC timers) ---
    'le97dh':     'AFB11',     # DSP ISR: exit routine 0 timer
    'le98eh':     'AFB12',     # DSP ISR: exit routine 1 (motor) timer
    'le99fh':     'AFB13',     # DSP ISR: delay counter
    'le9abh':     'AFB14',     # DSP ISR: restore and return

    # --- Disk config data ---
    'lea7bh':     'FDF1',      # Format definition table start
    'lea9ah':     'DPBASE',    # Disk parameter base (DPH area)

    # --- Workspace variables (floppy driver state) ---
    'leabbh':     'DPBLK1',    # DPBLCK+1 (DPB address high byte)
    'leabch':     'CPMRBP',    # CP/M records per block
    'leabdh':     'SPTRK',     # Sectors per track (overflow check)
    'leabeh':     'SECMSK',    # Sector mask
    'leabfh':     'SECSHF',    # Sector shift factor
    'leac0h':     'TRANTB',    # Translate table pointer (2 bytes)
    'leac2h':     'DTLV',      # Data transfer length value
    'leacah':     'SEKDSK',    # Seek disk number
    'leacbh':     'SEKTRK',    # Seek track (2 bytes)
    'leacdh':     'SEKSEC',    # Seek sector
    'leaceh':     'HSTDSK',    # Host disk
    'leacfh':     'HSTTRK',    # Host track (2 bytes)
    'lead1h':     'HSTSEC',    # Host sector
    'lead2h':     'LSTDSK',    # Last disk accessed
    'lead3h':     'LSTTRK',    # Last track accessed
    'lead4h':     'SEKHST',    # Seek host sector
    'lead5h':     'HSTACT',    # Host active flag
    'lead6h':     'HSTWRT',    # Host written flag
    'lead7h':     'UNACNT',    # Unallocated record count
    'lead8h':     'UNADSK',    # Unallocated disk
    'lead9h':     'UNATRK',    # Unallocated track (2 bytes)
    'leadbh':     'UNASEC',    # Unallocated sector
    'leadch':     'UNAMSK',    # Unallocated mask
    'leaddh':     'ERFLAG',    # Error flag
    'leadeh':     'RSFLAG',    # Read/skip flag
    'leadfh':     'READOP',    # Read operation flag
    'leae0h':     'WRTYPE',    # Write type (WRALL/WRDIR/WRUAL)
    'leae1h':     'DMAADR',    # DMA address (2 bytes)
    'leae3h':     'HSTBUF',    # Host buffer start

    # --- FDC parameter block variables ---
    'lee19h':     'DRNO',      # Max drive number (+1=DSKNO, +2=DSKAD)
    'lee1ch':     'DSKADH',    # DMA address high byte (FDC param)
    'lee1dh':     'ACTRA',     # Actual track
    'lee1eh':     'ACSEC',     # Actual sector
    'lee1fh':     'REPET',     # Retry counter
    'lee20h':     'RSTAB',     # Result table byte 0
    'lee21h':     'RSTAB1',    # Result table byte 1
    'lee28h':     'FL_FLG',    # Floppy interrupt flag

    # --- Floppy driver branch labels ---
    'lee4dh':     'SELD20',    # SELDSK: format byte loaded
    'lee64h':     'SELN',      # SELDSK: set current format
    'lee9eh':     'RSELD',     # SELDSK: return (error or done)
    'leeech':     'CHKUNA',    # Check unallocated sectors
    'lef29h':     'NOOVF',     # No sector overflow
    'lef3bh':     'SETMSK',    # Set unallocated mask
    'lef41h':     'ALLOC',     # Allocated sector (need pre-read)
    'lef4bh':     'RWOPER',    # Read/write operation common code
    'lef5ah':     'RSECS',     # Sector shift loop
    'lef63h':     'SETSH',     # Set host sector
    'lef8dh':     'NOMATC',    # No match (different host sector)
    'lef94h':     'FILHST',    # Fill host buffer
    'lefb1h':     'MATCH',     # Host sector matches
    'lefdbh':     'RWMOVE',    # Move data to/from host buffer
    'leffch':     'RRWOP',     # Return from read/write operation

    # --- Floppy driver functions ---
    'sub_efffh':  'TRKCMP',    # Track compare (16-bit)
    'sub_f00bh':  'WRTHST',    # Write host buffer to disk
    'sub_f011h':  'RDHST',     # Read host buffer from disk
    'sub_f021h':  'CHKTRK',    # Check host track, seek if needed
    'sub_f085h':  'RECA',      # Recalibrate and re-seek
    'sub_f101h':  'RFDAT',     # Read FDC data (DMA read command)
    'sub_f106h':  'WFDAT',     # Write FDC data (DMA write command)
    'sub_f10bh':  'GFPA',      # Get floppy params address
    'sub_f116h':  'FDSTAR',    # Start floppy motor
    'sub_f134h':  'FDSTOP',    # Stop floppy motor
    'sub_f13eh':  'WAITD',     # Wait delay (timer-based)
    'sub_f175h':  'FLO4',      # FDC recalibrate
    'sub_f1a4h':  'FLO6',      # FDC sense interrupt status
    'sub_f1c1h':  'FLO7',      # FDC seek
    'sub_f1deh':  'RSULT',     # FDC read result bytes
    'sub_f1fah':  'CLFIT',     # Clear floppy interrupt flag
    'sub_f210h':  'WATIR',     # Wait for floppy interrupt
    'sub_f218h':  'FLPR',      # Start DMA read (FDC→memory)
    'lf21fh':     'FLPR_2',    # FLPR: DMA channel setup (shared by FLPW)
    'sub_f239h':  'FLPW',      # Start DMA write (memory→FDC)
    'sub_f2bch':  'DUMITR',    # Dummy interrupt handler (EI/RETI)

    # --- Floppy driver branch labels (lower-level) ---
    'lf03ch':     'SET1',      # CHKTRK: head 0 branch
    'lf03fh':     'SET2',      # CHKTRK: translate sector
    'lf067h':     'SEEKT',     # CHKTRK: need to seek
    'lf097h':     'SECRD',     # Sector read entry
    'lf09ch':     'RPSC',      # Repeat sector read
    'lf0b4h':     'SECCH',     # Sector check (read result)
    'lf0d7h':     'SCR1',      # Sector read/write error
    'lf0e1h':     'SECWR',     # Sector write entry
    'lf0e6h':     'RPSW',      # Repeat sector write
    'lf01bh':     'RCHECK',    # RDHST: force pre-read check
    'lf141h':     'WAIT10',    # WAITD loop
    'lf161h':     'FLO2',      # Wait FDC ready for write
    'lf16bh':     'FLO3',      # Wait FDC ready for read
    'lf1e3h':     'RSL1',      # RSULT: byte read loop
    'lf1ech':     'RSL2',      # RSULT: delay loop
    'lf243h':     'GNCOM',     # General FDC command
    'lf2a1h':     'FITX',      # FDC ISR: delay loop
    'lf2b2h':     'FIT1',      # FDC ISR: read result branch
    'lf2b5h':     'FIT2',      # FDC ISR: restore and return
    'lf321h':     'IVTPAG',    # IVT page value (byte = 0xF3)
}


def build_rel14_renames():
    """Build rel.1.4 rename mapping from rel.1.3 mapping with address shifts.

    The rel.1.4 ISR handlers use stack-based save instead of EX AF,AF'/EXX,
    growing the code and shifting all subsequent addresses.

    Shift boundaries (rel.1.3 address → cumulative shift):
      E080-E423: +0   (before first ISR)
      E499-E4B5: +88  (after 8 SIO ISRs, before PIO ISRs)
      E4CA-E92B: +110 (after 10 small ISRs, before RTC ISR)
      E9B2-EE28: +115 (after RTC ISR, before SAVESP insertion)
      EE29-F28F: +117 (after SAVESP, before FDC ISR)
      F2BC+:     +122 (after FDC ISR)

    z80dasm auto-label format: l<hex>h or sub_<hex>h
    """
    def auto_label(addr13, is_sub, shift):
        """Generate the rel.1.4 auto-label name for a rel.1.3 address."""
        addr14 = addr13 + shift
        if is_sub:
            return 'sub_%xh' % addr14
        else:
            return 'l%xh' % addr14

    renames = {}

    # Wrong-label fixes (same label names in both files)
    renames.update({
        'SECTRAN': 'XREAD',
        'READ':    'XWRITE',
        'WRITE':   'STLIST',
        'LISTST':  'SECTRA',
        'EXIT':    'LINSEL',
        'CLOCK':   'EXIT',
        'INTFN5':  'CLOCK',
        'LINSEL':  'RDSTAT',
        'READS':   'WFITR',
    })

    # Unchanged region (E080-E423, shift=0) — same auto-label names
    for old, new in REL13_RENAMES.items():
        if old.startswith(('le0', 'le1', 'le2', 'le3', 'sub_e2', 'sub_e3')):
            addr = int(old.replace('sub_', '').replace('le', 'l').strip('lh'), 16)
            if addr < 0xE424:
                renames[old] = new

    # +88 region (E499-E4B5)
    shift88 = [
        (0xE499, False, 'KEYFLG'), (0xE49A, False, 'PARFLG'),
    ]

    # +110 region (E4CA-E92B)
    shift110 = [
        (0xE4CA, False, 'GRAPH'),    (0xE4CB, False, 'LINTEM'),
        (0xE4CD, True,  'CPLHL'),    (0xE4D4, True,  'NEGHL'),
        (0xE4D9, True,  'TSTLROW'),  (0xE4E4, True,  'CONV'),
        (0xE4EA, True,  'CON1'),     (0xE4EF, False, 'WP75'),
        (0xE500, False, 'ROWDN'),    (0xE511, False, 'ROWUP'),
        (0xE522, True,  'ES0H'),     (0xE530, False, 'CHKDC'),
        (0xE536, False, 'FILL'),     (0xE557, False, 'SCROLL'),
        (0xE584, True,  'ADDOFF'),   (0xE588, False, 'ADDOF1'),
        (0xE596, False, 'ADDOF2'),   (0xE59C, True,  'CLRBIT'),
        (0xE5AB, False, 'CLRBI1'),
        (0xE5B4, False, 'MOVUP'),    (0xE5BA, False, 'MOVUP1'),
        (0xE5BD, False, 'MOVUP2'),   (0xE5C2, True,  'MOVDWN'),
        (0xE5C8, False, 'MOVDWN1'),  (0xE5CB, False, 'MOVDWN2'),
        (0xE6B5, False, 'ESCD1'),    (0xE6D0, True,  'ESCC'),
        (0xE6DF, False, 'ESCC1'),
        (0xE7D9, False, 'ESCCF1'),   (0xE7E1, False, 'ESCCF2'),
        (0xE7EB, False, 'ESCCF3'),   (0xE7F1, False, 'ESCCF4'),
        (0xE7F6, False, 'ESCCF5'),
        (0xE853, True,  'XYADD'),    (0xE865, False, 'XYADD1'),
        (0xE872, False, 'XYADD2'),   (0xE88E, False, 'XYADD3'),
        (0xE899, True,  'DISPL'),    (0xE8B0, False, 'DISPL1'),
        (0xE8BF, False, 'DISPL2'),   (0xE8C5, False, 'DISPL3'),
        (0xE8EB, False, 'DISPL4'),
        (0xE912, False, 'CONOU1'),   (0xE920, False, 'CONOU2'),
        (0xE923, False, 'CONOU3'),
    ]

    # +115 region (E9B2-EE28) — after RTC ISR
    shift115 = [
        (0xE97D, False, 'AFB11'),    (0xE98E, False, 'AFB12'),
        (0xE99F, False, 'AFB13'),    (0xE9AB, False, 'AFB14'),
        (0xEA7B, False, 'FDF1'),     (0xEA9A, False, 'DPBASE'),
        (0xEABB, False, 'DPBLK1'),   (0xEABC, False, 'CPMRBP'),
        (0xEABD, False, 'SPTRK'),    (0xEABE, False, 'SECMSK'),
        (0xEABF, False, 'SECSHF'),   (0xEAC0, False, 'TRANTB'),
        (0xEAC2, False, 'DTLV'),     (0xEACA, False, 'SEKDSK'),
        (0xEACB, False, 'SEKTRK'),   (0xEACD, False, 'SEKSEC'),
        (0xEACE, False, 'HSTDSK'),   (0xEACF, False, 'HSTTRK'),
        (0xEAD1, False, 'HSTSEC'),   (0xEAD2, False, 'LSTDSK'),
        (0xEAD3, False, 'LSTTRK'),   (0xEAD4, False, 'SEKHST'),
        (0xEAD5, False, 'HSTACT'),   (0xEAD6, False, 'HSTWRT'),
        (0xEAD7, False, 'UNACNT'),   (0xEAD8, False, 'UNADSK'),
        (0xEAD9, False, 'UNATRK'),   (0xEADB, False, 'UNASEC'),
        (0xEADC, False, 'UNAMSK'),   (0xEADD, False, 'ERFLAG'),
        (0xEADE, False, 'RSFLAG'),   (0xEADF, False, 'READOP'),
        (0xEAE0, False, 'WRTYPE'),   (0xEAE1, False, 'DMAADR'),
        (0xEAE3, False, 'HSTBUF'),
        # FDC param block (same region)
        (0xEE19, False, 'DRNO'),     (0xEE1C, False, 'DSKADH'),
        (0xEE1D, False, 'ACTRA'),    (0xEE1E, False, 'ACSEC'),
        (0xEE1F, False, 'REPET'),    (0xEE20, False, 'RSTAB'),
        (0xEE21, False, 'RSTAB1'),   (0xEE28, False, 'FL_FLG'),
    ]

    # +117 region (EE29-F28F) — after SAVESP
    shift117 = [
        (0xEE4D, False, 'SELD20'),   (0xEE64, False, 'SELN'),
        (0xEE9E, False, 'RSELD'),    (0xEEEC, False, 'CHKUNA'),
        (0xEF29, False, 'NOOVF'),    (0xEF3B, False, 'SETMSK'),
        (0xEF41, False, 'ALLOC'),    (0xEF4B, False, 'RWOPER'),
        (0xEF5A, False, 'RSECS'),    (0xEF63, False, 'SETSH'),
        (0xEF8D, False, 'NOMATC'),   (0xEF94, False, 'FILHST'),
        (0xEFB1, False, 'MATCH'),    (0xEFDB, False, 'RWMOVE'),
        (0xEFFC, False, 'RRWOP'),
        (0xF01B, False, 'RCHECK'),   (0xF03C, False, 'SET1'),
        (0xF03F, False, 'SET2'),     (0xF067, False, 'SEEKT'),
        (0xF097, False, 'SECRD'),    (0xF09C, False, 'RPSC'),
        (0xF0B4, False, 'SECCH'),    (0xF0D7, False, 'SCR1'),
        (0xF0E1, False, 'SECWR'),    (0xF0E6, False, 'RPSW'),
        (0xF141, False, 'WAIT10'),   (0xF161, False, 'FLO2'),
        (0xF16B, False, 'FLO3'),     (0xF1E3, False, 'RSL1'),
        (0xF1EC, False, 'RSL2'),     (0xF243, False, 'GNCOM'),
        # Functions (sub_ prefix)
        (0xEFFF, True,  'TRKCMP'),   (0xF00B, True,  'WRTHST'),
        (0xF011, True,  'RDHST'),    (0xF021, True,  'CHKTRK'),
        (0xF085, True,  'RECA'),     (0xF101, True,  'RFDAT'),
        (0xF106, True,  'WFDAT'),    (0xF10B, True,  'GFPA'),
        (0xF116, True,  'FDSTAR'),   (0xF134, True,  'FDSTOP'),
        (0xF13E, True,  'WAITD'),    (0xF175, True,  'FLO4'),
        (0xF1A4, True,  'FLO6'),     (0xF1C1, True,  'FLO7'),
        (0xF1DE, True,  'RSULT'),    (0xF1FA, True,  'CLFIT'),
        (0xF210, True,  'WATIR'),    (0xF218, True,  'FLPR'),
        (0xF21F, False, 'FLPR_2'),   (0xF239, True,  'FLPW'),
    ]

    # +122 region (F2BC+) — after FDC ISR
    shift122 = [
        (0xF2BC, True,  'DUMITR'),
    ]

    # ISR body labels — need per-ISR address mapping (not shift-based)
    # These are inside the rewritten ISR handlers, mapped individually
    # from rel.1.4 actual addresses (found by examining the source)
    isr_direct = [
        # Small ISR entry points (sub_ labels from IVT references)
        ('sub_e46bh', 'SPECB'),   # SIO Ch.B Special Receive (was E44A)
        ('sub_e4a1h', 'EXTSTA'),  # SIO Ch.A External Status (was E46A)
        ('sub_e4d4h', 'SPECA'),   # SIO Ch.A Special Receive (was E487)
        # RTC ISR internals (inside the display ISR body)
        ('le9ech',  'AFB11'),     # rel.1.4 E9EC
        ('le9fdh',  'AFB12'),     # rel.1.4 E9FD
        ('lea0eh',  'AFB13'),     # rel.1.4 EA0E
        ('lea1ah',  'AFB14'),     # rel.1.4 EA1A
        # FDC ISR internals
        ('lf317h',  'FITX'),      # rel.1.4 F317
        ('lf328h',  'FIT1'),      # rel.1.4 F328
        ('lf32bh',  'FIT2'),      # rel.1.4 F32B
    ]

    # Apply all shifted groups
    for shift_val, entries in [(88, shift88), (110, shift110),
                                (115, shift115), (117, shift117),
                                (122, shift122)]:
        for addr13, is_sub, name in entries:
            renames[auto_label(addr13, is_sub, shift_val)] = name

    # Apply ISR body direct mappings
    for old, new in isr_direct:
        renames[old] = new

    return renames


def simultaneous_replace(text, mapping):
    """Replace all keys in mapping with their values simultaneously.

    Uses regex word boundaries to avoid partial matches.
    Handles the case where some old names are substrings of new names
    by doing all replacements in a single pass.
    Skips content inside single-quoted strings (e.g., 'DISKETTE READ ERROR').
    """
    if not mapping:
        return text

    # Sort by length (longest first) to avoid partial matches
    sorted_keys = sorted(mapping.keys(), key=len, reverse=True)
    escaped = [re.escape(k) for k in sorted_keys]
    label_pattern = r'\b(' + '|'.join(escaped) + r')\b'

    # Process line by line, splitting each line into quoted and unquoted parts
    result = []
    for line in text.split('\n'):
        # Split line into segments: alternating unquoted / quoted
        # Single quotes are used for string literals in Z80 asm
        parts = line.split("'")
        new_parts = []
        for i, part in enumerate(parts):
            if i % 2 == 0:
                # Unquoted segment — apply renames
                part = re.sub(label_pattern,
                              lambda m: mapping[m.group(0)], part)
            # Quoted segments (odd indices) are left unchanged
            new_parts.append(part)
        result.append("'".join(new_parts))

    return '\n'.join(result)


def apply_renames(filepath, renames):
    """Apply label renames to an assembly source file."""
    with open(filepath, 'r') as f:
        text = f.read()

    # Count occurrences before
    total_before = 0
    for old in renames:
        count = len(re.findall(r'\b' + re.escape(old) + r'\b', text))
        total_before += count

    new_text = simultaneous_replace(text, renames)

    # Verify no renames left
    remaining = 0
    for old in renames:
        count = len(re.findall(r'\b' + re.escape(old) + r'\b', new_text))
        if count > 0:
            print(f'  WARNING: {old} still appears {count} times', file=sys.stderr)
            remaining += count

    with open(filepath, 'w') as f:
        f.write(new_text)

    renamed = total_before - remaining
    print(f'  {filepath}: {renamed} replacements ({len(renames)} labels)', file=sys.stderr)


def main():
    import os
    workdir = os.path.dirname(os.path.abspath(__file__))

    # Rel.1.3
    mac13 = os.path.join(workdir, 'BIOS_58K.MAC')
    if os.path.exists(mac13):
        print('Renaming labels in BIOS_58K.MAC (rel.1.3)...', file=sys.stderr)
        apply_renames(mac13, REL13_RENAMES)
    else:
        print(f'Not found: {mac13}', file=sys.stderr)

    # Rel.1.4
    mac14 = os.path.join(workdir, 'BIOS_58K_14.MAC')
    if os.path.exists(mac14):
        print('Renaming labels in BIOS_58K_14.MAC (rel.1.4)...', file=sys.stderr)
        rel14_renames = build_rel14_renames()
        apply_renames(mac14, rel14_renames)
    else:
        print(f'Not found: {mac14}', file=sys.stderr)


if __name__ == '__main__':
    main()
