;
; CS-240 World 8
;
; @file graphics.asm
; @author Faye Roselle, Joe Buttarazzi 
; @date April 29, 2025
; @brief Functions and Macros for Graphics 
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
; 
; build with:
; make

include "src/utils.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"


section "newgraphics", rom0

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, GRAPHICS_DATA_ADDRESS_START
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, d
        cp a, high(GRAPHICS_DATA_ADDRESS_END)
        jr nz, .load_tile\@
endm

;clear oam
macro InitOAM
    ld c, OAM_COUNT
    ld hl, _OAMRAM + OAMA_Y
    ld de, sizeof_OAM_ATTRS
    .init_oam\@
        ld [hl], 0
        add hl, de
        dec c
        jr nz, .init_oam\@
endm

init_graphics2:
    ; init the palettes
    ld a, DEFAULT_PAL
    ld [rBGP], a
    ld [rOBP0], a
    ld a, ALT_PAL
    ld [rOBP1], a

    ; init graphics data
    InitOAM
    LoadGraphicsDataIntoVRAM

    ; init the sound
    Copy [rNR52], AUDENA_ON
    Copy [rNR50], $77
    Copy [rNR51], $FF

    ; enable the vblank interrupt
    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; place the window at the bottom of the LCD
    ld a, WIN_START_X
    ld [rWX], a
    ld a, WIN_START_Y
    ld [rWY], a

    ; set the background position
    ld a, BG_START_X
    ld [rSCX], a
    ld a, BG_START_Y
    ld [rSCY], a

    ld a, 0
    ld [HOUSE_CHECKER], a
    ld [FRAME_COUNTER], a
    ld [SECOND_COUNTER], a
    ret
  
    
write_message:  
    ; Loop until we hit the null terminator
    ld de, VRAM_LINE1
    .loop
        ld a, [hl]         
        cp a, END_MESSAGE
        jr z, .end  
        ;check for new line
        cp a, NEW_LINE
        jr z, .new_line
            ;convert to letter tile
            sub a, LETTER_CONVERT          
            add a, TILE_OFFSET
            ld [de], a       
            inc hl            
            inc de              
            jr .loop
        ;start writing on new line
        .new_line
        ld a, VRAM_LINE2
        ld e, a
        inc hl
        jr .loop
    .end
    ret

display_message: 
    ld a, CLUE_WIN_UP 
    ld [rWY], a
    ret

remove_message:
    ld a, CLUE_WIN_DOWN
    ld [rWY], a
    ret

message_process:
    call make_sound 
    call write_message
    call display_message
    .wait_for_start:
        UpdateJoypad     
        ld a, [PAD_CURR]      
        bit PADB_A, a
        jr nz, .wait_for_start
        call remove_message
        ;move the main character back and allow him to search again
        move_back
    ret

girl_appear: 
    Copy [NPC2 + OAMA_X], NPC2_X
    Copy [NPC2 + OAMA_Y], NPC2_Y
    ret 
    
girl_removed: 
    Copy [NPC2 + OAMA_X], NPC2_START_X
    Copy [NPC2 + OAMA_Y], NPC2_START_Y
    ret 
    
flash_bg:
    ld b, FLASH_COUNTER          
    .loop:
        ; Set inverted palette
        ld a, INVERTED_BGP
        ld [rBGP], a
        halt
        halt 
        ; Set back to normal
        ld a, DEFAULT_BGP
        ld [rBGP], a
        halt
        halt
        dec b
        jr nz, .loop
    ret

export write_message, display_message, remove_message, message_process, girl_appear, girl_removed
export flash_bg, init_graphics