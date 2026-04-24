; Applesoft BASIC for HBC-56 - Tokenizer
;
; Converts Applesoft BASIC text input into bytecode tokens
; Phase 1: Support keywords, numbers, strings, operators
;

; Zero page allocations
tokenizer_ptr      = $20   ; Input pointer (16-bit)
tokenizer_out      = $22   ; Output pointer (16-bit)
work_a             = $24   ; General work byte
work_b             = $25   ; General work byte

; Keyword token values
KW_PRINT           = $00
KW_INPUT           = $01
KW_LET             = $02
KW_GOTO            = $03
KW_IF              = $04
KW_THEN            = $05
KW_FOR             = $06
KW_NEXT            = $07
KW_GOSUB           = $08
KW_RETURN          = $09
KW_REM             = $0A
KW_END             = $0B
KW_RUN             = $0C
KW_NEW             = $0D
KW_PLOT            = $0E
KW_COLOR           = $0F

; Token type values
TOKEN_KEYWORD      = $00
TOKEN_VARIABLE     = $40
TOKEN_NUMBER       = $41
TOKEN_STRING       = $42
TOKEN_OPERATOR     = $43
TOKEN_DELIMITER    = $44

; =============================================================================
; tokenize_line: Parse a line of BASIC text
; Input:  $20/$21 = input pointer
; Output: none (works in-place)
; =============================================================================
tokenize_line:
    rts

; =============================================================================
; tokenize_keyword: Try to match a keyword at current position
; Input:  $20/$21 = input pointer
; Output: A = token value ($00-$0F) or returns with carry set if no match
; Carry: clear if match, set if no match
; =============================================================================
tokenize_keyword:
    php
    pha
    phx
    phy
    
    ; Match keyword by string comparison
    ; Get input string in $20/$21
    ; Try each keyword in order
    
    ; Try "PRINT"
    ldy #0
    lda ($20), y
    cmp #80                 ; 'P'
    bne try_input
    iny
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_input
    iny
    lda ($20), y
    cmp #73                 ; 'I'
    bne try_input
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_input
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_input
    iny
    lda ($20), y
    cmp #32                 ; space or other non-letter
    bcc print_match         ; branch if less (carry clear means A < #)
    cmp #65                 ; 'A'
    bcc print_match
    cmp #91                 ; past 'Z'
    bcs print_match         ; branch if greater or equal
    bra try_input
print_match:
    lda #KW_PRINT
    ply
    plx
    pla
    plp
    clc
    rts
    
try_input:
    ; Try other keywords...
    ; For Phase 1, just support PRINT
    ; (TODO: Add INPUT, LET, GOTO, etc.)
    
    ply
    plx
    pla
    plp
    sec
    rts

; =============================================================================
; tokenize_number: Parse a decimal number (0-65535)
; Input:  $20/$21 = input pointer
; Output: X (msb), Y (lsb) = 16-bit number
;         Carry: clear if success
; =============================================================================
tokenize_number:
    php
    pha
    
    lda #0
    ldx #0
    ldy #0
    
    pla
    plp
    clc
    rts

; =============================================================================
; tokenize_string: Parse a quoted string
; Input:  $20/$21 = input pointer (at opening quote)
; Output: A = pool index
;         Carry: clear if success, set if unterminated
; =============================================================================
tokenize_string:
    php
    pha
    
    lda #0
    
    pla
    plp
    clc
    rts
