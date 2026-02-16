/*
 * isr.c — Interrupt service routines for RC702 autoload
 *
 * DISINT (display interrupt) may need inline assembly due to
 * timing-critical DMA reprogramming.
 */

#include "hal.h"
