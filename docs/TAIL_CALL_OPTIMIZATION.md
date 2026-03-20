# Tail Call Fall-Through Optimization

## Strategy
When a function ends with `jp _target` (tail call), placing `_target` immediately
after in the binary allows the `jp` to be eliminated (fall-through). This saves
3 bytes per eliminated jump.

## How to apply
- Identify `jp _target` at end of function (sdcc generates these for tail calls)
- Move `_target` function definition to right after the caller in the C source
- Add forward declaration if needed (other callers defined before the moved function)

## Solution: comment-aware peephole rules
sdcc inserts function separator comments between functions:
```
	jp	_cursor_right
;	---------------------------------
; Function cursor_right
; ---------------------------------
_cursor_right:
```
Fixed by adding peephole rules that match 1-3 comment lines using `;%N` patterns:
```
	jp	%1
;%2
;%3
;%4
%1:
=
;%2
;%3
;%4
%1:
```
**No underscore prefix needed**: `jp %1` won't match conditional jumps like
`jp Z,_foo` because `%1` captures to end-of-line, and no label `Z,_foo:` exists.
Conditional jumps contain a comma, which is not valid in labels, so they
naturally don't match the `%1:` line.

## Highest-value targets (by call frequency)
- `_cursorxy`: 9 tail calls from cursor_right, cursor_left, cursor_down, cursor_up, etc.
- `_rwoper`: 3 tail calls from xread, xwrite
- `_cursor_right`: 2 tail calls from displ, specc
- `_bg_clear_from`: 2 tail calls from erase_to_eol, erase_to_eos

## Note
Even when the peephole limitation is fixed, only ONE caller per function can
benefit from fall-through (the one immediately before). Prioritize the most
frequently executed code path.
