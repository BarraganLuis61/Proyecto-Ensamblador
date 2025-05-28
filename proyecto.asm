section .text
  global mover_jugador

;Constantes
%define FILAS 10
%define COLUMNAS 12

;int mover_jugador(char laberinto[FILAS][COLUMNAS],int x, int y, char letra)
;Windows x64 calling convention:
; RCX = laberinto
; RDX = x
; R8 = y
; R9 = tecla
mover_jugador:
    push rbp
    mov rbp, rsp
    push rbx        ; Preservar registros no volátiles
    push rsi
    push rdi
    
    ; Extraer parámetros
    mov rdi, rcx    ; rdi = laberinto
    mov esi, edx    ; esi = x
    mov edx, r8d    ; edx = y
    movzx ecx, r9b  ; ecx = tecla (solo el byte bajo)
    
    ; Guardar posición original
    mov r8d, esi    ; r8d = x original
    mov r9d, edx    ; r9d = y original
    
    ; Convertir tecla a minúscula si es mayúscula
    cmp cl, 'A'
    jl .verificar_movimiento
    cmp cl, 'Z'
    jg .verificar_movimiento
    add cl, 32      ; Convertir a minúscula
    
.verificar_movimiento:
    ; Mover arriba (W)
    cmp cl, 'w'
    jne .no_w
    dec edx         ; y--
.no_w:
    ; Mover abajo (S)
    cmp cl, 's'
    jne .no_s
    inc edx         ; y++
.no_s:
    ; Mover izquierda (A)
    cmp cl, 'a'
    jne .no_a
    dec esi         ; x--
.no_a:
    ; Mover derecha (D)
    cmp cl, 'd'
    jne .no_d
    inc esi         ; x++
.no_d:
    
    ; Verificar límites
    cmp esi, 0
    jl .restaurar
    cmp esi, COLUMNAS-1
    jge .restaurar
    cmp edx, 0
    jl .restaurar
    cmp edx, FILAS-1
    jge .restaurar
    
    ; Verificar si es pared
    mov eax, edx    ; y
    imul eax, COLUMNAS ; y * COLUMNAS
    add eax, esi    ; + x
    cmp byte [rdi + rax], '#'
    je .restaurar
    
    ; Movimiento válido - preparar retorno
    shl edx, 8      ; y << 8
    or edx, esi     ; (y << 8) | x
    mov eax, edx
    jmp .fin
