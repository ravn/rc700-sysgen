/*
 * nmi.c — NMI handler for RC702 autoload PROM
 *
 * The Z80 NMI vector is hardwired to 0x0066. This function is placed there
 * via --codeseg NMI in the build. NMI is not used by RC702 hardware, so the
 * handler does nothing and returns immediately.
 *
 * __critical __interrupt generates no EI and ends with RETN, which is
 * correct for NMI: RETN copies IFF2 back to IFF1, restoring the interrupt
 * enable state that was saved when the NMI fired.
 */

/* nmi_noop — NMI handler, does nothing (NMI is unused on RC702) */
void nmi_noop(void) __critical __interrupt {
}
