#!/usr/bin/env sh
set -euxo pipefail

mkdir -p build

true "If you don't have cc or objcopy, you can set \`NO_DEBUG_HEADER\` to build without needing these binaries"
if test -z "${NO_DEBUG_HEADER+x}"; then
	cc -c -fno-eliminate-unused-debug-types -O0 -ffreestanding -nostdlib -gdwarf ./debug_headers.c -o build/debug_headers.o
	objcopy --remove-section .note.GNU-stack --remove-section .note.gnu.property --remove-section .comment --remove-section .text --remove-section .data --remove-section .bss build/debug_headers.o
fi

# find is a crappy command, so if -exec fails, it still returns 0
find src/ -name '*.asm' -exec sh -c 'nasm -g -F dwarf -O0 -Isrc/ -w+all -w-reloc -w+error -w-error=user -f elf64 {} -o build/$(basename {} ".asm").o' \;
ld build/*.o -o build/snek
