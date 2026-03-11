# Copilot Instructions for RC702 Sysgen Repository

This guide helps AI assistants work effectively in this Z80 assembly codebase for the RC702 computer system.

## Quick Context

This project aims to make the RC702 family fully usable in MAME with preservation disk images from ddhf.dk, alongside hardware-compatible implementations. The RC702 is a Z80-based business machine with:
- CPU: Z80-A @ 4 MHz
- Storage: 8" & 5.25" floppies, optional hard disk (later models)
- I/O: Keyboard via parallel port, communication via serial port
- OS: CP/M-80 (firmware + BIOS)

**Project Goals** (in order of priority):

1. **MAME Bug Fixes** - Make RC702 family emulation in MAME bug-free so preservation disk images (e.g., from ddhf.dk) run identically to original hardware

2. **Firmware Refactoring** - Refactor original firmware and BIOS from CP/M-80 into:
   - Byte-exact Z80 assembly equivalents (complete)
   - C implementations using z88dk compiler (ongoing)

3. **Software Archaeology** - Establish timeline of how original software was developed

4. **MEMDISK Recovery** - Understand and restore MEMDISK functionality (RAM-based disk)

5. **CP/NET Networking** - Implement CP/NET for transparent file transfers:
   - Phase 1: Serial port transport
   - Phase 2: Parallel port transport

6. **Native Hardware Support** - Run refactored code on original RC702 hardware against a server (platform TBD)

7. **Diskless Client** - Create CP/NOS (diskless client):
   - Boot PROM1 with minimal code
   - Download remaining OS from CP/NET server at runtime

## Build & Verification Commands

### SYSGEN Assembly (`sysgen/`)
```bash
# Assemble with zmac (primary method)
zmac -z --dri SYSGEN.ASM        # Produces zout/SYSGEN.cim
make verify                      # Compare against RCSYSGEN.COM reference
```
⚠️ **Critical**: Use `-z --dri` flags (not `-8` which is 8080 mode). This is Z80 code.

### ROA375 PROM (`roa375/`)
```bash
make              # Build roa375.cim from roa375.asm
make verify       # Compare against roa375.rom (original ROM image)
```

### RC702 BIOS (`rcbios/`)
```bash
# Build specific variants
make rel21-mini   # CP/M 2.1, 5.25" mini floppy, 56K TPA
make rel22-mini   # CP/M 2.2, 5.25" mini floppy, 56K TPA
make rel23-maxi   # CP/M 2.3, 8" maxi floppy, 56K TPA
make rel14-maxi   # CP/M 1.4, 8" maxi floppy, 58K TPA
make verify       # Build ALL variants & verify against extracted binaries
make patch-test   # Patch BIOS onto disk, boot in emulator, verify signon
```

### Autoload-in-C PROM (`autoload-in-c/`)
```bash
make test         # Run host tests (mock HAL, no hardware needed)
make rom          # Build Z80 ROM (requires z88dk)
make prom         # Assemble 2048-byte image
make rc700        # Build & run in RC700 emulator
```

### Assembler Toolchain (`zmac/`)
```bash
make              # Download & compile zmac from source
```

## Verification Strategy

**Every build must be verified before marking complete**:

1. **Binary comparison** - Verify assembled `.cim` or `.COM` matches reference:
   ```bash
   make verify     # Uses cmp command on Makefiles
   dhex ORIGINAL.COM NEW.COM  # Visual hex diff
   ```

2. **Symbol file checks** - Ensure correct byte alignment:
   ```bash
   grep '04EF SIGNON' SYSGEN.SYM  # Address verification
   ```

3. **Python verification scripts** (in `rcbios/`):
   - `verify_bios.py` - Compare extracted vs assembled BIOS
   - `patch_bios.py` - Patch BIOS onto IMD disk images + verify boot

## Assembly Language Conventions

### Z80 Assembler: zmac
- **Syntax dialect**: Digital Research (DRI) MAC assembler
- **Key flags**: `-z` (Z80), `--dri` (syntax), `-f` (full listing), `-l` (listing file)
- **Output format**: `.cim` files (binary) or `.COM` files (CP/M executables at org 0x0100)
- **Directives**: `.Z80`, `ORG`, `EQU`, `DB`, `DW`, `IF`/`ENDIF` (conditional assembly)
- **Error codes**: Single-character flags in listings: `L` (label), `U` (undefined), `P` (phase), `S` (syntax)

### Symbol Files
Before committing `.SYM` files to git, strip CP/M EOF markers:
```bash
perl -i -pe 's/\032//g' SYSGEN.SYM
```
This lets git recognize them as ASCII text.

## High-Level Architecture

### Multi-Density Disk Format
RC702 uses mixed-density 8" diskettes for backward compatibility:
```
Track 0, Side 0:  FM (single density)  - 26 sectors × 128 bytes = 3.3 KB
Track 0, Side 1:  MFM (double density) - 26 sectors × 256 bytes = 6.5 KB
Tracks 1-76 both: MFM (double density) - 15 sectors × 512 bytes per track
Total capacity: ~1.2 MB (DS/DD format)
```

This complexity is why SYSGEN required RC702-specific modifications. Track 0's mixed encoding requires dynamic density switching during read/write operations.

### Boot Sequence (ROA375 PROM)
```
1. ROM entry at 0x0000: DI, set SP, CALL relocate, JP 0x7000
2. Self-relocate code from ROM (0x0000) to RAM (0x7000)
3. Initialize Z80 Mode 2 interrupt vectors at 0x7300
4. Initialize hardware: PIO, DMA, CTC, CRT controllers
5. Read Track 0 (mixed density) into memory at 0x0000
6. Disable ROM via I/O port 0x14
7. Jump to 0x0000 and begin CP/M cold boot
```

### PROM Image Layout (2048 bytes max)
```
Address   Section  Contents
--------  -------  -----------------------------------------------
0x0000    BOOT     Entry point (asm): relocate code
0x000A             clear_screen function
0x0018             init_fdc function
0x0066    NMI      RETN instruction (Z80 hardware NMI vector)
0x0068    CODE     Interrupt handlers, HAL (asm) + boot logic (C)
          ...      Interrupt vector table at 0x7100 (256-byte aligned)
          ...      FDC driver, format tables, read-only data
```

**BOOT and NMI** are permanently in ROM until boot completes. **CODE** section is copied to RAM (0x7000) by `relocate()` using linker symbols.

### Component Directory Map

| Directory | Purpose |
|-----------|---------|
| `sysgen/` | SYSGEN utility (main SYSGEN.ASM target) |
| `roa375/` | Boot ROM assembly version + binaries |
| `autoload-in-asm/` | Alternative ASM-only boot ROM |
| `autoload-in-c/` | Boot ROM C rewrite with z88dk + tests |
| `rcbios/` | CP/M BIOS extraction & reconstruction + patching tools |
| `zmac/` | Z80 macro assembler (pre-compiled binary) |
| `cpnet/` | CP/M networking system (SNIOS) |
| `docs/` | Technical documentation & specs |

## Key Conventions

### Documentation Location
- **Project documentation** → Commit to repo (README.md, CLAUDE.md, etc.)
- **Session working notes** → Session workspace only (do NOT commit to repo)
- See `CLAUDE.md` section "Documentation Preference" for rationale

### Reference Files
- **CLAUDE.md** - Comprehensive guidance for Claude Code (architecture, components, conventions)
- **AGENT.md** - Workflow orchestration (plan mode, subagent strategy, verification discipline)
- **RC702_HARDWARE_TECHNICAL_REFERENCE.md** - I/O ports, memory maps, controller specs

### Build Verification Before Commit
✅ **Always verify** assembled binaries match reference before marking work complete:
- Use `make verify` in component directories
- Compare with reference `.COM` or `.ROM` files
- Check symbol alignment with grep

### Error Handling in MAC
Single-character error codes in listings:
- `B` - Balance error (macro/conditional assembly malformed)
- `C` - Comma error (expression not delimited)
- `D` - Data error (DB/DW element placement)
- `E` - Expression error (ill-formed expression)
- `I` - Invalid character (non-graphic character)
- `L` - Label error (duplicate or invalid placement)
- `M` - Multiple definition (label defined twice)
- `N` - Nesting error (too many nested macros/conditionals)
- `O` - Overflow error (value too large for field)
- `P` - Phase error (label value differs between passes)
- `R` - Register error (invalid register in instruction)
- `S` - Syntax error (malformed instruction)
- `U` - Undefined symbol

## CI/CD Workflow

The `.github/workflows/makefile.yml` runs:
1. Compile zmac assembler
2. Assemble ROA375 PROM with listing
3. Assemble SYSGEN utility
4. Implicit verification (Makefiles use `make verify` targets)

This ensures builds remain reproducible across sessions.

## Working with Copilot in This Codebase

### Task Framing
**Do**: Frame tasks as problems to solve, not questions to answer. Include context and constraints.
- ✅ "The SYSGEN Track 0 density-switching logic fails when tracks are non-contiguous. Debug and fix."
- ❌ "How does SYSGEN handle Track 0?"

**Source**: AGENT.md (Autonomous Bug Fixing principle)

### Verification Discipline
**Always verify before marking done**:
1. Run `make verify` in the affected component directory
2. Compare binaries against reference files (`.COM`, `.ROM`, `.cim`)
3. For BIOS patches, run `make patch-test` to verify boot in emulator
4. Show diff output if changes fail verification

**Source**: AGENT.md (Verification Before Done), README.md assembly verification section

### Error Investigation
When assembly fails:
1. Check single-character MAC error codes in listing files
2. Reference README.md "MAC error codes" section for meaning
3. Show the error line(s) in output before attempting fixes

**Source**: README.md (lines 45-60)

### Binary Matching
For byte-exact targets, always use symbol file alignment checks:
```bash
grep '04EF SIGNON' SYSGEN.SYM && dhex RCSYSGEN.COM SYSGEN.COM
```
The grep ensures correct byte alignment before hex comparison.

**Source**: README.md (lines 31-35)

### Multi-Density Context
When working on SYSGEN, BIOS, or ROA375 disk I/O: assume Track 0 mixed encoding (FM side 0, MFM side 1) unless explicitly stated otherwise. This is why the code exists.

**Source**: README.md (lines 4-9), CLAUDE.md (lines 121-135)

### Tool Selection
- **zmac** for Z80 assembly (primary, reproducible)
- **MAC** under CP/M emulation only if zmac fails (legacy fallback)
- **Python scripts** in rcbios/ for BIOS extraction/patching workflows
- **z88dk** for C-based autoload PROM (advanced, separate build system)

**Source**: README.md (lines 22-26), CLAUDE.md (lines 80-86)

## MCP Server Configuration

For enhanced Copilot integration with this project, configure these MCP servers:

### Python MCP Server
Enables running Python verification scripts (BIOS extraction, disk patching, format analysis):
```json
{
  "mcpServers": {
    "python": {
      "command": "python3",
      "args": ["-m", "mcp.server.stdio"],
      "env": {
        "PYTHONPATH": "."
      }
    }
  }
}
```

### Shell/Bash MCP Server
Enables direct command execution for Make targets, disk image utilities, and emulator control:
```json
{
  "mcpServers": {
    "bash": {
      "command": "bash",
      "args": ["-i"]
    }
  }
}
```

Configure in your Copilot settings (Cursor `.cursor/mcp.json`, Windsurf `.windsurfrules`, etc.) to enable direct script execution and disk/format analysis workflows.

## References

- **RC702 Emulator**: http://www.jbox.dk/rc702/
- **zmac Assembler**: http://48k.ca/zmac.html (source & docs)
- **MAC Assembler Docs**: http://www.cpm.z80.de/manuals/mac.pdf
- **CP/M Sources**: http://www.cpm.z80.de/source.html
- **Z80 Instruction Set**: Standard Z80 references (A80 format compatible with zmac)
