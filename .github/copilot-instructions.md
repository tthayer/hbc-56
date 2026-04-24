# HBC-56 Copilot Instructions

HBC-56 is a homebrew 8-bit computer built around the 65C02 CPU on a 56-pin backplane. This repo contains two major components: a **C/C++ desktop emulator** (with SDL2 + Dear ImGui) and **6502 assembly source code** for the machine. Always clone with `--recurse-submodules` — the modules directory contains vendored chip emulators as git submodules.

## Build: Emulator

First, ensure submodules are initialized:
```sh
git submodule update --init --recursive
```

Then build:
```sh
# Configure and build (Release)
cmake -B build -DCMAKE_BUILD_TYPE=Release -S .
cmake --build build --config Release
# Output: build/bin/Hbc56Emu (Linux/macOS) or build/bin/Hbc56Emu.exe (Windows)
```

**Note for macOS:** The SDL2 build works correctly; some Objective-C code will produce warnings about declaration-after-statement, but these are harmless and do not affect the build.

### WebAssembly build

```sh
# Linux
./emconfigure.sh build_wasm
cmake --build build_wasm --config Release
# Serve: cd build_wasm/bin && python -m http.server
```

## Build: 6502 Assembly

Assembly is built with the ACME assembler (built as part of the CMake build) and GNU Make.

```sh
# Build and launch a specific program in the emulator
cd code/6502/invaders
make invaders            # build + run
make invaders.o          # assemble only

# Build and run all demos in a directory
make all
```

Each `make` target produces three files: `<name>.o` (binary ROM), `<name>.o.lmap` (label map), `<name>.o.rpt` (ACME report for source debugging). The emulator auto-loads `.lmap` and `.rpt` if present alongside the `.o` file.

## Architecture

### Emulator (`emulator/`)

- **`src/hbc56emu.cpp`** — main entry point; owns the device array and the SDL2/ImGui event loop
- **`src/devices/`** — one `.c`/`.h` pair per hardware chip (`6502_device`, `tms9918_device`, `ay38910_device`, `lcd_device`, `keyboard_device`, `nes_device`, `uart_device`, `via_device`, `memory_device`)
- **`src/devices/device.h`** — the core device abstraction: an `HBC56Device` struct holding function pointers (`tickFn`, `readFn`, `writeFn`, `renderFn`, `audioFn`, `eventFn`) and a `void* data` for private state. All devices implement this interface.
- **`modules/`** — vendored chip emulator libraries as CMake subprojects: `65c02`, `65c22`, `tms9918`, `ay38910`, `lcd`
- **`thirdparty/`** — SDL2, Dear ImGui, ImGui-Addons
- The WebAssembly build (`EMSCRIPTEN` defined) disables shared libraries, uses `-s USE_SDL=2`, and exports a fixed set of C functions called from `wasm/hbc56-frontend.js`

### 6502 Assembly (`code/6502/`)

```
code/6502/
├── lib/          # Shared library includes (.asm / .inc per subsystem)
│   ├── hbc56.inc / hbc56.asm   # IO base addresses, vectors, delay routines
│   ├── gfx/      # TMS9918 driver, tilemap, bitmap, fonts
│   ├── sfx/      # AY-3-8910 sound driver
│   ├── inp/      # NES controller, PS/2 keyboard
│   ├── lcd/      # Character/graphics LCD driver
│   ├── ser/      # UART driver
│   └── ut/       # Math, memory utilities
├── kernel/       # HBC-56 kernel ROM (assembled to kernel.o)
│   ├── kernel.asm          # Kernel entry point
│   ├── hbc56kernel.inc     # Include this in user programs that use the kernel
│   └── kernel.inc          # Kernel macros (setIntHandler, setNmiHandler, vsync callback, etc.)
├── basic/        # Enhanced BASIC interpreter
├── invaders/     # Space Invaders demo
├── qbert/        # Q*bert demo
├── tests/        # Hardware tests (tms/, sfx/, inp/, lcd/, io/)
└── makefile      # Shared makefile included by all project makefiles
```

User programs include `hbc56kernel.inc` to pull in the kernel ROM image and set up the 65C02 vectors. Programs that exclude the kernel (e.g., bare-metal tests) define `HBC_56_EXCLUDE_KERNEL_ROM` and link at `$0400`.

## Memory Map

| Range | Purpose |
|---|---|
| `$0000`–`$00ff` | Zero page |
| `$0100`–`$01ff` | Stack |
| `$0200`–`$79ff` | User RAM |
| `$7a00`–`$7eff` | Kernel RAM |
| `$7f00`–`$7fff` | I/O ports |
| `$8000`–`$dfff` | User ROM |
| `$e000`–`$ffff` | Kernel ROM |

Key I/O addresses (all `$7fxx`): TMS9918A at `$10`/`$11`, AY-3-8910 A at `$40`–`$42`, AY-3-8910 B at `$44`–`$46`, PS/2 keyboard at `$80`/`$81`, NES controllers at `$82`/`$83`, 65C22 VIA at `$f0`–`$ff`.

## Key Conventions

### ACME assembler syntax
- CPU target declared at top of each file: `!cpu w65c02`
- Memory fill: `!initmem $FF`
- Includes: `!src "file.asm"` / `!src "file.inc"` (`.asm` for code, `.inc` for macros/constants)
- Macros: `!macro myMacro .param { ... }` — parameters are prefixed with `.`
- Anonymous forward/backward branch labels: `+` and `-` (ACME convention)
- Conditional defines: `!ifdef SYMBOL { ... } else { ... }`
- Set origin: `*=$address`
- Emit bytes/words: `!byte $xx`, `!word $xxxx`, `!bin "file"`, `!text "string"`

### Project makefiles
Each project has its own `makefile` that sets `ROOT_PATH` and `DISABLE_KERNEL_MODULES` then includes `code/6502/makefile`. The shared makefile provides the `%.o` pattern rule (assemble) and the `kernel` dependency. Disabling a module (e.g., `DISABLE_KERNEL_MODULES = LCD`) passes `-DHBC56_DISABLE_LCD=1` to ACME and avoids including that driver.

### Emulator device pattern
Each device is created with `createDevice("name")` and then its function-pointer fields are populated. Devices are added to the global `devices[]` array. The main loop calls `tickDevice`, `readDevice`/`writeDevice` (routed by address range), `renderDevice`, and `renderAudioDevice` on every device that implements them.

### Emulator command-line
```sh
./build/bin/Hbc56Emu --rom <file.o> [--keyboard] [--brk] [--lcd 12864|1602|2004]
```
- The ROM binary must be exactly 32 KB
- `--brk` starts the debugger paused at the first instruction
- Inserting opcode `$db` in assembly code triggers a breakpoint in the emulator

### VSCode (code/6502/)
- **Ctrl+F5** — assemble and run the currently open `.asm` file
- **Ctrl+Shift+B** — assemble only (no run)
