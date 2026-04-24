# Generate full keyword matching code
keywords = [
    ("PRINT", 5),
    ("INPUT", 5),
    ("LET", 3),
    ("GOTO", 4),
    ("IF", 2),
    ("THEN", 4),
    ("FOR", 3),
    ("NEXT", 4),
    ("GOSUB", 5),
    ("RETURN", 6),
    ("REM", 3),
    ("END", 3),
    ("RUN", 3),
    ("NEW", 3),
    ("PLOT", 4),
    ("COLOR", 5),
]

# Generate comparison code for each keyword
for i, (kw, length) in enumerate(keywords):
    print(f"; Try keyword {i}: {kw}")
    print(f"try_kw_{i}:")
    for j, char in enumerate(kw):
        ascii_val = ord(char)
        print(f"    ldy #{j}")
        print(f"    lda ($20), y")
        print(f"    cmp #{ascii_val}        ; '{char}'")
        if j == 0:
            print(f"    bne try_kw_{i+1}")
        else:
            print(f"    bne kw_try_next")
    print(f"    ldy #{length}")
    print(f"    lda ($20), y")
    print(f"    cmp #65                 ; 'A'")
    print(f"    bcc kw_found_{i}")
    print(f"    cmp #91")
    print(f"    bcc kw_try_next")
    print(f"    cmp #48                 ; '0'")
    print(f"    bcc kw_found_{i}")
    print(f"    cmp #58")
    print(f"    bcc kw_try_next")
print(f"try_kw_{len(keywords)}:")
print(f"    bra no_keyword_match")
