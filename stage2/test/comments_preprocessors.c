/* 
 * Multi-line comment header
 * This file tests comment handling
 * Author: Test Suite
 * Date: 2024
 */
#include <stdio.h>      // Include directive with comment
#include <stdlib.h>     /* Another include with multi-line comment */
// Preprocessor definitions
#define MAX_VALUE 1000  // Maximum allowed value
#define MIN_VALUE 0     /* Minimum allowed value */
#ifndef VERSION
    #define VERSION "1.0"
#endif

// Single line comment before function
int main() {
    int value = 42;     // Variable with inline comment
    
    /* 
     * Multi-line comment in function
     * explaining the logic below
     */
    
    if (value > 0) {    // Positive check
        printf("Positive\n");
        /* Nested comment test:
           /* This should be handled correctly */
           More comment content
        */
    }
    
    // Comment at end of line with code
    int result = value * 2;     // Double the value
    
    /*
     * Block comment with mixed content
     * Special characters: !@#$%^&*()
     * Numbers: 123456789
     * Code-like content: int x = 5;
     */
    
    return 0;   // Return statement comment
}

// Function with extensive comments
/* 
 * Function: calculate_sum
 * Purpose: Adds two integers
 * Parameters: a, b - integers to add
 * Returns: sum of a and b
 */
int calculate_sum(int a, int b) {
    // Perform addition
    return a + b;       /* Return the sum */
}
