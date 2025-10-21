{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [
    # QMK CLI and Python environment
    qmk
    python3
    python3Packages.pip

    # Build tools
    gnumake
    gcc
    unzip
    wget
    zip
    git

    # AVR cross-compilation tools
    pkgsCross.avr.buildPackages.gcc
    pkgsCross.avr.buildPackages.binutils
    pkgsCross.avr.avrlibc
    avrdude
    dfu-programmer

    # ARM cross-compilation tools
    gcc-arm-embedded
    dfu-util

    # Additional useful tools
    file
    which
  ];

  env = {
    QMK_HOME = "${config.env.DEVENV_ROOT}/qmk_firmware";
  };

  enterShell = ''
    echo "QMK development environment loaded!"
    echo "QMK_HOME is set to: $QMK_HOME"
    echo ""
    echo "Available tools:"
    echo "  - qmk (QMK CLI)"
    echo "  - avr-gcc (AVR cross-compiler)"
    echo "  - arm-none-eabi-gcc (ARM cross-compiler)"
    echo "  - make, gcc, git, and other build tools"
    echo ""
    echo "Run 'qmk setup' to initialize your QMK environment if needed."
  '';
}
