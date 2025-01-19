#!/usr/bin/env sh
set -euxo pipefail

# this doesn't really work anymore since we make heavy use of nasm preprocessor
# which has a lot of features restricted in preprocessor-only mode (weird)
# so it cannot preprocess-only most of the code

mkdir -p build
# find is a crappy command, so if -exec fails, it still returns 0
find src/ -name '*.asm' -exec sh -c 'nasm --keep-all -E -Isrc/ {} -o build/$(basename {} ".asm").asm' \;
