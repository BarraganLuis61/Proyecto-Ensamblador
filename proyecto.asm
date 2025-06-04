section .text
    global mover_jugador     

; Constantes 
%define FILAS 10
%define COLUMNAS 12

mover_jugador:
    push rbp                 ; Guardamos el puntero base anterior
    mov rbp, rsp             ; Establecemos un nuevo marco de pila
    push rbx                 ; Guardamos registros no volátiles
    push rsi
    push rdi

    ; Extraer parámetros que vienen en los registros:
    mov rdi, rcx             ; rdi = puntero al laberinto
    mov esi, edx             ; esi = posición X del jugador
    mov edx, r8d             ; edx = posición Y del jugador
    movzx ecx, r9b           ; ecx = tecla presionada (solo byte bajo, convertimos a 32 bits)

    ; Guardamos posición original por si no se puede mover
    mov r8d, esi             ; r8d = x original
    mov r9d, edx             ; r9d = y original

    ; Convertimos la tecla a minúscula si es mayúscula (para aceptar W o w, A o a, etc.)
    cmp cl, 'A'              ; ¿Es menor que 'A'?
    jl .verificar_movimiento ; Si es menor, saltamos (no es mayúscula)
    cmp cl, 'Z'              ; ¿Es mayor que 'Z'?
    jg .verificar_movimiento ; Si es mayor, saltamos (no es mayúscula)
    add cl, 32               ; Convertimos a minúscula sumando 32 (ASCII)

.verificar_movimiento:
    ; Si la tecla fue 'w' (arriba)
    cmp cl, 'w'
    jne .no_w                ; Si no es 'w', saltamos
    dec edx                  ; y-- (mover hacia arriba)
.no_w:

    ; Si la tecla fue 's' (abajo)
    cmp cl, 's'
    jne .no_s
    inc edx                  ; y++ (mover hacia abajo)
.no_s:

    ; Si la tecla fue 'a' (izquierda)
    cmp cl, 'a'
    jne .no_a
    dec esi                  ; x-- (mover hacia la izquierda)
.no_a:

    ; Si la tecla fue 'd' (derecha)
    cmp cl, 'd'
    jne .no_d
    inc esi                  ; x++ (mover hacia la derecha)
.no_d:

    ; Verificamos que el nuevo movimiento esté dentro de los límites del laberinto
    cmp esi, 0
    jl .restaurar            ; Si x < 0, regresamos a la posición anterior

    cmp esi, COLUMNAS-1
    jge .restaurar           ; Si x >= columnas, también restauramos

    cmp edx, 0
    jl .restaurar            ; Si y < 0, también restauramos

    cmp edx, FILAS-1
    jge .restaurar           ; Si y >= filas, también restauramos

    ; Calculamos la posición [y][x] en el arreglo lineal del laberinto
    mov eax, edx             ; eax = y
    imul eax, COLUMNAS       ; eax = y * columnas (salto de fila)
    add eax, esi             ; eax = (y * columnas) + x (posición final)
    cmp byte [rdi + rax], '#' ; Verificamos si hay una pared en esa posición
    je .restaurar            ; Si es pared, no nos movemos (saltamos a restaurar)

    ; Movimiento válido: empaquetamos las coordenadas en un solo valor de retorno
    shl edx, 8               ; y << 8 (y pasa a los 8 bits altos)
    or edx, esi              ; combinamos y e x: (y << 8) | x
    mov eax, edx             ; ponemos el resultado en eax (registro de retorno)
    jmp .fin                 ; saltamos al final

.restaurar:
    ; Si el movimiento fue inválido, restauramos la posición anterior
    mov eax, r9d             ; eax = y original
    shl eax, 8               ; y << 8
    or eax, r8d              ; combinamos con x original

.fin:
    ; Restauramos los registros que usamos
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret                      ; Salimos de la función y devolvemos eax

