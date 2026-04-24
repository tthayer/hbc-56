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
    bne check_equal
    jmp do_divide
check_equal:
    cmp #OP_EQUAL
    bne check_less
    jmp do_equal
check_less:
    cmp #OP_LESS
    bne check_greater
    jmp do_less
check_greater:
    cmp #OP_GREATER
    bne check_le
    jmp do_greater
check_le:
    cmp #OP_LE
    bne check_ge
    jmp do_le
check_ge:
    cmp #OP_GE
    bne check_ne
    jmp do_ge
check_ne:
    cmp #OP_NE
    bne unknown_op
    jmp do_ne
    
unknown_op:
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
    bne eq_false
    lda eval_left_a
    cmp eval_right_a
    bne eq_false
    ; Equal: return 1
    ldx #0
    lda #1
    jmp apply_done
eq_false:
    ldx #0
    lda #0
    jmp apply_done
    
do_less:
    ; Compare left < right
    lda eval_left_x
    cmp eval_right_x
    bcc lt_true             ; left_high < right_high
    bne lt_false            ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc lt_true             ; left_low < right_low
    bra lt_false
    
lt_true:
    ldx #0
    lda #1
    jmp apply_done
lt_false:
    ldx #0
    lda #0
    jmp apply_done
    
do_greater:
    ; Compare left > right
    lda eval_left_x
    cmp eval_right_x
    bcc gt_false            ; left_high < right_high
    bne gt_true             ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc gt_false            ; left_low < right_low
    beq gt_false            ; left_low == right_low
    ; left_low > right_low
    ldx #0
    lda #1
    jmp apply_done
    
gt_true:
    ldx #0
    lda #1
    jmp apply_done
gt_false:
    ldx #0
    lda #0
    jmp apply_done
    
do_le:
    ; Compare left <= right
    lda eval_left_x
    cmp eval_right_x
    bcc le_true             ; left_high < right_high
    bne le_false            ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc le_true             ; left_low < right_low
    beq le_true             ; left_low == right_low
    bra le_false
    
le_true:
    ldx #0
    lda #1
    jmp apply_done
le_false:
    ldx #0
    lda #0
    jmp apply_done
    
do_ge:
    ; Compare left >= right
    lda eval_left_x
    cmp eval_right_x
    bcc ge_false            ; left_high < right_high
    bne ge_true             ; left_high > right_high
    ; High bytes equal, check low bytes
    lda eval_left_a
    cmp eval_right_a
    bcc ge_false            ; left_low < right_low
    ; left_low >= right_low
    ldx #0
    lda #1
    jmp apply_done
    
ge_true:
    ldx #0
    lda #1
    jmp apply_done
ge_false:
    ldx #0
    lda #0
    jmp apply_done
    
do_ne:
    ; Compare left != right
    lda eval_left_x
    cmp eval_right_x
    bne ne_true             ; high bytes differ
    lda eval_left_a
    cmp eval_right_a
    bne ne_true             ; low bytes differ
    ; Values are equal, so != is false
    ldx #0
    lda #0
    jmp apply_done
    
ne_true:
    ldx #0
    lda #1
    jmp apply_done
    
apply_done:
    ply
    plx
    pla
    plp
    rts
