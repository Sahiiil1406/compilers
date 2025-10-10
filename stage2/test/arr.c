#include <stdio.h>

// Global array declarations
int global_array[100];
char string_buffer[256];
float matrix_2d[10][20];
int cube_3d[5][4][3];

int main() {
    // Local array declarations
    int local_int_array[20];
    float local_float_array[10][5];
    char local_char_matrix[7][8][9];
    
    // Array initialization
    int initialized_array[5] = {1, 2, 3, 4, 5};
    char name[20] = "Test String";
    
    // Arrays with computed sizes
    int size = 10;
    // Note: Variable-length arrays would need special handling
    
    // Multi-dimensional array access
    matrix_2d[5][10] = 3.14;
    cube_3d[2][1][0] = 42;
    
    // Array operations
    for (int i = 0; i < 20; i++) {
        local_int_array[i] = i * 2;
    }
    
    // String operations
    printf("Array test: %s\n", name);
    
    return 0;
}