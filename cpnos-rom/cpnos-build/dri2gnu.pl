#!/usr/bin/perl -w
# Translate XIZ-produced Zilog Z80 source (DRI directives) into
# GNU-as syntax that clang --target=z80 can assemble.
#
# Read from stdin, write to stdout.

use strict;
use warnings;
use feature 'state';

sub _split_chars {
    my $s = shift;
    $s =~ s|''|'|g;       # de-double DRI doubled quotes
    return "'$s'" if length($s) == 1;
    return join(',', map { "'$_'" } split(//, $s));
}

while (my $line = <>) {
    $line =~ s/\r//g;         # CRLF -> LF
    $line =~ s/\x1A//g;       # Strip CP/M Ctrl-Z EOF padding
    chomp $line;              # Strip trailing \n so regexes don't eat it
    # (we'll add a single \n back at end of iteration)

    # Drop entirely-blank lines.
    if ($line =~ /^\s*$/) { next; }

    # Skip END / TITLE / PAGE (listing/layout, GNU-as has no equivalent).
    if ($line =~ /^\s*END(\s|$)/i) { next; }
    if ($line =~ /^\s*TITLE(\s|$)/i) { next; }
    if ($line =~ /^\s*PAGE\s*(;.*)?$/i) { next; }

    # EXTRN / EXTERNAL
    $line =~ s/^(\s*)EXTRN\s+(.+?)\s*$/$1.extern $2/i;

    # PUBLIC
    $line =~ s/^(\s*)PUBLIC\s+(.+?)\s*$/$1.global $2/i;

    # CSEG / DSEG.  DSEG in DRI holds initialized data (tables,
    # strings) plus zero-init reservations (ds) — not strict BSS —
    # so use @progbits not @nobits.
    $line =~ s/^(\s*)CSEG\s*(;.*)?$/$1.section .cpnos_code,"ax",\@progbits/i;
    $line =~ s/^(\s*)DSEG\s*(;.*)?$/$1.section .cpnos_data,"aw",\@progbits/i;

    # ORG
    $line =~ s/^(\s*)ORG\s+/$1.org /i;

    # DEFB -> .byte, DEFW -> .2byte, DEFS -> .skip
    $line =~ s/\bDEFB\b/.byte/ig;
    $line =~ s/\bDEFW\b/.2byte/ig;
    $line =~ s/\bDEFS\b/.skip/ig;

    # "NAME EQU value" -> ".equ NAME, value"  (only if label-less)
    # Pattern: <name>\s+EQU\s+<expr>
    $line =~ s/^(\s*)([A-Za-z_\$][A-Za-z0-9_\$\?]*)\s+EQU\s+(.+?)\s*$/$1.equ $2, $3/i;

    # Hex literals: 0FFH / 0xFF / 0FFh -> 0xFF
    $line =~ s/\b([0-9][0-9A-Fa-f]*)[Hh]\b/0x$1/g;

    # Binary literals: "0000$0000B" or "111B" -> "0b00000000" / "0b111"
    # DRI allows $ as digit grouping inside binary literals.
    $line =~ s/\b([01]+(?:\$[01]+)*)B\b/"0b" . ($1 =~ s|\$||gr)/ge;

    # $ is DRI's location counter.  Protect $ in identifiers
    # (STA$RET) and $ inside single-quoted character literals before
    # converting standalone $ to '.'.
    $line =~ s/([A-Za-z_])\$([A-Za-z_0-9])/$1\x01$2/g;   # \x01 placeholder
    $line =~ s/'\$'/'\x02'/g;                              # quoted dollar
    $line =~ s/'([^']*)\$([^']*)'/"'$1\x02$2'"/g;          # $ inside longer quoted
    $line =~ s/\$/./g;                                      # now safe
    $line =~ s/\x01/\$/g;                                    # restore identifier $
    $line =~ s/\x02/\$/g;                                    # restore quoted $

    # DRI "not X" in expressions -> bitwise complement.  XIZ leaves
    # these alone; GNU-as uses ~.  Conservative: only when we see
    # "not true" or "not false" (the only pattern in our sources).
    $line =~ s/\bNOT\s+TRUE\b/0/ig;
    $line =~ s/\bNOT\s+FALSE\b/0xFFFF/ig;

    # DRI conditional assembly: IF / ELSE / ENDIF -> .if / .else / .endif
    $line =~ s/^(\s*)IF\s+/$1.if /i;
    $line =~ s/^(\s*)ELSE\s*(;.*)?$/$1.else/i;
    $line =~ s/^(\s*)ENDIF\s*(;.*)?$/$1.endif/i;

    # DRI operators: MOD -> %, SHL -> <<, SHR -> >>, AND -> &,
    # OR -> |, XOR -> ^, NOT -> ~.  These are DRI expression keywords;
    # they also appear as mnemonics (AND A, OR B, XOR H) so only
    # replace when they look like infix/prefix operators: preceded by
    # an expression-safe char (space in expression context), followed
    # by whitespace then alphanumeric/paren.
    # Simpler conservative rule: only convert AND/OR/XOR/NOT when
    # they appear on .if / .equ / .org lines or inside parenthesised
    # expressions where DRI keyword semantics apply.
    if ($line =~ /^\s*(\.if|\.equ|\.org|\.byte|\.2byte|\.skip|and|or|xor|AND|OR|XOR)\b/i) {
        $line =~ s/\bMOD\b/%/g;
        $line =~ s/\bSHL\b/<</g;
        $line =~ s/\bSHR\b/>>/g;
    }
    # `NOT (expr)` as bitwise complement in mnemonic context.  Can't
    # use `~(expr)` — clang Z80 doesn't accept `~` prefix operator,
    # and a leading `(` gets parsed as memory indirect.  Use
    # `0xFF ^ (expr)` which is equivalent for 8-bit masks.
    $line =~ s/\bNOT\s+\(([^)]+)\)/0xFF ^ ($1)/g;

    # DRI AND/OR/XOR as infix operators inside instruction operand
    # expressions.  These conflict with the Z80 mnemonics of the same
    # names — so convert only when preceded by `)` or a literal/name
    # (expression continuation), not when starting a line (mnemonic).
    $line =~ s/(\))\s*AND\s+/$1 \& /g;
    $line =~ s/(\))\s*OR\s+/$1 | /g;
    $line =~ s/(\))\s*XOR\s+/$1 ^ /g;
    # NOT as operator in assembler expressions (.if, .equ bodies)
    # only — leave alone in opcodes.
    if ($line =~ /^\s*(\.if|\.equ|\.org)\b/i) {
        $line =~ s/\bNOT\b/~/g;
        $line =~ s/\bAND\b/&/g;
        $line =~ s/\bOR\b/|/g;
    }

    # Multi-char single-quoted strings inside .byte: DRI accepts
    # `.byte 'ABC'` as three bytes; GNU-as needs 'A','B','C'.
    # Split multi-char strings into comma-separated single-char
    # literals.  Handles optional label prefix.
    if ($line =~ /^([A-Za-z_][A-Za-z0-9_]*:)?\s*\.byte\s/) {
        $line =~ s/'((?:''|[^'])+)'/_split_chars($1)/ge;
    } else {
        # Outside .byte context, a 2-char string literal is DRI's
        # 16-bit packed value (1st char = low byte, 2nd = high).
        # Convert 'xy' -> ('x' + 'y' * 256) so GNU-as computes it.
        $line =~ s/'([^'])([^'])'/"('$1' + '$2' * 256)"/ge;
    }

    # `jp $` (jump-to-self error halt) -> `jp .` is rejected by
    # clang's Z80 as.  Emit a unique local label + jump.
    state $hang_id = 0;
    if ($line =~ /^(\s*)(jp|jr|call)(\s+)\.\s*(;.*)?$/i) {
        my $indent = $1;
        my $op = lc $2;
        my $ws = $3;
        my $cmt = $4 // '';
        $hang_id++;
        $line = qq{${indent}_hang${hang_id}: ${op}${ws}_hang${hang_id}  $cmt};
    }

    # Lowercase known Z80 mnemonics.  Use lookahead (non-consuming) so
    # the whitespace *after* the mnemonic stays in the output.
    $line =~ s/^(\s+)([A-Z]{2,5})(?=\s|$)/$1.lc($2)/e
        if $line =~ /^(\s+)(LD|LDI|LDIR|LDD|LDDR|CP|CPI|CPIR|CPD|CPDR
                        |JP|JR|CALL|RET|RETI|RETN|DJNZ|RST
                        |ADD|ADC|SUB|SBC|AND|OR|XOR|INC|DEC|CPL|NEG
                        |RLC|RRC|RL|RR|SLA|SRA|SLL|SRL|RLD|RRD|BIT|SET|RES
                        |PUSH|POP|EX|EXX|IN|OUT|INI|IND|OUTI|OUTD
                        |DI|EI|HALT|NOP|IM|DAA|SCF|CCF
                        |RLCA|RRCA|RLA|RRA)(\s|$)/x;

    print "$line\n";
}
