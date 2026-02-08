# Ghidra Script to Import ROA375 ROM Analysis
# @category RC702
# @description Seeds Ghidra with disassembly findings from manual analysis

from ghidra.program.model.symbol import SourceType
from ghidra.program.model.listing import CodeUnit

# Get current program
program = currentProgram
listing = program.getListing()
symbolTable = program.getSymbolTable()
addrFactory = program.getAddressFactory()

def addr(offset):
    """Create address from offset"""
    return addrFactory.getDefaultAddressSpace().getAddress(offset)

def setLabel(offset, name, comment=None):
    """Set a label at the given address"""
    address = addr(offset)
    symbolTable.createLabel(address, name, SourceType.USER_DEFINED)
    if comment:
        listing.setComment(address, CodeUnit.PLATE_COMMENT, comment)
    print("Label: 0x%04x -> %s" % (offset, name))

def setComment(offset, comment):
    """Set a comment at the given address"""
    address = addr(offset)
    listing.setComment(address, CodeUnit.EOL_COMMENT, comment)
    print("Comment: 0x%04x -> %s" % (offset, comment))

def setPlateComment(offset, comment):
    """Set a plate comment (multi-line header) at address"""
    address = addr(offset)
    listing.setComment(address, CodeUnit.PLATE_COMMENT, comment)

print("=" * 70)
print("Seeding Ghidra with ROA375 ROM Analysis")
print("=" * 70)

#===========================================================================
# SECTION: Main Entry Points and Flow
#===========================================================================

setLabel(0x0000, "BEGIN",
"""ROM START - COLD BOOT INITIALIZATION

This section executes from ROM and relocates the bootstrap code
to RAM at 0x7000 for execution.""")

setLabel(0x0004, "SCAN", "Find end of ROM image (0xFF marker or zeros)")
setLabel(0x0013, "SKIP", "Found end marker")
setLabel(0x0014, "RELOCATE", "Start memory relocation to RAM")
setLabel(0x001A, "COPYLOOP", "Copy byte-by-byte to 0x7000")
setLabel(0x0027, "INIT_HW", "Hardware initialization routine")
setLabel(0x004E, "CLEARLOOP", "Clear I/O register array (8 bytes)")

#===========================================================================
# SECTION: Hardware I/O Port Usage
#===========================================================================

# Document PORT14 usage
setComment(0x0036, "Read diskette size: bit 7 (1=mini/5.25\", 0=maxi/8\")")
setComment(0x005C, "Disable PROM, enable full RAM access")

# Document PORT18 usage
# (PORT18 is at 0x18, used later in relocated code)

#===========================================================================
# SECTION: Relocated Code Section (PHASE 0x7000)
#===========================================================================

setLabel(0x0068, "DATASTART",
"""DATA SECTION - Code and data that gets relocated to 0x7000

Everything from here gets copied to RAM starting at 0x7000.
Addresses in comments show relocated location.""")

# The actual relocated addresses would be:
# 0x68 in ROM -> 0x7000 in RAM
# So we document both

setPlateComment(0x0069, "RST 38H vector (0xFF opcode)")

# Code blocks
setLabel(0x0069, "CODE_BLK1", "Display initialization - message 1")
setLabel(0x0075, "CODE_BLK2", "Display initialization - message 2")
setLabel(0x0084, "CODE_BLK3", "Display initialization - message 3")

# Subroutines
setLabel(0x0096, "SUB_CMP1", "String comparison helper 1")
setLabel(0x00A7, "SUB_CMP2", "String comparison helper 2")
setLabel(0x00B8, "SUB_CHK", "Check byte at offset +7, compare with 0x13")
setLabel(0x00C5, "SUB_COMPARE",
"""Compare memory regions byte by byte

Input: DE = source1, BC = source2, L = byte count
Output: Z flag set if equal""")

setLabel(0x00D1, "SUB_COPY",
"""Copy memory block

Input: DE = source, BC = destination, L = byte count""")

# Error messages
setLabel(0x00DA, "MSG_ERROR1",
"""Boot failure error messages

Displayed when system cannot boot from diskette.""")

# The message breaks down as:
# " RC700" + " RC702" + " **NO SYSTEM FILES** " +
# " **NO DISKETTE NOR LINEPROG** " + " **NO KATALOG** "

setComment(0x00DA, "Message: ' RC700'")
setComment(0x00E0, "Message: ' RC702'")
setComment(0x00E6, "Message: ' **NO SYSTEM FILES** '")
setComment(0x00FC, "Message: ' **NO DISKETTE NOR LINEPROG** '")
setComment(0x011C, "Message: ' **NO KATALOG** '")
setComment(0x012A, "Control character (0x02)")

# Command table
setLabel(0x012B, "CMD_TABLE", "System command identifier strings")
setComment(0x012B, "Jump vector: JP 0x53C8")
setComment(0x012E, "Commands: 'SYSM SYSC '")

#===========================================================================
# SECTION: Memory Mapped I/O Addresses
#===========================================================================

# Create equate symbols for memory-mapped I/O
# Note: These are referenced but not in the ROM itself

print("\n" + "=" * 70)
print("Memory-Mapped I/O Addresses (referenced in code):")
print("=" * 70)
print("0x801C - I/O control register")
print("0x801D - I/O control register")
print("0x8042 - I/O control register")
print("0x8033 - I/O control register")
print("0x801B - I/O control register")
print("0x8060 - I/O control register")
print("0x8061 - I/O control register")
print("0x8041 - I/O control register")
print("0x8062 - I/O control register")
print("0x8063 - I/O register array base (8 bytes)")
print("0x7320 - Storage for diskette type")
print("0x7218 - Jump target address")
print("=" * 70)

#===========================================================================
# SECTION: Add Bookmarks for Key Locations
#===========================================================================

from ghidra.program.model.listing import BookmarkType

bookmarkManager = program.getBookmarkManager()

def addBookmark(offset, category, comment):
    """Add a bookmark at the given address"""
    address = addr(offset)
    bookmarkManager.setBookmark(address, BookmarkType.INFO, category, comment)
    print("Bookmark: 0x%04x [%s] %s" % (offset, category, comment))

print("\n" + "=" * 70)
print("Adding Bookmarks:")
print("=" * 70)

addBookmark(0x0000, "Entry", "ROM cold boot start")
addBookmark(0x0027, "Init", "Hardware initialization")
addBookmark(0x0068, "Data", "Start of relocated section")
addBookmark(0x00DA, "Error", "Boot failure messages")

#===========================================================================
# SECTION: Summary
#===========================================================================

print("\n" + "=" * 70)
print("Seeding Complete!")
print("=" * 70)
print("\nNext steps in Ghidra:")
print("1. Review the labels in the Symbol Tree")
print("2. Check bookmarks in the Bookmark window")
print("3. Follow code flow from BEGIN (0x0000)")
print("4. Examine the relocated section starting at DATASTART (0x68)")
print("5. Add more detailed comments as you analyze")
print("\nKey hardware information:")
print("- PORT14 (0x14): Mini/Maxi switch & PROM disable")
print("- PORT18 (0x18): Beeper/speaker")
print("- Relocation: ROM 0x68+ -> RAM 0x7000+")
print("=" * 70)
