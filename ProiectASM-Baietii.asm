; Proiect colaborativ ASC
; Realizat de baietii din ultima banca 1

.model small
.stack 100h

.data
    ; mesaje interfata
    msg_intro db 13, 10, ' proiect asm ', 13, 10, 'introduceti octetii in format hex : $'
    msg_c_calc db 13, 10, 'cuvantul c calculat : $'
    
    ; date stocare
    buffer     db 50, 0, 50 dup(0) ; buffer pt citire int 21h, ah=0ah 
    sir_octeti db 16 dup(0)        ; sirul in format binar 
    nr_octeti  db 0                ; numarul de valori introduse 
    cuvant_c   dw 0                ; rezultatul pe 16 biti 

.code
start:
    mov ax, @data
    mov ds, ax

    ; afisare mesaj introducere 
    mov ah, 09h
    lea dx, msg_intro
    int 21h

    ; citire de la tastatura 
    mov ah, 0ah
    lea dx, buffer
    int 21h

    ; conversie ascii hex in binar
    lea si, buffer + 2 
    lea di, sir_octeti
    xor cx, cx         

conv_loop:
    mov al, [si]
    cmp al, 13         ; verificare tasta enter
    je calcul_c
    cmp al, ' '        ; ignorare spatii
    je next_char

    ; conversie prima cifra hex
    call hex_to_bin
    shl al, 4
    mov bl, al

    ; conversie a doua cifra hex
    inc si
    mov al, [si]
    call hex_to_bin
    or al, bl
    
    mov [di], al       ; stocare in sirul binar
    inc di
    inc cl

next_char:
    inc si
    jmp conv_loop

calcul_c:
    mov nr_octeti, cl  ; salvare lungime sir

    ; pas 1: bitii 0-3 (xor)
    ; xor intre primii 4 biti ai primului si ultimii 4 ai ultimului octet
    mov al, sir_octeti[0]
    shr al, 4          
    
    mov bl, cl
    xor bh, bh
    dec bx
    mov dl, sir_octeti[bx] 
    and dl, 0fh        
    
    xor al, dl         
    and al, 0fh
    or byte ptr cuvant_c, al

    ; pas 2: bitii 4-7 (or)
    ; or intre bitii 2-5 ai fiecarui octet
    xor dl, dl         
    lea si, sir_octeti
    mov ch, 0
    mov cl, nr_octeti
or_loop:
    mov al, [si]
    shr al, 2          ; aliniere biti 2-5
    and al, 0fh        
    or dl, al          ; acumulare or [cite: 58]
    inc si
    loop or_loop
    
    shl dl, 4          ; mutare pe pozitiile 4-7
    or byte ptr cuvant_c, dl

    ; pas 3: bitii 8-15 (suma mod 256)
    ; suma tuturor octetilor
    xor al, al
    lea si, sir_octeti
    mov cl, nr_octeti
suma_loop:
    add al, [si]       ; adunarea pe 8 biti face automat mod 256
    inc si
    loop suma_loop
    mov byte ptr cuvant_c + 1, al ; octetul superior al lui c

    ; afisare rezultat c
    mov ah, 09h
    lea dx, msg_c_calc
    int 21h
    
    mov dx, cuvant_c
    xchg dh, dl        ; pregatire afisare hex [cite: 99]
    call afisare_hex_16

    ; aici se termina pasul 1. codul lui alin va incepe dupa aceasta linie.
    mov ah, 4ch
    int 21h

; subrutine

hex_to_bin proc
    cmp al, '9'
    jbe cifra
    sub al, 7          ; ajustare pt litere a-f
cifra:
    sub al, '0'
    ret
hex_to_bin endp

afisare_hex_16 proc    ; afiseaza dx in format hex
    push cx
    mov cx, 4
loop_hex:
    rol dx, 4
    mov al, dl
    and al, 0fh
    add al, '0'
    cmp al, '9'
    jbe print_h
    add al, 7
print_h:
    mov ah, 02h
    push dx
    mov dl, al
    int 21h
    pop dx
    loop loop_hex
    pop cx
    ret
afisare_hex_16 endp

end start