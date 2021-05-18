; =============================
; Dimigo Operating System (DOS)
; Copyright (C) 2021 Rok
; =============================

    BITS    16
    ORG     7C00h

start:
    mov     ax, 0003h
    int     10h

    call    print_logo
    mov     si, hello
    call    print_string

.repeat:
    mov     si, prompt
    call    print_string
    call    scan_string

    mov     si, jatoe
    call    compare_strings
    cmp     ax, 0
    jne     .exit

    jmp     .repeat

.exit:
    call    shutdown
    jmp     $


shutdown:
    mov     ax, 1000h
    mov     ax, ss
    mov     sp, 0F000h
    mov     ax, 5307h
    mov     bx, 0001h
    mov     cx, 0003h
    int     15h
    ret


print_string:
    mov     ah, 0Eh

.repeat:
    lodsb
    cmp     al, 0
    je      .exit
    int     10h
    jmp     .repeat

.exit:
    ret


scan_string:
    xor     bx, bx

.wait:
    mov     ah, 01h
    int     16h
    cmp     al, 0
    je      .wait

    mov     ah, 00h
    int     16h
    cmp     al, 8
    je      .back
    cmp     al, 13
    je      .enter
    mov     ah, 0Eh
    int     10h
    mov     byte [di + bx], al
    inc     bx
    jmp     .wait

.back:
    cmp     bx, 0
    jle     .wait
    dec     bx
    mov     ah, 0Eh
    mov     al, 8
    int     10h
    mov     al, 0
    int     10h
    mov     al, 8
    int     10h
    jmp     .wait

.enter:
    mov     byte [di + bx], 0
    mov     ah, 0Eh
    mov     al, 13
    int     10h
    mov     al, 10
    int     10h
    ret


compare_strings:
    xor     bx, bx

.repeat:
    mov     ah, byte [si + bx]
    mov     al, byte [di + bx]
    cmp     ah, al
    jne     .false

    cmp     ah, 0
    je      .true
    inc     bx
    jmp     .repeat

.true:
    mov     ax, 0001h
    ret
.false:
    mov     ax, 0000h
    ret


print_logo:
    mov     si, logo
    mov     al, '#'
    mov     bh, 0
    mov     bl, 13
    mov     cx, 1
    mov     dx, 0

.repeat:
    lodsb
    cmp     al, 0
    je      .exit
    cmp     al, 1
    je      .sp
    cmp     al, 2
    je      .bl
    cmp     al, 3
    je      .nl

.exit:
    mov     ah, 02h
    mov     dh, 9
    mov     dl, 0
    int     10h
    ret

.sp:
    inc     dl
    jmp     .repeat

.bl:
    mov     ah, 02h
    int     10h
    mov     ah, 09h
    int     10h
    inc     dl
    jmp     .repeat

.nl:
    inc     dh
    xor     dl, dl
    jmp     .repeat


logo    db 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 1, 2, 2, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 3, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 2, 2, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 3, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 3, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0
hello   db 'Hello from DimigOS', 13, 10, 10, 0
prompt  db '$ ', 0
jatoe   db 'jatoe', 0

    times   510-($-$$) db 0
    dw      0AA55h