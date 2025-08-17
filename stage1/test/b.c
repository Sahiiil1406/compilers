#include <stdlib.h>

/* Nested comment test 
   /* This is a nested comment */


struct Point {
    int x, y;
};

union Data {
    int i;
    float f;
    char str[20];
};

int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

int main() {
    // Various numeric constants
    int decimal = 42;
    int hex = 0xFF;
    int octal = 0755;
    float scientific = 1.5e-10;
    
    struct Point p = {10, 20};
    union Data data;
    
    // Various operators
    int a = 5, b = 10;
    int result = (a++ <= b--) ? a : b;
    
    // Bitwise operations
    int mask = 0x0F;
    int value = (mask << 4) | 0x0A;
    value >>= 2;
    value &= ~mask;
    
    // Pointer operations
    int *ptr = &a;
    int val = *ptr;
    
    // String with escape sequences
    char *msg = "Line1\nLine2\tTabbed\"Quoted\"";
    
    return factorial(5);
}