; Test programs for Applesoft BASIC interpreter
;
; These are hand-encoded bytecode test cases

*=$1400                        ; Start of program buffer

; Test 1: PRINT "HELLO"
; Bytecode: PRINT string(0)
test_1:
    !byte KW_PRINT, TOKEN_STRING, $00, TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END
    
    ; String pool for test 1
    !text "HELLO"

; Test 2: PRINT 42
; Bytecode: PRINT number(42)
test_2:
    !byte KW_PRINT, TOKEN_NUMBER, $00, $2A, TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END

; Test 3: X=10, PRINT X
; Bytecode: LET X(0)=10, PRINT X(0)
test_3:
    !byte KW_LET, TOKEN_VARIABLE, $00, TOKEN_OPERATOR, OP_EQUAL
    !byte TOKEN_NUMBER, $00, $0A
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_PRINT, TOKEN_VARIABLE, $00
    !byte TOKEN_DELIMITER, DELIM_NEWLINE
    !byte KW_END
