#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <windows.h>

#define FILAS 10
#define COLUMNAS 12

// Declaración de la función ensamblador
extern int mover_jugador(char laberinto[FILAS][COLUMNAS], int x, int y, char tecla);

// Laberinto como matriz 2D
char laberinto[FILAS][COLUMNAS] = {
    {'#','#','#','#','#','#','#','#','#','#','#','#'},
    {'#','.','.','.','.','.','.','#','.','.','.','#'},
    {'#','.','#','#','#','#','.','#','#','#','.','#'},
    {'#','.','.','#','.','.','.','#','.','#','.','#'},
    {'#','.','#','#','.','#','#','#','.','.','.','#'},
    {'#','.','#','.','.','#','.','.','.','#','.','#'},
    {'#','.','#','#','#','#','.','#','#','#','.','#'},
    {'#','.','.','.','.','.','.','.','.','#','.','#'},
    {'#','.','#','#','#','.','#','#','.','.','X','#'},
    {'#','#','#','#','#','#','#','#','#','#','#','#'}
};

//  Limpiar pantalla (sin usar system("cls"))
void limpiar_pantalla() {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    DWORD count, cellCount;
    COORD homeCoords = { 0, 0 };

    if (hConsole == INVALID_HANDLE_VALUE) return;
    if (!GetConsoleScreenBufferInfo(hConsole, &csbi)) return;

    cellCount = csbi.dwSize.X * csbi.dwSize.Y;
    FillConsoleOutputCharacter(hConsole, ' ', cellCount, homeCoords, &count);
    FillConsoleOutputAttribute(hConsole, csbi.wAttributes, cellCount, homeCoords, &count);
    SetConsoleCursorPosition(hConsole, homeCoords);
}

// Leer tecla sin ENTER
char leer_tecla() {
    HANDLE hInput = GetStdHandle(STD_INPUT_HANDLE);
    DWORD mode = 0;
    GetConsoleMode(hInput, &mode);
    SetConsoleMode(hInput, mode & ~(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT));

    char c = 0;
    DWORD read;
    ReadConsoleA(hInput, &c, 1, &read, NULL);

    SetConsoleMode(hInput, mode); // Restaurar modo original
    return c;
}

// Mostrar el laberinto y al jugador con espacios
void mostrar_laberinto(int x, int y) {
    limpiar_pantalla();

    printf("=== LABERINTO ===\n");
    printf("Usa W/A/S/D para moverte. Presiona Q para salir -> A JUGAR !!\n\n");

    for (int i = 0; i < FILAS; i++) {
        for (int j = 0; j < COLUMNAS; j++) {
            if (i == y && j == x) {
                printf("P ");
            } else {
                printf("%c ", laberinto[i][j]);
            }
        }
        printf("\n");
    }

    printf("\nTú estas en : X = %d, Y = %d\n", x, y);
}

int main() {
    int jugar = 1; // Nueva variable para controlar si quiere jugar otra vez

    while (jugar) { // Bucle principal para repetir el juego
        int x = 1, y = 1; // Resetear posición inicial
        char tecla;

        while (1) {
            mostrar_laberinto(x, y);

            if (laberinto[y][x] == 'X') {
                printf("\n ---------------------------\n");
                printf("\n         GANASTE             \n");

                printf("\n¿Quieres jugar de nuevo (r) o salir (q)?\n");
                char opcion = leer_tecla();

                if (opcion == 'r' || opcion == 'R') {
                    break; // salir de este while (se reinicia el juego)
                } else {
                    printf("\n HAS TERMINADO EL JUEGO \n");
                    jugar = 0; // salir completamente del juego
                    break;
                }
            }

            tecla = leer_tecla();

            if (tecla == 'q' || tecla == 'Q') {
                printf("\n HAS TERMINADO EL JUEGO \n");
                jugar = 0; // salir completamente
                break;
            }

            int nueva_pos = mover_jugador(laberinto, x, y, tecla);
            x = nueva_pos & 0xFF;
            y = (nueva_pos >> 8) & 0xFF;
        }
    }

    return 0;
}

