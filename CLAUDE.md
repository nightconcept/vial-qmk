# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal fork of Vial QMK firmware, streamlined to contain only specific keyboards. Vial is a fork of QMK that enables real-time keymap editing through a GUI application. The repository is based on the TMK keyboard firmware with additional Vial support.

**Supported keyboards in this fork:**
- Keebio Iris family (primarily Rev8 with RP2040)
- Lily58 family (primarily Rev1 with RP2040 converter)
- Corne (CRKBD) family (3x6 split keyboard with multiple revisions)

## Build Commands

### Using QMK CLI (Primary Method)

```bash
# Keebio Iris Rev8 with Vial keymap
qmk compile -kb keebio/iris/rev8 -km vial

# Lily58 Rev1 with Vial keymap (converted to RP2040)
qmk compile -kb lily58/rev1 -km vial -e CONVERT_TO=rp2040_ce

# Corne (CRKBD) with Vial keymap (specify revision)
qmk compile -kb crkbd/rev1 -km vial
# or for v4 boards:
qmk compile -kb crkbd/rev4_0/standard -km vial
qmk compile -kb crkbd/rev4_1/standard -km vial
```

The compiled UF2 files are created in the root directory and can be flashed directly to keyboards by dragging them onto the mounted bootloader drive.

### Using Just (Convenience)

```bash
just iris    # Compile Iris Rev8
just lily    # Compile Lily58 Rev1
just clean   # Clean build artifacts
just list    # Show available recipes
```

### Using Make (Alternative)

```bash
# Format: make <keyboard>:<keymap>
make keebio/iris/rev8:vial
make lily58/rev1:vial CONVERT_TO=rp2040_ce
make crkbd/rev1:vial

# Flash directly (requires keyboard in bootloader mode)
make keebio/iris/rev8:vial:flash

# Clean build artifacts
make clean
make distclean  # Also removes *.bin, *.hex, *.uf2 files
```

### Development Environment

This repository uses devenv (Nix-based) for reproducible development environments. The setup includes:
- QMK CLI and Python environment
- AVR cross-compilation toolchain
- ARM cross-compilation toolchain (gcc-arm-embedded)
- Build tools (make, gcc, git)
- Flashing tools (avrdude, dfu-programmer, dfu-util)

To activate: `devenv shell` or use direnv if configured.

## Architecture

### QMK Firmware Structure

QMK follows a layered architecture:

1. **Platform Layer** (`platforms/`): Hardware abstraction for different MCU families (AVR, ChibiOS/ARM, RP2040)
2. **Quantum Layer** (`quantum/`): Core QMK features (keycodes, matrix scanning, RGB, etc.)
3. **Keyboard Layer** (`keyboards/`): Keyboard-specific implementations
4. **Keymap Layer**: User-specific key configurations

### Vial Integration

Vial extends QMK with real-time configuration capabilities:

- **Core Vial code**: `quantum/vial.c`, `quantum/vial.h`
- **RGB integration**: `quantum/vialrgb.c`, `quantum/vialrgb.h` (enables RGB control through Vial GUI)
- **Build system**: `builddefs/build_vial.mk` (handles Vial-specific compilation)
- **Layout definition**: Each Vial keymap requires a `vial.json` file that defines the visual layout for the Vial GUI

### Keyboard Configuration Files

Each keyboard typically has:

- `keyboard.json`: Hardware configuration (matrix pins, features, USB IDs, RGB matrix layout)
- `rules.mk`: Build options and feature flags at keyboard or keymap level
- `config.h`: C preprocessor definitions for the keyboard or keymap
- `keymap.c`: Actual keymap implementation
- `vial.json` (Vial keymaps only): Layout definition for Vial GUI

### MCU Converters

The build system supports converting designs from one MCU to another:
- Located in `platforms/chibios/converters/`
- Example: `CONVERT_TO=rp2040_ce` converts Pro Micro pinout designs to RP2040-CE boards
- Used for Lily58 Rev1 (originally atmega32u4) to run on RP2040 hardware

### Build System Flow

1. Top-level `Makefile` parses the target (`keyboard:keymap:target` format)
2. Includes `builddefs/build_keyboard.mk` for the actual build
3. If `VIAL_ENABLE=yes`, includes `builddefs/build_vial.mk`
4. Vial build generates `vial_generated_keyboard_definition.h` from `vial.json` using `util/vial_generate_definition.py`
5. Platform-specific makefiles handle MCU-specific compilation
6. Output is typically a `.uf2` file for RP2040 keyboards

## Common Patterns

### Enabling Vial Features

In keymap-level `rules.mk`:
```make
VIA_ENABLE = yes          # Required base for Vial
VIAL_ENABLE = yes         # Enable Vial support
VIALRGB_ENABLE = yes      # Enable RGB control in Vial GUI (requires RGB_MATRIX_ENABLE)
QMK_SETTINGS = yes        # Enable advanced QMK settings in Vial
TAP_DANCE_ENABLE = yes    # Enable tap dance
DYNAMIC_MACRO_ENABLE = yes # Enable dynamic macros
```

### Firmware Size Optimization

When approaching size limits:
```make
LTO_ENABLE = yes          # Link-time optimization (most important)
MOUSEKEY_ENABLE = no      # Disable mouse keys if not needed
CONSOLE_ENABLE = no       # Disable debug console
COMMAND_ENABLE = no       # Disable command mode
```

### RGB Configuration

There are two main RGB systems in QMK - they are **mutually exclusive**:

**RGB Matrix** (per-key RGB, used by Iris Rev8):
- More advanced, supports per-key effects and animations
- Configured in `keyboard.json`:
  - `features.rgb_matrix`: Enable the feature
  - `rgb_matrix.driver`: Driver type (usually "ws2812")
  - `rgb_matrix.split_count`: LED counts for split keyboards `[left, right]`
  - `rgb_matrix.layout`: Array of LED positions with matrix coordinates and flags
  - `rgb_matrix.animations`: Enabled animation modes
  - `ws2812.driver` and `ws2812.pin`: LED data pin
- Enable in `rules.mk`: `RGB_MATRIX_ENABLE = yes`
- Vial control: `VIALRGB_ENABLE = yes` (requires RGB_MATRIX_ENABLE)

**RGBLIGHT** (underglow/strip lighting, used by Corne):
- Simpler, treats LEDs as a single strip
- Configured in `keyboard.json`:
  - `features.rgblight`: Enable the feature
  - `rgblight.max_brightness`: Maximum brightness level
- Enable in `rules.mk`: `RGBLIGHT_ENABLE = yes`
- Vial control: Set `"lighting": "qmk_rgblight"` in `vial.json`
- **Cannot be used together with RGB_MATRIX_ENABLE**

## File Locations

- **Keyboard definitions**: `keyboards/<manufacturer>/<model>/`
- **Vial keymaps**: `keyboards/<manufacturer>/<model>/keymaps/vial/`
- **Build outputs**: Root directory (`.uf2`, `.hex`, `.bin` files)
- **Build artifacts**: `.build/` directory
- **Vial core**: `quantum/vial.c`, `quantum/vialrgb.c`
- **Build scripts**: `builddefs/`, `util/`

## Testing Changes

1. Make changes to keyboard configuration or keymap
2. Compile: `qmk compile -kb <keyboard> -km vial` (add `-e CONVERT_TO=rp2040_ce` if needed)
3. Check for errors in the build output
4. Flash the resulting `.uf2` file to the keyboard
5. Test in Vial GUI application (https://get.vial.today/)

## Important Notes

- This fork is intentionally minimal - it only includes keyboards actually owned/used
- **RGB systems are mutually exclusive**:
  - Iris Rev8: Uses RGB Matrix with `VIALRGB_ENABLE` for per-key control
  - Corne: Uses RGBLIGHT with `"lighting": "qmk_rgblight"` in vial.json
  - Cannot enable both `RGB_MATRIX_ENABLE` and `RGBLIGHT_ENABLE` simultaneously
- Lily58 Rev1 requires the RP2040 converter flag (`CONVERT_TO=rp2040_ce`) for the hardware being used
- Vial keymaps must have a `vial.json` file or compilation will fail
- The serial number in `builddefs/build_vial.mk` identifies this Vial build
- When adding new Vial keymaps, always create the `vial.json` layout definition first
- Corne has multiple revisions (rev1, rev4_0, rev4_1, r2g) - specify the correct one when building
