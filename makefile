
.PHONY: all

all: game.gbc

game.gbc: build build/sample.o build/main.o build/graphics.o build/player.o
	rgblink --tiny --map game.map --sym game.sym -o game.gbc build/main.o build/sample.o build/graphics.o build/player.o
	rgbfix --title game --color-only --pad-value 0 --validate game.gbc

build:
	mkdir build

build/sample.o: build src/sample.asm src/hardware.inc src/utils.inc assets/*.tlm assets/*.chr
	rgbasm -o build/sample.o src/sample.asm

build/graphics.o: build src/graphics.asm src/hardware.inc src/utils.inc
	rgbasm -o build/graphics.o src/graphics.asm

build/player.o: build src/player.asm src/hardware.inc src/utils.inc
	rgbasm -o build/player.o src/player.asm

build/main.o: build src/main.asm src/hardware.inc assets/*.chr assets/*.pal assets/*.idx assets/*.prm assets/*.tlm
	rgbasm -o build/main.o src/main.asm
