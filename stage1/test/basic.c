#include <stdio.h>
#include <stdlib.h>
#define MAX_SIZE 100
#define PI 3.14159

int global_var;
char status = 'A';
float temperature = 98.6;
double precision = 2.71828e10;

struct Student {
    int id;
    char name[50];
    float gpa;
};

enum Colors {
    RED = 1,
    GREEN = 2,
    BLUE = 3
};

int main() {
    int count = 42;
    unsigned long big_num = 0x1A2B3C4D;
    short small = 077;
    
    // Basic operations
    count++;
    count += 5;
    count *= 2;
    
    if (count > 50) {
        printf("Count is large\n");
    } else {
        printf("Count is small: %d\n", count);
    }
    
    return 0;
}
