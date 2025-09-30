# Justfile for Vial QMK Firmware - Personal Fork
# Quick compilation commands for keyboards in this fork

# Compile Keebio Iris Rev8 with Vial keymap
iris:
    qmk compile -kb keebio/iris/rev8 -km vial

# Compile Lily58 Rev1 with Vial keymap (converted to RP2040)  
lily:
    qmk compile -kb lily58/rev1 -km vial -e CONVERT_TO=rp2040_ce

# Clean build artifacts
clean:
    qmk clean

# List all available recipes
list:
    @just --list