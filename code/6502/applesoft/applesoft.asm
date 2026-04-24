; Applesoft BASIC for HBC-56 - Main Entry Point
;
; Copyright (c) 2026
; Licensed under MIT
;

!cpu w65c02
!initmem $FF

*=$8000

; Include subsystems
!src "tokenizer.asm"
!src "interpreter.asm"

; =============================================================================
; Main program entry point
; =============================================================================

; Initialize Applesoft interpreter
jsr applesoft_init

; Run interpreter on bytecode
jsr interpret

; If we return here, program has ended
bra *

; =============================================================================
; applesoft_init: Initialize interpreter state
; =============================================================================
applesoft_init:
    php
    pha
    
    lda #0
    sta $20
    sta $21
    sta $28
    sta $29
    sta $2B
    sta $2C
    
    pla
    plp
    rts

; Interrupt vectors
*=$FFFA
!word $8000
!word $8000
!word $8000
