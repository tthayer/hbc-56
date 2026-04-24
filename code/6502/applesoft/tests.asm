; Test programs for Applesoft BASIC interpreter
;
; These are hand-encoded bytecode test cases
; Format: [line number (2 bytes)] [statements...] [NEWLINE]

*=$1400                        ; Start of program buffer

; Test 1: PRINT "HELLO"
; Line 10: PRINT "HELLO"
test_1:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_PRINT, TOKEN_STRING, $00, TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END
    
    ; String pool for test 1
    !text "HELLO"

; Test 2: PRINT 42
; Line 10: PRINT 42
test_2:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A, TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 3: X=10, PRINT X
; Line 10: LET X=10
; Line 20: PRINT X
test_3:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_LET, TOKEN_VARIABLE, $00, TOKEN_OPERATOR, OP_EQUAL
    !byte TOKEN_NUMBER, $00, $0A
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_VARIABLE, $00
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 4: PRINT 2+3
; Line 10: PRINT 2+3
test_4:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_PRINT, TOKEN_NUMBER, $00, $02
    !byte TOKEN_OPERATOR, OP_PLUS
    !byte TOKEN_NUMBER, $00, $03
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 5: GOTO jump
; Line 10: GOTO 20
; Line 20: PRINT 42
test_5:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_GOTO, TOKEN_NUMBER, $00, $14 ; GOTO 20
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 6: IF/THEN true branch
; Line 10: IF 1 THEN 20
; Line 20: PRINT 42
test_6:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_IF, TOKEN_NUMBER, $00, $01 ; IF 1 (true)
    !byte TOKEN_OPERATOR, OP_EQUAL      ; Just a dummy operator to test condition evaluation
    !byte TOKEN_NUMBER, $00, $01        ; = 1
    !byte KW_THEN, TOKEN_NUMBER, $00, $14 ; THEN 20
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 7: IF/THEN false branch (skip)
; Line 10: IF 0 THEN 20
; Line 10: PRINT 99 (0x63)
; Line 20: PRINT 42 (skipped)
test_7:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_IF, TOKEN_NUMBER, $00, $00 ; IF 0 (false)
    !byte KW_THEN, TOKEN_NUMBER, $00, $14 ; THEN 20
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_PRINT, TOKEN_NUMBER, $00, $63 ; PRINT 99
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END


; Test 8: FOR/NEXT loop
; Line 10: FOR I=1 TO 3
; Line 20: PRINT I
; Line 30: NEXT I
test_8:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_FOR, TOKEN_VARIABLE, $08   ; FOR I (variable index 8)
    !byte TOKEN_OPERATOR, OP_EQUAL      ; =
    !byte TOKEN_NUMBER, $00, $01        ; 1
    ; Next is end value
    !byte TOKEN_NUMBER, $00, $03        ; 3
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_VARIABLE, $08 ; PRINT I
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    
    !byte TOKEN_NUMBER, $00, $1E        ; Line number 30
    !byte KW_NEXT, TOKEN_VARIABLE, $08  ; NEXT I
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 9: GOSUB/RETURN subroutine call
; Line 10: GOSUB 30
; Line 20: PRINT 99 (should execute after RETURN)
; Line 30: PRINT 42 (subroutine)
; Line 40: RETURN
test_9:
    !byte TOKEN_NUMBER, $00, $0A        ; Line number 10
    !byte KW_GOSUB, TOKEN_NUMBER, $00, $1E ; GOSUB 30
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    
    !byte TOKEN_NUMBER, $00, $14        ; Line number 20
    !byte KW_PRINT, TOKEN_NUMBER, $00, $63 ; PRINT 99
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    
    !byte TOKEN_NUMBER, $00, $1E        ; Line number 30
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A ; PRINT 42
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    
    !byte TOKEN_NUMBER, $00, $28        ; Line number 40
    !byte KW_RETURN                     ; RETURN
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END
