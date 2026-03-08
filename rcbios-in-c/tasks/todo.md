# BIOS-in-C Phase Tracker

## Completed Phases
- **Phase 1a**: Skeleton (builds, correct binary layout)
- **Phase 1b**: CRT display refresh ISR and keyboard input
- **Phase 1d**: CONOUT display driver with escape sequences
- **Phase 1e**: Floppy disk driver (blocking/deblocking, multi-density T0, verified 4 images)
- **Phase 1f**: Boot sequence — CP/M boots to A> prompt on MAXI 8" disk

## Remaining Work

### SIO serial ring buffer (READI)
- [ ] Arm SIO Ch.A receiver for serial ring buffer in cold boot
- [ ] Enable RTS flow control

### MINI (5.25") support
- [ ] Currently 513 bytes over MINI limit (6657 vs 6144)
- [ ] Optimize code size or conditionally exclude features

### Integration testing
- [ ] Run DIR, PIP, or other transient commands to verify full disk I/O
- [ ] Test warm boot (Ctrl-C from CCP)
- [ ] Test with MINI disk images

### Code quality
- [ ] Audit all BIOS wrappers returning uint16_t for DE→HL sdcccall(1) correctness
- [ ] Consider replacing assembly interrupt wrappers with __interrupt C functions
