; Applesoft BASIC - Bytecode Token Definitions
;
; Shared by tokenizer, interpreter, and test programs
;

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
