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
    ; Try "INPUT"
    ldy #0
    lda ($20), y
    cmp #73                 ; 'I'
    bne try_let
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_let
    iny
    lda ($20), y
    cmp #80                 ; 'P'
    bne try_let
    iny
    lda ($20), y
    cmp #85                 ; 'U'
    bne try_let
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_let
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc input_match
    cmp #65                 ; 'A'
    bcc input_match
    cmp #91                 ; past 'Z'
    bcs input_match
    bra try_let
input_match:
    lda #KW_INPUT
    ply
    plx
    pla
    plp
    clc
    rts

try_let:
    ; Try "LET"
    ldy #0
    lda ($20), y
    cmp #76                 ; 'L'
    bne try_goto
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_goto
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_goto
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc let_match
    cmp #65                 ; 'A'
    bcc let_match
    cmp #91                 ; past 'Z'
    bcs let_match
    bra try_goto
let_match:
    lda #KW_LET
    ply
    plx
    pla
    plp
    clc
    rts

try_goto:
    ; Try "GOTO"
    ldy #0
    lda ($20), y
    cmp #71                 ; 'G'
    bne try_if
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne try_if
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_if
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne try_if
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc goto_match
    cmp #65                 ; 'A'
    bcc goto_match
    cmp #91                 ; past 'Z'
    bcs goto_match
    bra try_if
goto_match:
    lda #KW_GOTO
    ply
    plx
    pla
    plp
    clc
    rts

try_if:
    ; Try "IF"
    ldy #0
    lda ($20), y
    cmp #73                 ; 'I'
    bne try_then
    iny
    lda ($20), y
    cmp #70                 ; 'F'
    bne try_then
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc if_match
    cmp #65                 ; 'A'
    bcc if_match
    cmp #91                 ; past 'Z'
    bcs if_match
    bra try_then
if_match:
    lda #KW_IF
    ply
    plx
    pla
    plp
    clc
    rts

try_then:
    ; Try "THEN"
    ldy #0
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_for
    iny
    lda ($20), y
    cmp #72                 ; 'H'
    bne try_for
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_for
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_for
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc then_match
    cmp #65                 ; 'A'
    bcc then_match
    cmp #91                 ; past 'Z'
    bcs then_match
    bra try_for
then_match:
    lda #KW_THEN
    ply
    plx
    pla
    plp
    clc
    rts

try_for:
    ; Try "FOR"
    ldy #0
    lda ($20), y
    cmp #70                 ; 'F'
    bne try_next
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne try_next
    iny
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_next
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc for_match
    cmp #65                 ; 'A'
    bcc for_match
    cmp #91                 ; past 'Z'
    bcs for_match
    bra try_next
for_match:
    lda #KW_FOR
    ply
    plx
    pla
    plp
    clc
    rts

try_next:
    ; Try "NEXT"
    ldy #0
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_gosub
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_gosub
    iny
    lda ($20), y
    cmp #88                 ; 'X'
    bne try_gosub
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_gosub
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc next_match
    cmp #65                 ; 'A'
    bcc next_match
    cmp #91                 ; past 'Z'
    bcs next_match
    bra try_gosub
next_match:
    lda #KW_NEXT
    ply
    plx
    pla
    plp
    clc
    rts

try_gosub:
    ; Try "GOSUB"
    ldy #0
    lda ($20), y
    cmp #71                 ; 'G'
    bne try_return
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne try_return
    iny
    lda ($20), y
    cmp #83                 ; 'S'
    bne try_return
    iny
    lda ($20), y
    cmp #85                 ; 'U'
    bne try_return
    iny
    lda ($20), y
    cmp #66                 ; 'B'
    bne try_return
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc gosub_match
    cmp #65                 ; 'A'
    bcc gosub_match
    cmp #91                 ; past 'Z'
    bcs gosub_match
    bra try_return
gosub_match:
    lda #KW_GOSUB
    ply
    plx
    pla
    plp
    clc
    rts

try_return:
    ; Try "RETURN"
    ldy #0
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_rem
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_rem
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_rem
    iny
    lda ($20), y
    cmp #85                 ; 'U'
    bne try_rem
    iny
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_rem
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_rem
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc return_match
    cmp #65                 ; 'A'
    bcc return_match
    cmp #91                 ; past 'Z'
    bcs return_match
    bra try_rem
return_match:
    lda #KW_RETURN
    ply
    plx
    pla
    plp
    clc
    rts

try_rem:
    ; Try "REM"
    ldy #0
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_end
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_end
    iny
    lda ($20), y
    cmp #77                 ; 'M'
    bne try_end
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc rem_match
    cmp #65                 ; 'A'
    bcc rem_match
    cmp #91                 ; past 'Z'
    bcs rem_match
    bra try_end
rem_match:
    lda #KW_REM
    ply
    plx
    pla
    plp
    clc
    rts

try_end:
    ; Try "END"
    ldy #0
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_run
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_run
    iny
    lda ($20), y
    cmp #68                 ; 'D'
    bne try_run
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc end_match
    cmp #65                 ; 'A'
    bcc end_match
    cmp #91                 ; past 'Z'
    bcs end_match
    bra try_run
end_match:
    lda #KW_END
    ply
    plx
    pla
    plp
    clc
    rts

try_run:
    ; Try "RUN"
    ldy #0
    lda ($20), y
    cmp #82                 ; 'R'
    bne try_new
    iny
    lda ($20), y
    cmp #85                 ; 'U'
    bne try_new
    iny
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_new
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc run_match
    cmp #65                 ; 'A'
    bcc run_match
    cmp #91                 ; past 'Z'
    bcs run_match
    bra try_new
run_match:
    lda #KW_RUN
    ply
    plx
    pla
    plp
    clc
    rts

try_new:
    ; Try "NEW"
    ldy #0
    lda ($20), y
    cmp #78                 ; 'N'
    bne try_plot
    iny
    lda ($20), y
    cmp #69                 ; 'E'
    bne try_plot
    iny
    lda ($20), y
    cmp #87                 ; 'W'
    bne try_plot
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc new_match
    cmp #65                 ; 'A'
    bcc new_match
    cmp #91                 ; past 'Z'
    bcs new_match
    bra try_plot
new_match:
    lda #KW_NEW
    ply
    plx
    pla
    plp
    clc
    rts

try_plot:
    ; Try "PLOT"
    ldy #0
    lda ($20), y
    cmp #80                 ; 'P'
    bne try_color
    iny
    lda ($20), y
    cmp #76                 ; 'L'
    bne try_color
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne try_color
    iny
    lda ($20), y
    cmp #84                 ; 'T'
    bne try_color
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc plot_match
    cmp #65                 ; 'A'
    bcc plot_match
    cmp #91                 ; past 'Z'
    bcs plot_match
    bra try_color
plot_match:
    lda #KW_PLOT
    ply
    plx
    pla
    plp
    clc
    rts

try_color:
    ; Try "COLOR"
    ldy #0
    lda ($20), y
    cmp #67                 ; 'C'
    bne no_match
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne no_match
    iny
    lda ($20), y
    cmp #76                 ; 'L'
    bne no_match
    iny
    lda ($20), y
    cmp #79                 ; 'O'
    bne no_match
    iny
    lda ($20), y
    cmp #82                 ; 'R'
    bne no_match
    iny
    lda ($20), y
    cmp #32                 ; space or non-letter
    bcc color_match
    cmp #65                 ; 'A'
    bcc color_match
    cmp #91                 ; past 'Z'
    bcs color_match
    bra no_match
color_match:
    lda #KW_COLOR
    ply
    plx
    pla
    plp
    clc
    rts

no_match:
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
    phx
    phy
    
    lda #0
    tax                     ; Result high byte
    tay                     ; Result low byte
    ldy #0                  ; Index counter
    
number_loop:
    lda ($20), y            ; Load digit character
    cmp #48                 ; '0'
    bcc number_done
    cmp #58                 ; past '9'
    bcs number_done
    
    ; Multiply accumulator by 10 and add new digit
    ; result = result * 10 + digit
    
    ; First, get digit value
    sbc #48                 ; A = digit value (0-9)
    pha
    
    ; Multiply current result by 10
    ; result_hi:result_lo * 10
    lda $25                 ; load result_lo
    sta work_a
    lda $24                 ; load result_hi
    sta work_b
    
    ; Shift left 3 times for *8, then add *2
    asl work_a
    rol work_b              ; result * 2
    asl work_a
    rol work_b              ; result * 4
    asl work_a
    rol work_b              ; result * 8
    
    lda work_a
    sta $25
    lda work_b
    sta $24
    
    ; Now add result*2: shift left once more from original
    lda $25
    asl
    sta work_a
    lda $24
    asl
    sta work_b
    
    ; Add *2 to *8 to get *10
    lda work_a
    adc $25
    sta $25
    lda work_b
    adc $24
    sta $24
    
    ; Add new digit
    pla
    adc $25
    sta $25
    bcc number_next
    inc $24
    
number_next:
    iny
    bra number_loop
    
number_done:
    ldx $24                 ; X = high byte
    ldy $25                 ; Y = low byte
    ply
    plx
    pla
    plp
    clc
    rts

; =============================================================================
; tokenize_string: Parse a quoted string
; Input:  $20/$21 = input pointer (at opening quote)
; Output: A = pool index (0-63, limited by 4KB pool)
;         Carry: clear if success, set if unterminated
; String storage: Strings are stored at $0300-$12FF (4 KB string pool)
; =============================================================================
tokenize_string:
    php
    pha
    phx
    phy
    
    ldy #1                  ; Skip opening quote
    lda #0                  ; Pool index starts at 0
    tax                     ; X = output position in pool
    
    ; String pool is at $0300 (fixed address for simplicity)
    ; We'll use a simple inline allocation for Phase 1
    
string_loop:
    lda ($20), y            ; Load next character from input
    cmp #34                 ; '"'
    beq string_done
    cmp #0                  ; NULL or EOL
    beq string_unterminated
    
    ; Store character in string pool
    ; For now, use fixed address approach
    ; TODO: Track string pool offset properly
    
    iny
    inx
    cpx #64                 ; Max 64 strings for Phase 1
    bcc string_loop
    bcs string_unterminated
    
string_done:
    lda #0                  ; Return string index 0 for now
    ply
    plx
    pla
    plp
    clc
    rts
    
string_unterminated:
    ply
    plx
    pla
    plp
    sec
    rts
