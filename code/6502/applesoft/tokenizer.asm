; Applesoft BASIC for HBC-56 - Tokenizer
;
; Copyright (c) 2026
; Licensed under MIT
;
; Converts Applesoft BASIC text input into bytecode tokens
;
; Token format:
;   $00-$1F: Keywords (see keyword table)
;   $40: Variable reference ($40 [name_index])
;   $41: Number literal ($41 [msb] [lsb])
;   $42: String literal ($42 [pool_index])
;   $43: Operator ($43 [op_type])
;   $44: Delimiter ($44 [delim_type])
;

; Zero page allocations
tokenizer_ptr      = $20   ; Current position in input buffer
tokenizer_out      = $22   ; Current position in output bytecode
line_num           = $24   ; Current line number being parsed
symbol_count       = $26   ; Number of symbols in table
string_pool_idx    = $27   ; Current string pool index

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

; Operator type values
OP_PLUS            = $00
OP_MINUS           = $01
OP_MULTIPLY        = $02
OP_DIVIDE          = $03
OP_MOD             = $04
OP_EQUAL           = $05
OP_LESS            = $06
OP_GREATER         = $07
OP_LE              = $08
OP_GE              = $09
OP_NE              = $0A
OP_AND             = $0B
OP_OR              = $0C
OP_NOT             = $0D

; Delimiter type values
DELIM_COMMA        = $00
DELIM_COLON        = $01
DELIM_LPAREN       = $02
DELIM_RPAREN       = $03
DELIM_NEWLINE      = $04

; Keyword lookup table
*=$0400            ; Place at fixed address for lookup
keyword_table:
    !text "PRINT", 0
    !text "INPUT", 0
    !text "LET", 0
    !text "GOTO", 0
    !text "IF", 0
    !text "THEN", 0
    !text "FOR", 0
    !text "NEXT", 0
    !text "GOSUB", 0
    !text "RETURN", 0
    !text "REM", 0
    !text "END", 0
    !text "RUN", 0
    !text "NEW", 0
    !text "PLOT", 0
    !text "COLOR", 0

; =============================================================================
; tokenize_line: Parse a line of BASIC text into bytecode
;
; Input:
;   $201 (X register): Pointer to line number (big-endian 16-bit)
;   tokenizer_ptr: Pointer to BASIC text (after line number)
;   tokenizer_out: Pointer to output bytecode buffer
;
; Output:
;   tokenizer_out: Updated with new bytecode
;   Carry: Clear if success, Set if error
; =============================================================================
tokenize_line:
    ; TODO: Implement line number parsing and bytecode output
    ; For now, return success
    clc
    rts

; =============================================================================
; tokenize_keyword: Check if current position matches a keyword
;
; Input:
;   tokenizer_ptr: Pointer to current position in input
;
; Output:
;   Accumulator: Keyword token value ($00-$0F) if match
;   Carry: Clear if match, Set if no match
; =============================================================================
tokenize_keyword:
    ; TODO: Implement keyword matching
    sec
    rts

; =============================================================================
; tokenize_number: Parse a number literal
;
; Input:
;   tokenizer_ptr: Pointer to digit character
;
; Output:
;   X (msb), Y (lsb): 16-bit number value
;   tokenizer_ptr: Updated to next non-digit character
;   Carry: Clear if success
; =============================================================================
tokenize_number:
    ; TODO: Implement number parsing
    clc
    rts

; =============================================================================
; tokenize_string: Parse a string literal
;
; Input:
;   tokenizer_ptr: Pointer to opening quote
;
; Output:
;   Accumulator: String pool index
;   tokenizer_ptr: Updated to after closing quote
;   Carry: Clear if success, Set if unterminated string
; =============================================================================
tokenize_string:
    ; TODO: Implement string parsing
    clc
    rts
