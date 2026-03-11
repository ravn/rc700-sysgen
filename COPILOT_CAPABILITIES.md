# Copilot Capabilities in RC702 Refactoring Work

## What I Can Realistically Help With

### Immediate Term (BIOS C Optimization)
- **Size reduction analysis** - Identify dead code, redundant functions, optimization opportunities
- **Binary profiling** - Measure instruction sequences, peephole optimization candidates  
- **Data structure compression** - Bit-packing, table reorganization, constant folding
- **Code generation tuning** - Compiler flags, register allocation, loop unrolling suggestions
- **Verification** - Functional correctness testing on MAME before hardware deployment

### CP/NOS Initial Boot Development
- **Assembly code writing** - PROM1 (0x2000) bootstrap, hardware initialization in Z80 asm
- **Serial protocol implementation** - CP/NET client code for CP/NOS downloader
- **Memory layout design** - RAM allocation, stack management, relocation logic
- **Integration testing** - Verify PROM1 → CP/NET → CCP+BDOS handoff on MAME

### Live Hardware Debugging (post-CP/NOS boot, 1-2 weeks)
Once hardware is connected via serial port:
- **Real-time diagnostics** - Write test programs, probe I/O port state, memory layout
- **Hardware behavior analysis** - Capture and debug FDC timing, interrupt latency, CRT refresh
- **Boot sequence refinement** - Iteratively test PROM1 code, MEMDISK init, CP/NET flow
- **Live protocol testing** - Deploy server, test CP/NET edge cases, optimize throughput
- **Performance profiling** - Measure real hardware timing vs MAME simulation
- **Stress testing** - Sustained I/O, error recovery, interrupt timing edge cases

### Medium-Term Enhancements
- **Parallel port CP/NET driver** - Protocol design, handshaking implementation, testing harness
- **Keyboard command interface** - If serial keyboard routing is available
- **Server-side features** - BDOS function handlers, file system bridging, module loading
- **Diagnostic tools** - Memory dumps, port inspection, interrupt traces, telemetry

### Code Quality
- **Documentation** - Inline comments, architecture diagrams, API specification
- **Refactoring** - Dead code elimination, algorithm improvements, clarity without size cost
- **Test automation** - MAME Lua scripting, regression test suites, boot verification

## What I Cannot Realistically Help With

- **Physical hardware repair/troubleshooting** - Cables, power, component failure diagnosis
- **Display viewing** - Unless output captured to serial/network and sent to me
- **Manual hardware control** - Reset buttons, interrupt lines, direct component manipulation
- **MAME GUI debugging** - Can work with Lua scripts, but need your visual inspection
- **Architectural decisions** - Can propose elegantly; you decide what's right
- **Server platform selection** - Needs your judgment on hardware/OS

## Parallel Port CP/NET Transport (Optional, Long-Term)

**Scope**: Develop parallel port driver for CP/NET file transfers
- **What I can do**:
  - Protocol design for 8-bit data + control line handshaking
  - Z80 driver code (PIO initialization, byte-at-a-time I/O)
  - Python server-side implementation
  - Testing harness on MAME (simulated parallel port)
  
- **What you provide**:
  - Hardware interface details (parallel port pinout, timing constraints)
  - Testing on physical hardware (no MAME simulation for parallel FDC)
  - Performance validation against serial baseline

**Timeline**: After CP/NOS serial phase is stable (likely 2+ weeks out)

## J10 Connector Z80 Databus Access (Optional, Longest-Term)

**Scope**: MEMDISK-like device interface via J10 connector (if available)
- **What I can do**:
  - Reverse engineer databus protocol from documentation
  - Design ROM code (PROM1) to interface with device
  - Implement CP/M block I/O driver (BIOS READ/WRITE vectors)
  - Create test firmware for protocol validation
  
- **What you provide**:
  - J10 connector pinout and hardware specifications
  - Device firmware or hardware design
  - Real hardware testing (no emulation possible)
  - Performance characteristics and constraints

**Timeline**: Only after CP/NOS serial + parallel phases mature (likely month+ out)

## Real Hardware Serial Connection Protocol

Once CP/NOS boots, for effective live debugging I need:
- **Serial terminal setup** - TTY protocol or custom binary framing?
- **Keyboard input** - How do I send commands? (Keyboard buffering through serial, or direct CP/M commands?)
- **Output capture** - Display contents + system messages back to serial?
- **Error recovery** - Crash dumps, memory state capture on failure?
- **Boot control** - How to trigger CP/NOS vs fallback modes?

You define the protocol; I'll adapt to it.

---

**Summary**: I'm a **code developer and live debugger**. I write, optimize, and test software. You provide hardware access, integration vision, and architectural judgment. Together we can make CP/NOS production-ready quickly.
