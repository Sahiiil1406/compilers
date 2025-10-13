/*
 * Comprehensive test file with mixed features
 */

#include <stdio.h>
#include <string.h>


// Complex data types and structures
typedef struct {
    int id;
    char name[100];
    float scores[10];
} Student;

typedef union {
    int i;
    float f;
    char c[4];
} DataUnion;

// Function pointers and complex declarations
int (*compare_func)(const void*, const void*);
void (*callback_array[5])(int);

// Global variables with different storage classes
static int static_var = 100;
extern int external_var;
volatile int hardware_flag;
register int fast_counter;

// Arrays with various complexities
int simple_array[50];
float matrix[10][10];
char string_table[20][100];
Student class_roster[30];

// Functions with different signatures
static void internal_helper();
extern int external_function(char* str);
inline int fast_function(register int x);

int main(int argc, char* argv[]) {
    // Local variables
    auto int local_auto = 5;
    const int CONSTANT = 42;
    
    // Pointer declarations
    int* int_ptr;
    char** string_array;
    void* generic_ptr;
    
    // Complex expressions
    int result = (argc > 1) ? atoi(argv[1]) : 0;
    
    // Bitwise operations
    unsigned int flags = 0x0F;
    flags |= 0x10;
    flags &= ~0x01;
    flags ^= 0xFF;
    flags <<= 2;
    flags >>= 1;
    
    // Loop constructs
    for (int i = 0; i < 10; i++) {
        if (i % 2 == 0) continue;
        printf("%d ", i);
        if (i > 7) break;
    }
    
    // Switch statement
    switch (result) {
        case 0:
            printf("Zero\n");
            break;
        case 1:
        case 2:
            printf("Small\n");
            break;
        default:
            printf("Other\n");
    }
    
    // goto statement (rarely used but valid)
    if (result < 0) goto error_handler;
    
    return 0;
    
error_handler:
    fprintf(stderr, "Error occurred\n");
    return -1;
}

// Function definitions
static void internal_helper() {
    static int call_count = 0;
    call_count++;
}

// Macro with parameters
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define SQUARE(x) ((x) * (x))

// Complex array operations
void matrix_operations() {
    int temp_matrix[5][5];
    
    // Initialize matrix
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            temp_matrix[i][j] = i + j;
        }
    }
}