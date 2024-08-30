# My dotfiles

This repository consists of my dotfiles and other config files alongside a program that automatically
links them to their locations.

## Subdirectories

* `./home` -> `$1` of the script `link.sh` (required argument, use your `$HOME` before running with sudo)
* `./root` -> `$2` of the script `link.sh` (optional argument, default: `/`)

## Dependencies

* Nim
  * gcc (or another C compiler)
* Bash
