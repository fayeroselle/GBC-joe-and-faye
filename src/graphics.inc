; 
; CS 240  
;
; @file graphics.inc
; @author Joe Buttarazzi and Faye Roselle
; @date April 29th, 2025 
; @brief macros to initialize and update/store the state of the graphics
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
; 
; build with: 
; make 
;  
include "src/wram.inc"
include "src/utils.inc"
include "src/hardware.inc"

def TILES_COUNT                     equ (384)
def BYTES_PER_TILE                  equ (16)
def TILES_BYTE_SIZE                 equ (TILES_COUNT * BYTES_PER_TILE)

def TILEMAPS_COUNT                  equ (1)
def BYTES_PER_TILEMAP               equ (1024)
def TILEMAPS_BYTE_SIZE              equ (TILEMAPS_COUNT * BYTES_PER_TILEMAP)

def GRAPHICS_DATA_SIZE              equ (TILES_BYTE_SIZE + TILEMAPS_BYTE_SIZE)
def GRAPHICS_DATA_ADDRESS_END       equ ($4000)
def GRAPHICS_DATA_ADDRESS_START     equ (GRAPHICS_DATA_ADDRESS_END - GRAPHICS_DATA_SIZE)

def PLAYER_SPRITE         equ _OAMRAM
def PLAYER_SPRITE_RIGHT   equ _OAMRAM + 4
def NPC                   equ _OAMRAM + 8
def NPC2                  equ _OAMRAM + 12
def PLAYER_START_X        equ 85
def NPC_START_X           equ 20
def NPC2_START_X          equ 0
def PLAYER_START_Y        equ 90
def NPC_START_Y           equ 46
def NPC2_START_Y          equ 0
def PLAYER_NEUTRAL_TILEID equ 0
def OAMA_NO_FLAGS         equ 0
def DEFAULT_PAL           equ %11100100
def ALT_PAL               equ %00011011
def BG_START_X            equ 35
def BG_START_Y            equ 75
def WIN_START_X           equ 7
def WIN_START_Y           equ 0
def X_ADJUST              equ 8
def LEFT_MAIN_ID          equ 0
def RIGHT_MAIN_ID         equ 2
def NPC_ID                equ 33
def NPC2_ID               equ 36
def NPC_ID2               equ 34

def END_MESSAGE          equ 49
def NEW_LINE             equ 48
def TILE_OFFSET          equ $41
def LETTER_CONVERT       equ 65
def VRAM_LINE2           equ $20
def VRAM_LINE1           equ $9C00
def CLUE_WIN_UP          equ 127
def CLUE_WIN_DOWN        equ 144
def CLUE1_X              equ 6
def CLUE1_Y              equ 17
def CLUE1                equ $0000
def CLUE2_X              equ 6
def CLUE2_Y              equ 2
def CLUE2                equ $1000
def GAME_OVER_MESSAGE    equ $1100
def MAIN_START_X         equ 120
def MAIN_START_Y         equ 165
def TILE                 equ 8
def INVERTED_BGP         equ %11111111  
def DEFAULT_BGP          equ $E4

def HOUSE4_X             equ 29
def HOUSE4_Y             equ 21
def HOUSE4_BIT           equ %00010000
def TREASURE_Y           equ 25
def TREASURE_BIT         equ %01000000
def HOUSE3_X             equ 24
def HOUSE3_Y             equ 12
def HOUSE3_BIT           equ %00001000
def HOUSE2_X             equ 27
def HOUSE2_Y             equ 2
def HOUSE2_BIT           equ %00000100
def MID_X                equ 28
def HOUSE1_X             equ 6
def MID_Y                equ 19
def HOUSE1_BIT           equ %00000001
def SIGN_BIT             equ %00000010
def MANSION_Y            equ 28
def MANSION_BIT          equ %00100000
def SPLIT_X              equ 15
def NPC2_X               equ 80
def NPC2_Y               equ 75
def FLASH_COUNTER        equ 8
def HOUSE1_MESSAGE       equ $0000
def HOUSE2_MESSAGE       equ $1000
def WIN_MESSAGE          equ $1100
def HOUSE3_MESSAGE       equ $1200
def HOUSE4_MESSAGE       equ $1300
def HOUSE5_MESSAGE       equ $1400
def HOUSE6_MESSAGE       equ $1500
def HOUSE7_MESSAGE       equ $1600
def LOSE_MESSAGE         equ $1700
def LEVEL2_MESSAGE       equ $1800
def HOUSE1_VAL           equ 1
def HOUSE2_VAL           equ 2
def HOUSE3_VAL           equ 4
def HOUSE4_VAL           equ 8
def HOUSE5_VAL           equ 16
def HOUSE6_VAL           equ 32
def HOUSE7_VAL           equ 64
def WRONG_HOUSES         equ %00110101
def FRAMES_PER_SECOND    equ 60
def SECONDS              equ 60




if !def(GRAPHICS_RGBINC)
def GRAPHICS_RGBINC equ 1

macro DisableLCD
    ; wait for the vblank
    .wait_vblank\@
        ld a, [rLY]
        cp a, SCRN_Y
        jr nz, .wait_vblank\@

    ; turn the LCD off
    xor a
    ld [rLCDC], a
endm

macro EnableLCD
    ; set the graphics parameters and turn back LCD on
    ld a, LCDCF_ON LCDCF_BG9800 | LCDCF_BGON | LCDF_8000
    ld [rLCDC], a

endm

;move main character back
macro move_back
    ld a, [MAIN_CHAR_Y]
    add a, TILE
    ld [MAIN_CHAR_Y], a
    ld a, [rSCY]
    add a, TILE
    ld [rSCY], a 
endm

macro init_sprite_data
    ;initialize the main characters x coordinate
    push af
    push bc
    ld a, [rSCX]
    ld b, a
    ld a, PLAYER_START_X
    add a, b
    ld [MAIN_CHAR_X], a
    ;initialize the main characters y coordinate
    ld a, [rSCY]
    ld b, a
    ld a, PLAYER_START_Y
    add a, b
    ld [MAIN_CHAR_Y], a

    ;initialize the npcs x coordinate
    ld a, [rSCX]
    ld b, a
    ld a, NPC_START_X
    add a, b
    ld [NPC_X], a

    ;initialize the npcs y coordinate
    ld a, [rSCY]
    ld b, a
    ld a, NPC_START_Y
    add a, b
    ld [NPC_Y], a

    pop bc 
    pop af

endm

macro div_by8
    srl a
    srl a
    srl a
endm

macro set_house_checker
    ld a, 0
    ld [HOUSE_CHECKER], a
endm
endc