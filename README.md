# spacelib2

a successor to [spacelib](https://github.com/backwardspy/spacelib) written for kick assembler.

inspired by "Retro Game Dev C64 Edition Volume 2" by Derek Morris.

## usage

open the `spacelib2.code-workspace` in [vscode](https://code.visualstudio.com/).

vscode will recommend you install ["Kick Assembler (C64) for Visual Studio Code" by Paul Hocker](https://marketplace.visualstudio.com/items?itemName=paulhocker.kick-assembler-vscode-ext). install & configure the extension.

now open one of the assembly files (`src/main.asm` is a good starting point) and hit F5 to build and run in VICE.

see `src/memory_map.asm` for binary layout. it also serves as the root of the project and is set as the startup file for the kick assembler extension.
