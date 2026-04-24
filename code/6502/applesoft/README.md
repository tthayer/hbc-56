# Applesoft BASIC for HBC-56

An Applesoft BASIC-compatible interpreter for the HBC-56 homebrew computer.

## Features

### Phase 1 (Core)
- Tokenizer: Parse line numbers, keywords, variables, numbers, strings, operators
- Bytecode interpreter: Execute PRINT, INPUT, LET, GOTO, IF/THEN, FOR/NEXT, GOSUB/RETURN, REM
- 16-bit integer arithmetic
- Basic string support
- Simple graphics (PLOT, COLOR)

### Phase 2 (Graphics & Functions)
- Hi-res graphics driver (TMS9918A native mode)
- Built-in math and string functions
- Advanced control flow (DEF FN, ON/GOTO, ON/GOSUB)

### Phase 3 (Polish)
- Extended compatibility testing
- Documentation
- Optimization

## Building

```bash
cd code/6502/applesoft
make test_hello    # Build and run test_hello.asm in emulator
```

## Test Programs

Pre-compiled test programs in `programs/examples/`:
- `hello.bas` — Simple PRINT example
- `loop.bas` — FOR/NEXT loop
- `graphics.bas` — Graphics demo

## Memory Layout

```
$0000–$00FF    Zero page (variables, state)
$0100–$01FF    Stack
$0200–$7A00    User program + bytecode + strings (≤ 32KB)
```

## Known Limitations

- Integers only (16-bit unsigned); floating-point deferred
- Programs loaded via emulator bytecode loader or ROM pre-load
- TMS9918A graphics mode (not Apple hi-res emulation)
- No arrays, no file I/O, no tape operations
