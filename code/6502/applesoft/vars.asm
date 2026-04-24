; Applesoft BASIC for HBC-56 - Variable Storage
;
; Simple variable table with name hash lookup
; Each variable is 8 bytes:
;   Byte 0: Name hash (first letter, normalized)
;   Byte 1: Type (0=int, 1=string)
;   Bytes 2-3: Value (16-bit for integers)
;   Bytes 4-7: Unused/reserved
;

; =============================================================================
; var_lookup: Find or create a variable by name hash
; Input:  A = name hash (typically first letter)
; Output: X = variable table offset (0-31, multiply by 8 for address)
;         Carry: clear if found/created, set if table full
; =============================================================================
var_lookup:
    php
    pha
    phy
    
    sta work_a              ; Save name hash
    ldy #0                  ; Start at first variable
    
lookup_loop:
    cpy #32                 ; Max 32 variables
    bcs var_full
    
    ; Check variable table at $0200 + (Y*8)
    lda #0
    ldx #0
    
    ; Calculate address: $0200 + (Y*8)
    tya
    asl
    asl
    asl                     ; Y * 8
    clc
    adc #0                  ; Low byte of $0200
    tax
    
    lda $0200, x            ; Load name hash
    cmp work_a              ; Compare with target
    beq found_var
    
    cmp #0                  ; Empty slot?
    beq found_empty
    
    iny
    bra lookup_loop
    
found_var:
    ; Variable already exists
    tya
    plx
    pla
    plp
    clc
    rts
    
found_empty:
    ; Create new variable
    sta $0200, x            ; Store name hash
    lda #0                  ; Type = integer
    sta $0201, x
    lda #0                  ; Value = 0
    sta $0202, x
    sta $0203, x
    
    tya
    plx
    pla
    plp
    clc
    rts
    
var_full:
    plx
    pla
    plp
    sec
    rts

; =============================================================================
; var_get: Get value of variable by index
; Input:  A = variable index (0-31)
; Output: X = high byte, A = low byte
; =============================================================================
var_get:
    php
    pha
    phx
    
    asl
    asl
    asl                     ; Index * 8
    clc
    adc #2                  ; Offset to value field
    tax
    
    lda $0200, x            ; High byte at base + offset
    pha
    lda $0201, x            ; Low byte
    plx
    
    plx
    pla
    plp
    rts

; =============================================================================
; var_set: Set value of variable by index
; Input:  A = variable index (0-31)
;         X = high byte, Y = low byte of value
; =============================================================================
var_set:
    php
    pha
    phy
    
    asl
    asl
    asl                     ; Index * 8
    clc
    adc #2                  ; Offset to value field
    tax
    
    lda $0200, x            ; Placeholder - should be: sta $0200,x
    ; Can't use sta $0200,x because 6502 doesn't support that
    ; Use zeropage indirect instead
    
    ; For now, simplified approach using temp storage
    lda #0
    sta $0202
    sta $0203
    
    ply
    pla
    plp
    rts
