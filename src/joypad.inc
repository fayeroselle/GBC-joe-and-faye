; 
; CS 240 
;
; @file joypad.inc
; @author Joe Buttarazzi and Faye Roselle
; @date April 29th, 2025
; @brief macros to initialize and update/store the state of the joypad
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
;
; build with:  
; make
;

if !def(JOYPAD_RGBINC)
def JOYPAD_RGBINC equ 1

include "src/wram.inc"
include "src/utils.inc"
include "src/hardware.inc"

def NONE_HELD equ $FF

; initialize stored joypad buttons to so that
; none of them are initially detected as held
macro InitJoypad
    ld a, NONE_HELD
    ld [PAD_CURR], a
    ld [PAD_PREV], a
    ld [PAD_RLSE], a
    ld [PAD_PRSS], a
endm

macro UpdateJoypad
    ; store the previous input into the struct and (c)
    ld a, [PAD_CURR]
    ld [PAD_PREV], a
    ld c, a

    ; read the dpad
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]

    ; put the dpad input into (b)'s high nibble
    swap a
    and a, $F0
    ld b, a

    ; read the buttons
    ld a, P1F_GET_BTN
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]

    ; merge the buttons' input into (b)'s low nibble
    and a, $0F
    or a, b
    ld b, a

    ; store the current input
    ld [PAD_CURR], a

    ; disable input polling
    ld a, P1F_GET_NONE
    ldh [rP1], a

    ; compute and store pressed buttons
    ld a, c
    cpl
    or a, b
    ld [PAD_PRSS], a

    ; compute and store released buttons
    ld a, b
    cpl
    or a, c
    ld [PAD_RLSE], a
endm

macro MoveSpriteRight
    inc c 
    ld a, c 

    ; Timing Sprite Animations  
    cp a, 8
    jr c, .og_sprite_right 

    ; New Sprite
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 22
    Copy [PLAYER_SPRITE + OAMA_TILEID], 20
    jr .check_right 

    .og_sprite_right
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 18
    Copy [PLAYER_SPRITE + OAMA_TILEID], 16 

    .check_right 
    ld  a, c
    cp a, 16
    jr c, .done_right     
        ld c, 0          
    .done_right  

    ;keep NPCs global position the same
    ld a, [rSCX]
    ld b, a
    ld a, [NPC_X]
    dec a
    sub a, b
    ld [NPC + OAMA_X], a

    ;update main characters global position
    ld a, [MAIN_CHAR_X]
    inc a
    ld [MAIN_CHAR_X], a

    ;update screen position
    ld a, [rSCX]
    inc a 
    ld [rSCX], a 
endm

macro MoveSpriteLeft
    inc c 
    ld a, c 

    ; Timing Sprite Animations
    cp a, 8
    jr c, .og_sprite_left 

    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 30
    Copy [PLAYER_SPRITE + OAMA_TILEID], 28
    jr .check_left 

    .og_sprite_left
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 26
    Copy [PLAYER_SPRITE + OAMA_TILEID], 24 

    .check_left 
    ld  a, c
    cp a, 16
    jr c, .done_left     
        ld c, 0          
    .done_left

    ;keep NPCs global position the same
    ld a, [rSCX]
    ld b, a
    ld a, [NPC_X]
    inc a
    sub a, b
    ld [NPC + OAMA_X], a

    ;update main characters global position
    ld a, [MAIN_CHAR_X]
    dec a
    ld [MAIN_CHAR_X], a

    ;update screen position
    ld a, [rSCX]
    dec a 
    ld [rSCX], a 
endm

macro MoveSpriteUp
    inc c 
    ld a, c 

    ; Timing Sprite Animations
    cp a, 8
    jr c, .og_sprite_up 

    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 14
    Copy [PLAYER_SPRITE + OAMA_TILEID], 12
    jr .check_up 

    .og_sprite_up
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 10
    Copy [PLAYER_SPRITE + OAMA_TILEID], 8 
    
    .check_up 
    ld  a, c
    cp a, 16
    jr c, .done_up     
        ld c, 0          
    .done_up

    ;keep NPCs global position the same
    ld a, [rSCY]
    ld b, a
    ld a, [NPC_Y]
    inc a
    sub a, b
    ld [NPC + OAMA_Y], a

    ;update main characters global position
    ld a, [MAIN_CHAR_Y]
    dec a
    ld [MAIN_CHAR_Y], a

    ;update screen position
    ld a, [rSCY]
    dec a 
    ld [rSCY], a 
endm

macro MoveSpriteDown
    inc c 
    ld a, c 

    ; Timing Sprite Animations
    cp a, 8
    jr c, .og_sprite_down 

    ; New Sprite
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], 6
    Copy [PLAYER_SPRITE + OAMA_TILEID], 4
    jr .check 

    .og_sprite_down
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], RIGHT_MAIN_ID
    Copy [PLAYER_SPRITE + OAMA_TILEID], LEFT_MAIN_ID 
     
    .check 
    ld  a, c
    cp a, 16
    jr c, .done     
        ld c, 0          
    .done

    ;keep NPCs global position the same
    ld a, [rSCY]
    ld b, a
    ld a, [NPC_Y]
    dec a
    sub a, b
    ld [NPC + OAMA_Y], a

    ;update main characters global position
    ld a, [MAIN_CHAR_Y]
    inc a
    ld [MAIN_CHAR_Y], a

    ;update screen position
    ld a, [rSCY]
    inc a 
    ld [rSCY], a 
    endm

macro NPCMoveLeft 
    ld a, [NPC + OAMA_X]
    dec a
    ld [NPC + OAMA_X], a
endm

macro MoveSprite
    ld a, [PAD_CURR]

    ;move sprite to the right if right button is pressed
    bit PADB_RIGHT, a
    jr nz, .done_moving_right
        MoveSpriteRight 
    .done_moving_right

    ;move sprite to the left if left button is pressed
    ld a, [PAD_CURR]
    bit PADB_LEFT, a
    jr nz, .done_moving_left
        MoveSpriteLeft
    .done_moving_left

    ;move sprite up if up button is pressed
    ld a, [PAD_CURR]
    bit PADB_UP, a
    jr nz, .done_moving_up
        MoveSpriteUp
    .done_moving_up

    ;move sprite down if down is pressed
    ld a, [PAD_CURR]
    bit PADB_DOWN, a
    jr nz, .done_moving_down
        MoveSpriteDown
    .done_moving_down
endm
endc
