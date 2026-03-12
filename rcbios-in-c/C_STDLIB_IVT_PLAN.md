# Plan: Move IVT Setup to C with z88dk stdlib

## Current State

- **crt0.asm** defines the IVT as a static `defw` table at a 256-byte aligned address (~line 270)
- ISR wrappers use hand-written `__naked` functions with custom `isr_enter`/`isr_exit` macros that switch to a dedicated interrupt stack (`sp_sav` / `0xF620`)
- Build uses `--no-crt` — no stdlib, no z88dk library functions linked
- `im 2` and `ld i, a` are done in the `_cboot` assembly block

## What z88dk Offers

z88dk has a dedicated IM2 library (`im2.h`):

| Function | What it does |
|----------|-------------|
| `im2_init(addr)` | Sets `I` register and executes `IM 2` (3 instructions) |
| `im2_install_isr(vector, isr)` | Writes ISR address into the IVT at `I*256 + vector` |
| `IM2_DEFINE_ISR(name)` | Macro: generates `__naked` wrapper with full register save (AF,BC,DE,HL,IX,IY + shadow regs), `EI`, `RETI` |
| `IM2_DEFINE_ISR_8080(name)` | Same but saves only AF,BC,DE,HL (lighter, no IX/IY/shadow) |

**Key detail**: `im2_install_isr` reads the `I` register at runtime to find the table base — no compile-time address needed. The `vector` parameter is the low byte (device-supplied byte on the data bus during IACK).

### Source locations (z88dk)

- **IM2 API**: `z88dk/download/z88dk/include/_DEVELOPMENT/sdcc/im2.h`
- **IM2 library**: `z88dk/download/z88dk/libsrc/_DEVELOPMENT/im2/z80/`
- `im2_init`: `ld a,h` / `ld i,a` / `im 2` / `ret` (4 instructions)
- `im2_install_isr`: reads I register, indexes into IVT, swaps old/new address (10 instructions)
- `IM2_DEFINE_ISR`: macro generates `__naked` wrapper calling `asm_im2_push_registers` (saves AF,BC,DE + shadow AF',BC',DE',HL',IX,IY = 10 pushes), then body, then `asm_im2_pop_registers`, `EI`, `RETI`
- `IM2_DEFINE_ISR_8080`: lighter variant, saves only AF,BC,DE (3 pushes)

## Compatibility Concerns

1. **ISR stack switch**: Our ISRs switch SP to `0xF620` via `sp_sav`. z88dk's `IM2_DEFINE_ISR` does NOT switch stacks — it pushes onto whatever stack is current. This is a problem if the caller's stack is too small.

2. **`sp_sav` sharing**: Our current design uses a single `sp_sav` variable, which means ISRs cannot nest. `IM2_DEFINE_ISR` doesn't have this limitation (no shared state), but also doesn't switch stacks.

3. **Register save scope**: `IM2_DEFINE_ISR` saves ALL registers including IX, IY, and shadow regs (10 pushes = 20 bytes of stack). Our `isr_enter_full` saves only AF,BC,DE,HL (4 pushes = 8 bytes). The full save is safer but costs ~40 extra T-states per ISR.

4. **`--no-crt` vs stdlib**: Currently `--no-crt` prevents any library code from being linked. To use `im2.h` functions, we need to either:
   - Drop `--no-crt` and use z88dk's CRT (major change, must reconcile with fixed binary layout)
   - Keep `--no-crt` but manually link the im2 library objects
   - Just write equivalent C code ourselves (the functions are trivial)

5. **Section ordering**: Our crt0.asm declares specific section ordering. z88dk's CRT has its own section model. Mixing could cause layout problems.

## Proposed Approach (Incremental)

### Phase 1: IVT in C (keep `--no-crt`, no stdlib)

- Remove the `defw` IVT table from crt0.asm
- Add a `word ivt[18]` array in BSS with forced 256-byte alignment
- Populate it in `bios_hw_init()` with assignments: `ivt[0] = (word)isr_dummy; ivt[2] = (word)isr_crt;` etc.
- Keep `im 2` setup in `_cboot` assembly, or move to a tiny C helper
- **Risk**: Low. Same binary, just IVT built at runtime instead of compile time.

### Phase 2: Evaluate `IM2_DEFINE_ISR` macro

- Try replacing our `isr_enter`/`isr_exit` wrappers with `IM2_DEFINE_ISR`
- Measure: code size impact (shadow register saves add ~12 bytes per ISR) and cycle cost
- Decide: is the cleaner code worth the overhead?
- **Blocker**: Stack switch. Either accept no stack switch (ISRs run on caller's stack) or wrap `IM2_DEFINE_ISR` with a stack switch.

### Phase 3: Evaluate dropping `--no-crt`

- Try building with z88dk's standard CRT while keeping our crt0.asm for the fixed layout
- See if stdlib functions (memcpy, memset) are usable without conflicts
- Check if `#include <im2.h>` and linking the im2 library works alongside `--no-crt`
- **Risk**: High. Section ordering, ORG conflicts, duplicate symbols.

## Recommendation

Phase 1 is straightforward and self-contained — it moves the IVT to C without changing the build system. The z88dk im2 library functions are so trivial (3-5 instructions each) that writing equivalent C code is simpler than fighting `--no-crt` linkage issues.
