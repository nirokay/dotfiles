#!/usr/bin/env bash

nim c link.nim &> compile.log

[ -f "link" ] && sudo ./link $*
[ ! -f "link" ] && echo -e "Binary could not be found..."

