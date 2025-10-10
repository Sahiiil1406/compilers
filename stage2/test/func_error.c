#include <stdio.h>

// Function declarations
void simple_function();
int add_numbers(int a, int b);
float calculate_area(float radius, int precision);
char* process_string(char* input, int length, float factor);
void complex_func(int arr[], char* str, double* ptr, struct Data info);

// Function with multiple parameters
int multi_param_func(int x, char y, float z, double w, 
                     long v, short u, unsigned int t) {
    return x + y;
}

// Function pointer declaration
int (*operation)(int, int);

// Invalid identifiers and syntax errors
int 123invalid;     // Error: starts with digit
float var-name;     // Error: contains hyphen
char @symbol;       // Error: invalid character

// Function definitions
void simple_function() {
    printf("Simple function called\n");
}

int add_numbers(int a, int b) {
    int result;
    result = a + b;
    return result;
}

float calculate_area(float radius, int precision) {
    const float PI = 3.14159;
    return PI * radius * radius;
}

// Nested function calls
int main() {
    int sum = add_numbers(10, 20);
    float area = calculate_area(5.5, 2);
    
    // Function pointer assignment
    operation = add_numbers;
    int result = operation(15, 25);
    
    return 0;
}

// Incomplete function - missing closing brace
void incomplete_function() {
    int x = 5;
    // Missing }