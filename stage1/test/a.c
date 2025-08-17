#include <stdio.h>
#define MAX 100

/* This is a multi-line comment
   demonstrating the scanner's ability
   to handle comments properly */

int main() {
    int x = 10;
    float y = 3.14;
    char str[] = "Hello World";
    char ch = 'A';
    
    // Single line comment
    if (x > 5) {
        printf("x is greater than 5\n");
        y += 2.5;
    }
    
    for (int i = 0; i < MAX; i++) {
        x++;
    }
    
    return 0;
}