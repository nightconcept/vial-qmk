{
  description = "QMK/Vial firmware development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
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

          QMK_HOME = "${toString ./.}/qmk_firmware";

          shellHook = ''
            echo "QMK development environment loaded!"
            echo "QMK_HOME is set to: $QMK_HOME"
            echo ""

            # Check if submodules are initialized
            if [ ! -f "lib/chibios/readme.txt" ]; then
              echo "⚠️  Git submodules not initialized. Running 'qmk setup'..."
              echo ""
              qmk setup -y
            else
              echo "✓ Git submodules are initialized"
            fi
          '';
        };
      }
    );
}
