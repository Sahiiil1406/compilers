#include <stdio.h>

int main() {
    // Valid code
    int x = 10;
    float y = 3.14;
    
    // Invalid tokens (these will generate errors)
    int @ = 5;        // Invalid identifier starting with @
    int # = 10;       // Invalid identifier starting with #
    
    // Unterminated string (uncomment to test)
    // char *str = "This string is not terminated
    
    // Invalid character literal
    char invalid = '';  // Empty character literal
    
    // Invalid numeric constants
    int bad_hex = 0xGHI;   // Invalid hex digits
    
    // Special characters that might cause issues
    int result = x $ y;    // Invalid operator $
    
    // Valid assignment for comparison
    result = x + y;
    
    return 0;
}