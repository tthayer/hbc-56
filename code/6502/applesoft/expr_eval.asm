; Applesoft BASIC for HBC-56 - Expression Evaluator
;
; Evaluates bytecode expressions with 16-bit arithmetic
; Input: bytecode stream at (interp_pc)
; Output: 16-bit result in X (high) / A (low)

; =============================================================================
; eval_expr: Evaluate a complete expression (left-to-right)
; Input:  (interp_pc) = bytecode token (start of expression)
; Output: X = high byte, A = low byte of result
;         interp_pc advanced past expression
; =============================================================================
eval_expr:
    php
    pha
    phx
    phy
    
    ; Get left operand (primary value or expression)
    jsr eval_primary
    
    ; Store left operand
    sta eval_left_a
    stx eval_left_x
    
eval_expr_loop:
    ; Check if next token is an operator
    lda (interp_pc)
    cmp #TOKEN_OPERATOR
    bne eval_expr_done
    
    ; Save operator type (next byte after TOKEN_OPERATOR)
    inc interp_pc
    lda (interp_pc)
    sta eval_op
    
    ; Get right operand
    inc interp_pc
    jsr eval_primary
    sta eval_right_a
    stx eval_right_x
    
    ; Apply operator to left operand with right operand
    jsr apply_operator
    
    ; Result now in X:A, save as new left operand
    sta eval_left_a
    stx eval_left_x
    
    ; Continue looping for more operators (left-to-right evaluation)
    inc interp_pc
    bra eval_expr_loop
    
eval_expr_done:
    ; Return final result
    ldx eval_left_x
    lda eval_left_a
    
    ply
    plx
    pla
    plp
    rts

; =============================================================================
; eval_primary: Parse a primary value (literal, variable, or (expr))
; Input:  (interp_pc) = bytecode token
; Output: X = high byte, A = low byte of value
;         interp_pc NOT advanced (caller does it)
; =============================================================================
eval_primary:
    php
    pha
    phx
    phy
    
    lda (interp_pc)         ; Get token type
    
    ; Check token type
    cmp #TOKEN_NUMBER       ; $41 = 16-bit number
    beq primary_number
    
    cmp #TOKEN_VARIABLE     ; $40 = variable reference
    beq primary_variable
    
    cmp #TOKEN_STRING       ; $42 = string (evaluate to 0)
    beq primary_string
    
    ; Default: return 0
    ldx #0
    lda #0
    jmp primary_done
    
primary_number:
    ; TOKEN_NUMBER: [TOKEN_NUMBER][MSB][LSB]
    inc interp_pc
    lda (interp_pc)         ; MSB
    tax
    inc interp_pc
    lda (interp_pc)         ; LSB
    jmp primary_done
    
primary_variable:
    ; TOKEN_VARIABLE: [TOKEN_VARIABLE][var_index]
    ; Look up variable value from table at $0200
    inc interp_pc
    lda (interp_pc)         ; Variable index (0-31)
    asl                     ; *2 for byte offset
    tax
    lda $0200, x            ; High byte
    pha
    lda $0201, x            ; Low byte
    tax                     ; Move to X for return
    pla                     ; Get high byte back
    jmp primary_done
    
primary_string:
    ; Strings evaluate to 0
    ldx #0
    lda #0
    
primary_done:
    ply
    plx
    pla
    plp
    rts

; =============================================================================
; apply_operator: Apply binary operator to operands
; Input:  eval_op = operator type (OP_PLUS, OP_MINUS, etc.)
;         eval_left_a, eval_left_x = left operand
;         eval_right_a, eval_right_x = right operand
; Output: X = high byte, A = low byte of result
; =============================================================================
apply_operator:
    php
    pha
    phx
    phy
    
    lda eval_op
    
    cmp #OP_PLUS
    beq do_add
    cmp #OP_MINUS
    beq do_subtract
    cmp #OP_MULTIPLY
    beq do_multiply
    cmp #OP_DIVIDE
    beq do_divide
    cmp #OP_EQUAL
    beq do_equal
    cmp #OP_LESS
    beq do_less
    cmp #OP_GREATER
    beq do_greater
    cmp #OP_LE
    beq do_le
    cmp #OP_GE
    beq do_ge
    cmp #OP_NE
    beq do_ne
    
    ; Unknown operator: return left operand unchanged
    ldx eval_left_x
    lda eval_left_a
    jmp apply_done
    
do_add:
    ; 16-bit addition: left + right
    clc
    lda eval_left_a
    adc eval_right_a
    sta eval_left_a
    lda eval_left_x
    adc eval_right_x
    sta eval_left_x
    ldx eval_left_x
    lda eval_left_a
    jmp apply_done
    
do_subtract:
    ; 16-bit subtraction: left - right
    sec
    lda eval_left_a
    sbc eval_right_a
    sta eval_left_a
    lda eval_left_x
    sbc eval_right_x
    sta eval_left_x
    ldx eval_left_x
    lda eval_left_a
    jmp apply_done
    
do_multiply:
    ; 16-bit multiply: For Phase 1, simple 8-bit multiply using repeated addition
    ; result = left * right (simplified: assume left and right are < 256)
    
    lda #0
    sta $34                 ; result_high = 0
    sta $35                 ; result_low = 0
    
    ldx eval_left_a         ; X = counter (how many times to add right)
    beq multiply_done
    
multiply_loop:
    clc
    lda $35
    adc eval_right_a
    sta $35
    lda $34
    adc eval_right_x
    sta $34
    dex
    bne multiply_loop
    
multiply_done:
    ldx $34
    lda $35
    jmp apply_done
    
do_divide:
    ; 16-bit divide: Simple repeated subtraction
    ; Check for zero divisor
    lda eval_right_a
    ora eval_right_x
    beq divide_zero
    
    ; Initialize quotient and remainder
    lda #0
    sta $34                 ; quotient_high = 0
    sta $35                 ; quotient_low = 0
    
    ; Copy dividend to remainder
    lda eval_left_a
    sta $36                 ; remainder_low
    lda eval_left_x
    sta $37                 ; remainder_high
    
divide_loop:
    ; Check if remainder < divisor
    lda $37
    cmp eval_right_x
    bcc divide_done
    beq divide_check_low
    bcs divide_again
    
divide_check_low:
    lda $36
    cmp eval_right_a
    bcc divide_done
    
divide_again:
    ; Subtract divisor from remainder
    sec
    lda $36
    sbc eval_right_a
    sta $36
    lda $37
    sbc eval_right_x
    sta $37
    
    ; Increment quotient
    clc
    lda $35
    adc #1
    sta $35
    bcc divide_loop
    inc $34
    bra divide_loop
    
divide_zero:
    ; Division by zero: return 0
    lda #0
    sta $34
    sta $35
    
divide_done:
    ldx $34
    lda $35
    jmp apply_done
    
; Comparison operators return 1 (true) or 0 (false)
do_equal:
    ; Compare left == right
    lda eval_left_x
    cmp eval_right_x
    bne comp_false
    lda eval_left_a
    cmp eval_right_a
    bne comp_false
    ; Equal: return 1
    ldx #0
    lda #1
    jmp apply_done
    
do_less:
    ; Compare left < right
    lda eval_left_x
    cmp eval_right_x
    bcc comp_true           ; left_high < right_high
    bne comp_false          ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc comp_true           ; left_low < right_low
    jmp comp_false
    
do_greater:
    ; Compare left > right
    lda eval_left_x
    cmp eval_right_x
    bcc comp_false          ; left_high < right_high
    bne comp_true           ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc comp_false          ; left_low < right_low
    beq comp_false          ; left_low == right_low
    ; left_low > right_low
    ldx #0
    lda #1
    jmp apply_done
    
do_le:
    ; Compare left <= right
    lda eval_left_x
    cmp eval_right_x
    bcc comp_true           ; left_high < right_high
    bne comp_false          ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc comp_true           ; left_low < right_low
    beq comp_true           ; left_low == right_low
    jmp comp_false
    
do_ge:
    ; Compare left >= right
    lda eval_left_x
    cmp eval_right_x
    bcc comp_false          ; left_high < right_high
    bne comp_true           ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc comp_false          ; left_low < right_low
    ; left_low >= right_low
    ldx #0
    lda #1
    jmp apply_done
    
do_ne:
    ; Compare left != right
    lda eval_left_x
    cmp eval_right_x
    bne comp_true           ; high bytes differ
    lda eval_left_a
    cmp eval_right_a
    bne comp_true           ; low bytes differ
    ; Values are equal, so != is false
    jmp comp_false
    
comp_true:
    ldx #0
    lda #1
    jmp apply_done
    
comp_false:
    ldx #0
    lda #0
    jmp apply_done
    
apply_done:
    ply
    plx
    pla
    plp
    rts
