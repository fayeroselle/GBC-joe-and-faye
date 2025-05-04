;
; CS-240 World 8
;
; @file sample.asm
; @author Faye Roselle, Joe Buttarazzi
; @date April 29, 2025
; @brief function and macros for checking guesses and houses
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
;
; build with: 
; make

include "src/utils.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "player", rom0

make_sound: 
    Copy [rNR10], $00
    Copy [rNR11], $80
    Copy [rNR12], $F3
    Copy [rNR13], $C1
    Copy [rNR14], $87

check_outer_right:
    ;determine if the players x coordinate is the same as house 4/treasure
    cp a, HOUSE4_X
    jr nz, .end
        ld a, [MAIN_CHAR_Y]
        div_by8
        cp a, HOUSE4_Y
        ;determine if the player is at house 4
        jr nz, .other_house
            ld a, 5     
            ld [HOUSE_CHECKER], a
        .other_house
        cp a, TREASURE_Y
        ;determine if the player is at the treasure chest
        jr nz, .end
            ld a, 7    
            ld [HOUSE_CHECKER], a
    .end
    ret

check_inner_right:
    ;check if player is at house 3's x coordinate
    cp a, HOUSE3_X
    jr nz, .other_house
        ld a, [MAIN_CHAR_Y]
        div_by8
        cp a, HOUSE3_Y
        ;check if player is at house 3
        jr nz, .end
            ld a, 4   
            ld [HOUSE_CHECKER], a
    .other_house
    ;check if player is at house 2's x coordinate
    cp a, HOUSE2_X
    jr nz, .end
        ld a, [MAIN_CHAR_Y]
        div_by8
        ;check if player is at house 2
        cp a, HOUSE2_Y
        jr nz, .end
            ld a, 3      
            ld [HOUSE_CHECKER], a
    .end
    ret

check_right_map:
    ;check if the player could be at clue locations on the left or right side of the map
    cp a, MID_X
    jr nc, .outer_right
    call check_inner_right
    jr .end
    .outer_right
    call check_outer_right
    .end
    ret

check_beg_houses:
    cp a, CLUE1_Y
    ;determine if the player is at the first house
    jr nz, .second_house 
        ld a, 1       
        ld [HOUSE_CHECKER], a
    .second_house
    cp a, CLUE2_Y
    ;determine if the player is at the sign
    jr nz, .end
        ld a, 2 
        ld [HOUSE_CHECKER], a
    .end
    ret

check_left_map:
    cp a, HOUSE1_X
    jr nz, .end
        ld a, [MAIN_CHAR_Y]
        div_by8
        cp a, MID_Y
        jr nc, .check_mansion
            ;check if player is at first 2 clue location
            call check_beg_houses
        .check_mansion
        cp a, MANSION_Y
        ;check if player is at mansion
        jr nz, .end
            ld a, 6    ;MANSION_BIT
            ld [HOUSE_CHECKER], a
    .end
    ret

check_location: 
    ld a, [MAIN_CHAR_X]
    div_by8
    ;detemine if player is on left or right side of map
    cp a, SPLIT_X
    jr nc, .check_right
    call check_left_map
    .check_right
    call check_right_map
    .end
    ret

house1_clue:
    ld hl, HOUSE1_MESSAGE
    call message_process
    ret
    
house2_clue:
    ld hl, HOUSE2_MESSAGE
    call message_process
    ret

house3_clue:
    ld hl, HOUSE3_MESSAGE
    call message_process
    ret

house4_clue:
    ld hl, HOUSE4_MESSAGE
    call message_process
    ret

house5_clue:
    ld hl, HOUSE5_MESSAGE
    call message_process
    ret

house6_clue:
    ld hl, HOUSE6_MESSAGE
    call message_process
    ret

house7_clue:
    ld hl, HOUSE7_MESSAGE
    call message_process
    ret

macro CallHL    
    ld de, .call_return_address\@
    push de
    jp hl
    .call_return_address\@
endm

UpdateFuncTable:
    dw house1_clue
    dw house2_clue
    dw house3_clue
    dw house4_clue
    dw house5_clue
    dw house6_clue
    dw house7_clue

determine_house:
    halt
    ld a, [HOUSE_CHECKER]
    dec a
    ld d, 0
    ld e, a
    ld hl, UpdateFuncTable
    add hl, de
    add hl, de
    ; unpack the function address and call it
    ld a, [hli]
    ld h, [hl]
    ld l, a
    CallHL
    ret

determine_guess:
    ld b, 0
    cp a, 4     ;HOUSE4_VAL
    jr nz, .wrong_houses
        ld hl, WIN_MESSAGE
        call write_message
        call display_message
        call girl_appear 
        call end_wait
        inc b
    jr .end
    .wrong_houses
        and a, WRONG_HOUSES
        jr z, .end
        ld hl, LOSE_MESSAGE
        call write_message
        call display_message
        call flash_bg 
        call end_wait
        inc b
    .end 
    ret

check_end: 
    ;check if start is being pressed
    ld b, 0
    ld a, [PAD_CURR]      
    bit PADB_START, a
    jr nz, .end
        ;check if select is being pressed
        bit PADB_SELECT, a
        jr nz, .end
            inc b
            ld hl, LEVEL2_MESSAGE
            call write_message
            call display_message
    .end
    call girl_removed
    ret

end_wait:
    .wait_for_end:
        UpdateJoypad     
        ld a, [PAD_CURR]      
        bit PADB_B, a
        jr nz, .wait_for_end
    call remove_message
    ret
  
reset_game: 
    ;reset the main characters position
    ld a, MAIN_START_X
    ld [MAIN_CHAR_X], a
    ld a, MAIN_START_Y
    ld [MAIN_CHAR_Y], a

    ;reset the background position
    ld a, BG_START_X
    ld [rSCX], a
    ld a, BG_START_Y
    ld [rSCY], a

    ;reset the npc's y coordinate
    ld a, [NPC_Y]
    ld b, a
    ld a, [rSCY]
    sub a, b
    ld [NPC + OAMA_Y], a

    ;reset the npc's x coordinate
    ld a, [NPC_X]
    ld b, a
    ld a, [rSCX]
    sub a, b
    ld [NPC + OAMA_X], a

    ld a, 0
    ld [FRAME_COUNTER], a
    ld [SECOND_COUNTER], a
    ret

second_checker: 
    ; Increment frame counter
    ld b, 0
    ld a, [FRAME_COUNTER]
    inc a
    ld [FRAME_COUNTER], a

    ; Check if 60 frames have passed 
    cp a, FRAMES_PER_SECOND
    jr nz, .done
    xor a                
    ld [FRAME_COUNTER], a

    ; Increment seconds
    ld a, [SECOND_COUNTER]
    inc a
    ld [SECOND_COUNTER], a
    cp a, SECONDS
    jr nz, .done
    inc b

    .done
    ret

time_up:
    ld hl, $1900
    call write_message
    call display_message
    call end_wait
    ;call message_process
    call reset_game
    ret
 

; load the graphics data from ROM to VRAM
macro LoadGraphicsDataIntoVRAM
    ld de, tileset
    ld hl, _VRAM8000
    .load_tile\@
        ld a, [de]
        inc de
        ld [hli], a
        ld a, e
        cp a, low(tileset_end)
        jr nz, .load_tile\@
        ld a, d
        cp a, high(tileset_end)
        jr nz, .load_tile\@


    ;Copy [rVBK], 1
    ;ld de, tileset
    ;ld hl, _VRAM8000
    ;.load_tile1\@
        ;ld a, [de]
        ;inc de
        ;ld [hli], a
        ;ld a, d
        ;cp a, high(tileset_end)
        ;jr nz, .load_tile1\@
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

LoadTilesBank0:
    ld hl, tileset          ; ROM source for tile graphics
    ld de, _VRAM8000        ; destination in VRAM bank 0
    ld bc, TILES_BYTE_SIZE   ; total bytes to copy
    Copy [rVBK], 0           ; select VRAM bank 0
    
    .copy_tiles0
        ld a, [hl]               ; load byte from ROM
        ld [de], a               ; write to VRAM
        inc hl
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .copy_tiles0
    ret

LoadTilesBank1:
    ld hl, tileset      ; ROM source for tile attributes
    ld de, _VRAM8800         ; destination in VRAM bank 1
    ld bc, TILES_BYTE_SIZE    ; total attribute bytes (same as tile count)
    Copy [rVBK], 1           ; select VRAM bank 1
    
    .copy_tiles1
        ld a, [hl]               ; load attribute byte
        ld [de], a               ; write to VRAM bank 1
        inc hl
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .copy_tiles1
    ret


section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]

tileset:
incbin "assets/ship.chr"
tileset_end:


palette_data:
incbin "assets/ship.pal"
palette_data_end:

background_indices:
incbin "assets/ship.idx"
background_indices_end:

background_parameters:
incbin "assets/ship.prm"
background_parameters_end:

;window_indices:
;incbin "assets/new_window.idx"
;window_indices_end:

;window_parameters:
;incbin "assets/new_window.prm"
;window_parameters_end:

init_graphics:
    ;InitOAM
    ;call LoadTilesBank0
    ;call LoadTilesBank1

    Copy [rBCPS], 0 | BCPSF_AUTOINC
    ld hl, palette_data
    ld c, palette_data_end - palette_data
    .palette_copy
        Copy [rBCPD], [hli]
        dec c
        jr nz, .palette_copy

    InitOAM
    LoadGraphicsDataIntoVRAM

    ;Copy [rVBK], 0
    ;ld de, $000
    ;ld hl, tileset
    ;.tileset_copy
        ;Copy [de], [hli]
        ;inc de
        ;ld a, l
        ;cp a, low(tileset_end)
        ;ld a, h
        ;jr nz, .tilemap_indices_copy
        ;cp a, high(tileset_end)
        ;jr nz, .tileset_copy

    Copy [rVBK], 0
    ld de, _SCRN0
    ld hl, background_indices
    .tilemap_indices_copy
        Copy [de], [hli]
        inc de
        ld a, l
        cp a, low(background_indices_end)
        jr nz, .tilemap_indices_copy
        ld a, h
        cp a, high(background_indices_end)
        jr nz, .tilemap_indices_copy

    
    Copy [rVBK], 1
    ld de, _SCRN0
    ld hl, background_parameters
    .tilemap_parameters_copy
        Copy [de], [hli]
        inc de
        ld a, l
        cp a, low(background_parameters_end)
        jr nz, .tilemap_parameters_copy
        ld a, h
        cp a, high(background_parameters_end)
        jr nz, .tilemap_parameters_copy
       

    ;Copy [rVBK], 0
    ;ld hl, window_indices
    ;ld de, $9C00
    ;.window_indices_copy
        ;Copy [de], [hli]
        ;inc de
        ;ld a, l
        ;cp a, low(window_indices_end)
        ;ld a, h
        ;jr nz, .window_indices_copy
        ;cp a, high(window_indices_end)
        ;jr nz, .window_indices_copy

    ;Copy [rVBK], 1
    ;ld de, $9C00
    ;ld hl, window_parameters
    ;.window_parameters_copy
        ;Copy [de], [hli]
        ;inc de
        ;ld a, l
        ;cp a, low(window_parameters_end)
        ;ld a, h
        ;jr nz, .window_parameters_copy
        ;cp a, high(window_parameters_end)
        ;jr nz, .window_parameters_copy
    ret

export check_location, check_end, end_wait, reset_game, check_left_map
export check_beg_houses, check_right_map, check_inner_right, check_outer_right, determine_house
export determine_guess, second_checker, time_up, make_sound, init_graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
