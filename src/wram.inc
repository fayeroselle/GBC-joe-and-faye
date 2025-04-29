; 
; CS 240: Storing Joypad state, including pressed/released/etc
;
; @file wram.inc
; @author Joe Buttarazzi and Faye Roselle
; @date April 29th, 2025
; @brief a place to store all WRAM variables
; @license Creative Commons Zero v1.0 Universal (CC0 1.0)
; 
; build with: 
; make 

if !def(WRAM_RGBINC)
def WRAM_RGBINC equ 1

rsset _RAM
def PAD_CURR rb 1
def PAD_PREV rb 1
def PAD_PRSS rb 1
def PAD_RLSE rb 1
def MAIN_CHAR_X rb 1
def MAIN_CHAR_Y rb 1
def NPC_X   rb 1
def NPC_Y   rb 1
def HOUSE_CHECKER rb 1
def FRAME_COUNTER rb 1  
def SECOND_COUNTER rb 1

endc
