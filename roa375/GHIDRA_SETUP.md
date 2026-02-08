# Ghidra Setup Guide for ROA375 ROM Analysis

## Step 1: Create New Project

1. Launch Ghidra
2. **File → New Project**
3. Choose **Non-Shared Project**
4. Name: `RC702_ROA375`
5. Click **Finish**

## Step 2: Import the ROM

1. **File → Import File**
2. Select `roa375.rom`
3. Format: **Raw Binary**
4. Click **OK**

### Import Settings:
- **Language**: `Z80:LE:16:default` (select Z80 processor)
- **Base Address**: `0x0000` (ROM starts at address 0)
- Leave other settings as default
- Click **OK**

## Step 3: Open in CodeBrowser

1. Double-click `roa375.rom` in the project tree
2. When prompted to analyze: **YES**

### Analysis Options:
- ✅ Check: **Disassemble Entry Points**
- ✅ Check: **ASCII Strings**
- ✅ Check: **Create Address Tables**
- ✅ Check: **Subroutine References**
- Click **Analyze**

Wait for auto-analysis to complete (watch progress bar)

## Step 4: Run the Seed Script

1. In CodeBrowser: **Window → Script Manager**
2. Click **Create New Script** button (or press Ctrl+Shift+N)
3. Navigate to: `/Users/ravn/git/rc700-sysgen/roa375/`
4. Select `seed_ghidra.py`
5. Click **Run Script** button (green play icon)

**OR** from the command line:
```bash
# Add to your Ghidra script directory
cp seed_ghidra.py ~/ghidra_scripts/
```

Then in Ghidra Script Manager, refresh and run it.

### Expected Output:
The script will add:
- ✅ Labels for all key routines (BEGIN, SCAN, COPY, etc.)
- ✅ Comments explaining hardware operations
- ✅ Plate comments for major sections
- ✅ Bookmarks for navigation
- ✅ Documentation for I/O ports

## Step 5: Explore the Analysis

### Key Views to Open:

1. **Symbol Tree** (Window → Symbol Tree)
   - Shows all labels we added
   - Navigate by clicking labels

2. **Bookmarks** (Window → Bookmarks)
   - Quick navigation to key locations
   - Categories: Entry, Init, Data, Error

3. **Listing** (main disassembly view)
   - Shows annotated assembly
   - Comments appear inline

4. **Decompiler** (Window → Decompiler)
   - Shows pseudo-C code
   - Helps understand logic flow

### Navigation Tips:

- Press **G** (Go to address): Jump to specific address
- Click on **labels** to see cross-references
- Right-click → **Set Label** to add your own
- Press **;** to add end-of-line comments
- Press **/** to add pre-comments

## Step 6: Continue Analysis

### Follow the Boot Sequence:

1. Start at **BEGIN** (0x0000)
   - `DI` - Disable interrupts
   - `LD SP, 0xBFFF` - Set stack

2. Follow to **SCAN** (0x0004)
   - Searches for ROM end marker

3. Jump to **RELOCATE** (0x0014)
   - Copies code to RAM

4. Follow to **INIT_HW** (0x0027)
   - Hardware initialization
   - PORT14 operations

5. Examine **DATASTART** (0x0068)
   - This gets relocated to 0x7000
   - Contains boot messages

### Key Hardware Documentation:

**PORT14 (0x14)**: Mini/Maxi switch & PROM disable
- **Read**: bit 7 = diskette size (1=mini/5.25", 0=maxi/8")
- **Write**: disables PROM to enable full RAM access

**PORT18 (0x18)**: Beeper/speaker output

### Understanding PHASE/Relocation:

The code from 0x68 onwards gets copied to RAM at 0x7000:
- ROM address 0x68 → RAM address 0x7000
- ROM address 0x69 → RAM address 0x7001
- etc.

When analyzing, remember addresses in code comments refer to the **relocated** addresses (0x7000+)

## Step 7: Export Your Work

When you've added more analysis:

1. **File → Export Program**
2. Format: **ASCII**
3. This creates an annotated listing with all your comments

## Ghidra Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `G` | Go to address |
| `L` | Set label |
| `;` | Add EOL comment |
| `/` | Add pre-comment |
| `D` | Disassemble at cursor |
| `C` | Clear code/data at cursor |
| `F` | Create function |
| `Ctrl+E` | Edit function signature |
| `Ctrl+Shift+G` | Find references to... |
| `Ctrl+Shift+E` | Edit program properties |

## Getting Help

Ask me:
- "What does the code at address 0xXXXX do?"
- "Help me understand this subroutine"
- "What are these bytes at 0xXXXX - code or data?"
- "Create a label for this routine"
- "Explain this I/O operation"

I can see your Ghidra window if you share a screenshot!

## Troubleshooting

**Script fails?**
- Make sure auto-analysis finished
- Check Python syntax (Ghidra uses Jython)
- Run from Script Manager, not command line

**Can't find Z80 processor?**
- File → Install Extensions
- Check "Sleigh" if not installed

**Labels not appearing?**
- Window → Symbol Tree
- Verify script ran without errors
- Check Script Console for output
