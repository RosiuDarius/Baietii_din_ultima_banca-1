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


    msg_sortat db 13, 10, 'sirul a fost sortat descrescator.', 13, 10, '$'
    msg_biti1  db 13, 10, 'octetul cu cei mai multi biti de 1 se afla la pozitia: $'
    max_bits   db 0                ; retine numarul maxim de biti gasit
    pos_max    db 0                ; retine pozitia octetului respectiv

    msg_rotire db 13, 10, 'sirul dupa rotiri: ', 13, 10, '$'
    msg_bin    db ' (binar): $'
    msg_hex    db ' (hex): $'
    new_line   db 13, 10, '$'



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
    or dl, al          ; acumulare or 
    or dl, al          ; acumulare or
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
    xchg dh, dl        ; pregatire afisare hex 
    call afisare_hex_16


    xchg dh, dl        ; pregatire afisare hex
    call afisare_hex_16

    ; sortare descrescatoare 
    mov cl, nr_octeti
    dec cl             
sort_exterior:
    push cx
    lea si, sir_octeti
sort_interior:
    mov al, [si]
    cmp al, [si+1]     
    jae nu_schimba     
    xchg al, [si+1]    
    mov [si], al
nu_schimba:
    inc si
    loop sort_interior
    pop cx
    loop sort_exterior

    mov ah, 09h
    lea dx, msg_sortat
    int 21h

    ; gasire octet cu numar maxim de biti
    xor bx, bx         
    mov cl, nr_octeti
    mov ch, 0
find_max_bits:
    mov al, sir_octeti[bx]
    push cx
    xor dl, dl         ; dl numara bitii de 1
    mov cx, 8
numara_biti:
    shl al, 1          ; extragem bitul in carry
    adc dl, 0          ; adunam carry la dl
    loop numara_biti

    cmp dl, max_bits
    jbe nu_e_maxim
    mov max_bits, dl
    mov pos_max, bl    ; salvam pozitia
nu_e_maxim:
    pop cx
    inc bl
    loop find_max_bits

    ; afisare pozitie
    mov ah, 09h
    lea dx, msg_biti1
    int 21h
    mov al, pos_max
    add al, '0'        ; convertim in caracter
    mov dl, al
    mov ah, 02h
    int 21h

    mov ah, 09h
    lea dx, msg_rotire
    int 21h

    xor bx, bx         ; index sir
    mov cl, nr_octeti
    mov ch, 0

loop_rotiri:
    mov al, sir_octeti[bx]
    push cx

    ; calcul n = suma primilor 2 biti ai octetului
    mov dl, al
    rol dl, 1          ; aducem bitul 7 in carry
    mov dh, 0
    adc dh, 0          ; dh = bit 7
    rol dl, 1          ; aducem bitul 6 in carry
    adc dh, 0          ; dh = bit 7 + bit 6 (rezultatul n)

    ; rotire spre stanga cu n pozitii
    mov cl, dh         ; cl = n
    rol al, cl         ; rotire circulara
    mov sir_octeti[bx], al ; salvam inapoi in sir

    ; afisare binar
    mov ah, 09h
    lea dx, msg_bin
    int 21h

    mov al, sir_octeti[bx]
    call afisare_bin_8

    ; afisare hex
    mov ah, 09h
    lea dx, msg_hex
    int 21h

    mov dl, sir_octeti[bx]
    call afisare_hex_8

    ; trecere la rand nou
    mov ah, 09h
    lea dx, new_line
    int 21h

    pop cx
    inc bx
    loop loop_rotiri



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

afisare_bin_8 proc    ; afiseaza al in binar
    push cx
    mov cx, 8
    mov bl, al
loop_bin:
    rol bl, 1
    mov dl, '0'
    adc dl, 0
    mov ah, 02h
    int 21h
    loop loop_bin
    pop cx
    ret
afisare_bin_8 endp

afisare_hex_8 proc    ; afiseaza dl in hex
    push cx
    mov al, dl
    shr al, 4         ; nibble superior
    call hex_digit
    mov al, dl
    and al, 0fh       ; nibble inferior
    call hex_digit
    pop cx
    ret
afisare_hex_8 endp

hex_digit proc        ; afiseaza cifra hex din al
    add al, '0'
    cmp al, '9'
    jbe print_d
    add al, 7
print_d:
    mov dl, al
    mov ah, 02h
    int 21h
    ret
hex_digit endp

end start