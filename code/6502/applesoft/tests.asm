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

