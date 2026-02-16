/*
 * fdc.c — FDC driver for RC702 autoload
 *
 * uPD765/8272 floppy disk controller interface.
 * Density auto-detect, read, seek, retries.
 */

#include "hal.h"
