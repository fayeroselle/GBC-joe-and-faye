;
; CS-240 World 8
;
; @file player.asm
; @author Faye Roselle, Joe Buttarazzi 
; @date April 29, 2025
; @brief player functions for initializing and moving 
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
;
; build with:
; make

include "src/utils.inc"
include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"

section "newplayer", rom0
init_player:
    ; initialize Left Side, Main Character
    Copy [PLAYER_SPRITE + OAMA_X], PLAYER_START_X
    Copy [PLAYER_SPRITE + OAMA_Y], PLAYER_START_Y
    Copy [PLAYER_SPRITE + OAMA_TILEID], LEFT_MAIN_ID
    Copy [PLAYER_SPRITE + OAMA_FLAGS], OAMA_NO_FLAGS
    ; initialize Right Side, Main Character
    Copy [PLAYER_SPRITE_RIGHT + OAMA_Y], PLAYER_START_Y
    ld a, PLAYER_START_X
    add X_ADJUST             
    ld [PLAYER_SPRITE_RIGHT + OAMA_X], a
    Copy [PLAYER_SPRITE_RIGHT + OAMA_TILEID], RIGHT_MAIN_ID
    Copy [PLAYER_SPRITE_RIGHT + OAMA_FLAGS], OAMA_NO_FLAGS

    ; initialize NPC 
    Copy [NPC + OAMA_X], NPC_START_X
    Copy [NPC + OAMA_Y], NPC_START_Y
    Copy [NPC + OAMA_TILEID], NPC_ID
    Copy [NPC + OAMA_FLAGS], OAMA_NO_FLAGS

    ; initialize NPC 2
    Copy [NPC2 + OAMA_X], NPC2_START_X
    Copy [NPC2 + OAMA_Y], NPC2_START_Y
    Copy [NPC2 + OAMA_TILEID], NPC2_ID
    Copy [NPC2 + OAMA_FLAGS], OAMA_NO_FLAGS

    init_sprite_data
    ret

npc_wave:
    ld   a, [SECOND_COUNTER]
    bit  1, a
    ; if bit1=0 (seconds 0–1, 4–5, 8–9…), go to frame1
    jr   z, .wave_frame1  
    .wave_frame2:
        Copy [NPC + OAMA_TILEID], NPC_ID2
        ret
        
    .wave_frame1:
        Copy [NPC + OAMA_TILEID], NPC_ID
    ret

move_player:
    MoveSprite
    ret

export init_player, move_player, npc_wave