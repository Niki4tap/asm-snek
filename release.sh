#!/usr/bin/env sh
set -euxo pipefail

# `ld` will probably emit a warning here, and it would be right,
# as we're explicitly disabling mitigations here, but I wouldn't
# expect this silly little game to have a setuid bit on or be used
# in any context where exploitation of it would harm the user

mkdir -p build
# find is a crappy command, so if -exec fails, it still returns 0
find src/ -name '*.asm' -exec sh -c 'nasm -Ox -Isrc/ -Wall -Wno-reloc -Werror -f elf64 {} -o build/$(basename {} ".asm").o' \;
ld -w -s -N build/*.o -o build/snek
