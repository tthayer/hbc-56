; Applesoft BASIC for HBC-56 - Main Entry Point
;
; Copyright (c) 2026
; Licensed under MIT
;

!cpu w65c02
!initmem $FF

; Entry point at reset vector
*=$8000

; Include subsystems
!src "tokenizer.asm"
!src "interpreter.asm"

; =============================================================================
; Main program entry point
; =============================================================================

; Initialize Applesoft interpreter
jsr applesoft_init

; Run interpreter on bytecode (pre-loaded in ROM)
jsr interpret

; If we return here, program has ended
; Loop forever
-
    bra -

; =============================================================================
; applesoft_init: Initialize interpreter state
; =============================================================================
applesoft_init:
    ; Zero-initialize interpreter variables
    lda #0
    sta $20        ; tokenizer_ptr
    sta $21
    sta $28        ; interp_pc
    sta $29
    sta $2E        ; var_count
    sta $2F        ; gosub_depth
    sta $30        ; for_depth
    rts

; Interrupt vectors
*=$FFFA
!word $8000        ; NMI vector
!word $8000        ; RESET vector
!word $8000        ; IRQ vector
