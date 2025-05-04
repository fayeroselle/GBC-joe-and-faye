;
; CS-240 World 8
;
; @file main.asm
; @author Faye Roselle, Joe Buttarazzi 
; @date April 29, 2025
; @brief main game loop
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
;
; build with:
; make

include "src/hardware.inc"
include "src/joypad.inc"
include "src/graphics.inc"


def WINDOW_Y   equ 144
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jr main
    ds $150 - @, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "house_message", rom0
    DATA_LABEL:
    db "SHE WAS ALONE HIKING0  UP TO THE NORTH   1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "house_message2", rom0[$1000]
    MESSAGE_LABEL:
    db "LAST SEEN HEADING   0 EAST TO THE CACTI  1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "win_message", rom0[$1100]
    WIN_LABEL:
    db "CONGRATS YOU WIN    0 PRESS B TO RESTART 1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "house_message3", rom0[$1200]
    HOUSE3_LABEL:
    db "SHE WENT SOUTH WITH 0 SOME FELLA         1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "house_message4", rom0[$1300]
    HOUSE4_LABEL:
    db "I WAS WITH HER BUT  0SHE CONTINUED SOUTH 1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "house_message5", rom0[$1400]
    HOUSE5_LABEL:
    db "I WAS AWAY THAT DAY 0MANSION MAN WAS HERE1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "mansion_message", rom0[$1500]
    MANSION_LABEL:
    db "SAW TWO SHADOWS IN  0FIELD AND HEARD TAPS1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "field_message", rom0[$1600]
    FIELD_LABEL:
    db "TWO FOOTPRINT SETS  0TREASURE CHEST EMPTY1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "lose_message", rom0[$1700]
    LOSE_LABEL:
    db "WRONG GUESS YOU LOSE0 PRESS B TO RESTART 1"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "level2_message", rom0[$1800]
    LEVEL2_LABEL:
    db "PRESS B TO CONT AND 0 MAKE YOUR GUESS    1"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section "level2_mess", rom0[$1900]
    LEVEL2_LABEL2:
    db "TIME UP PRESS B TO  0 CONT AND GUESS     1"

section "main", rom0[$0155]
main:
    DisableLCD
    call init_graphics
    EnableLCD
    .loop
    jr .loop

    ret 
    ;InitJoypad

    ;display start screen until start is pressed
    ;.wait_for_start:
    ;UpdateJoypad     
    ;ld a, [PAD_CURR]      
    ;bit PADB_START, a
    ;jr nz, .wait_for_start

    ;remove the start screen and initialize sprites
    ;DisableLCD
    ;ld a, WINDOW_Y
    ;ld [rWY], a
    ;call init_player
    ;EnableLCD
    ;jr .game_loop

    ;.restart
    ;call reset_game

    ;ld c, 0
    ;.game_loop
        ;set_house_checker
        ;push bc 
        ;UpdateJoypad
        ;pop bc
        ;repeatedly check if main character or npc should move
        ;call move_player
        ;determine if the main character is at one of the clue locations
        ;call check_location
        ;halt
        ;ld a, [HOUSE_CHECKER]
        ;inc a
        ;dec a
        ;jr z, .after_loc
            ;halt
            ;call determine_house
        ;.after_loc
        ;call check_end
        ;inc b 
        ;dec b 
        ;jr z, .second_checker
            ;if the player pressed start and select then jump to the guessing level
            ;call end_wait
            ;call reset_game
            ;jr .level_two
        ;.second_checker
        ;call second_checker
        ;call npc_wave
        ;inc b 
        ;dec b
        ;jr z, .game_loop
            ;if the player runs out of time (1 minute) to find clues it jumps to the guessing level
            ;call time_up
            ;jr .level_two

    ;.level_two
        ;push bc 
        ;UpdateJoypad
        ;pop bc
        ;call move_player
        ;detemine if the player is at a house
        ;call check_location
        ;halt
        ;ld a, [HOUSE_CHECKER]
        ;inc a
        ;dec a
        ;jr z, .after_check
            ;determine if the player is at the right house
            ;call determine_guess
            ;inc b 
            ;dec b
            ;jr z, .level_two
                ;jp .restart
        ;.after_check
        ;jr .level_two