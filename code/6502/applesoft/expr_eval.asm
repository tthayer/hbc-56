; Applesoft BASIC for HBC-56 - Expression Evaluator
;
; Evaluates bytecode expressions with operator precedence
; Input: bytecode stream at (interp_pc)
; Output: 16-bit result in X (high) / A (low)
;

; =============================================================================
; eval_expr: Evaluate a single expression
; Input:  (interp_pc) = bytecode starting with expression
; Output: X = high byte, A = low byte of result
;         interp_pc advanced past expression
; =============================================================================
eval_expr:
    php
    pha
    phx
    phy
    
    ; Start with primary (operand or parenthesized expression)
    jsr eval_primary
    
    ; X has high byte, A has low byte
    ; Now check for operators at same precedence level
    
    ply
    plx
    pla
    plp
    rts

; =============================================================================
; eval_primary: Parse a primary value (literal, variable, or (expr))
; Input:  (interp_pc) = bytecode token
; Output: X = high byte, A = low byte
; =============================================================================
eval_primary:
    php
    pha
    phx
    phy
    
    lda (interp_pc)         ; Get token
    
    ; Check token type
    cmp #TOKEN_NUMBER       ; $41 = 16-bit number
    beq primary_number
    
    cmp #TOKEN_VARIABLE     ; $40 = variable reference
    beq primary_variable
    
    cmp #TOKEN_STRING       ; $42 = string (evaluate to 0)
    beq primary_string
    
    cmp #DELIM_LPAREN       ; $44,$02 = (expr)
    beq primary_paren
    
    ; Default: return 0
    ldx #0
    lda #0
    bra primary_done
    
primary_number:
    ; TOKEN_NUMBER: next byte is MSB, then LSB
    inc interp_pc
    lda (interp_pc)         ; MSB
    tax
    inc interp_pc
    lda (interp_pc)         ; LSB
    bra primary_done
    
primary_variable:
    ; TOKEN_VARIABLE: next byte is variable index
    inc interp_pc
    lda (interp_pc)         ; Variable index (0-31)
    ; Look up variable value
    ; For Phase 1: simple lookup in variable table at $0200
    ; Each variable is 2 bytes (high byte first)
    asl                     ; *2 for byte offset
    tax
    lda $0200, x            ; High byte
    pha
    lda $0201, x            ; Low byte
    plx
    bra primary_done
    
primary_string:
    ; Strings evaluate to 0
    ldx #0
    lda #0
    bra primary_done
    
primary_paren:
    ; Parenthesized expression: skip '(' and recurse
    inc interp_pc
    jsr eval_expr           ; Recursively evaluate
    ; Skip closing ')'
    inc interp_pc
    bra primary_done
    
primary_done:
    ply
    plx
    pla
    plp
    rts

; =============================================================================
; eval_expr_prec: Evaluate expression with operator precedence
; For Phase 1, simplified operator handling
; Input:  X:A = left operand
; Output: X:A = result
; =============================================================================
eval_expr_prec:
    php
    pha
    phx
    phy
    
    ; Stack the result for now
    sta work_a              ; Save low byte
    stx work_b              ; Save high byte
    
    ; Check for operator at (interp_pc)
    inc interp_pc
    lda (interp_pc)
    
    cmp #TOKEN_OPERATOR     ; $43 = operator token
    bne eval_expr_prec_done
    
    ; Get operator type
    inc interp_pc
    lda (interp_pc)         ; Operator type
    
    ; For Phase 1: handle simple binary operators
    ; Result is in work_a:work_b (16-bit)
    
    ; Get right operand
    inc interp_pc
    jsr eval_primary        ; Right operand in X:A
    
    ; Compare with saved operator type and apply
    ; For now, just return left operand unchanged
    
eval_expr_prec_done:
    ldx work_b
    lda work_a
    
    ply
    plx
    pla
    plp
    rts
