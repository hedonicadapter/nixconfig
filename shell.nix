{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell { buildInputs = with pkgs; [ python3 python3Packages.img2art ]; }

