# Vial QMK Firmware - Personal Fork

[![Current Version](https://img.shields.io/github/tag/qmk/qmk_firmware.svg)](https://github.com/qmk/qmk_firmware/tags)
[![Discord](https://img.shields.io/discord/440868230475677696.svg)](https://discord.gg/qmk)
[![Docs Status](https://img.shields.io/badge/docs-ready-orange.svg)](https://docs.qmk.fm)
[![GitHub contributors](https://img.shields.io/github/contributors/qmk/qmk_firmware.svg)](https://github.com/qmk/qmk_firmware/pulse/monthly)
[![GitHub forks](https://img.shields.io/github/forks/qmk/qmk_firmware.svg?style=social&label=Fork)](https://github.com/qmk/qmk_firmware/)

This is a personal fork of Vial QMK firmware, streamlined to contain only the keyboards I own and use. Based on the [tmk\_keyboard firmware](https://github.com/tmk/tmk_keyboard) with Vial support for real-time keymap editing.

## Quick Build Instructions

### Keebio Iris Rev8 (RP2040)
```bash
# Vial keymap
qmk compile -kb keebio/iris/rev8 -km vial
```

### Lily58 Rev1 (RP2040)
```bash
qmk compile -kb lily58/rev1 -km vial -e CONVERT_TO=rp2040_ce
```

The compiled UF2 files will be created in the root directory and can be flashed directly to your keyboard.

## Documentation

* [See the official documentation on docs.qmk.fm](https://docs.qmk.fm)

## Supported Keyboards in This Fork

This streamlined fork contains only the keyboards I personally own and use:

* **[Keebio Iris Family](/keyboards/keebio/iris/)** - Split ergonomic keyboards
  * [Iris Rev8](/keyboards/keebio/iris/rev8/) - Latest RP2040-based revision

* **[Lily58 Family](/keyboards/lily58/)** - Popular split keyboard
  * [Lily58 Rev1](/keyboards/lily58/rev1/) - Original atmega32u4 version
  * [Other variants](/keyboards/lily58/) - Multiple revisions available

## Official Website

[qmk.fm](https://qmk.fm) is the official website of QMK, where you can find links to this page, the documentation, and the keyboards supported by QMK.
