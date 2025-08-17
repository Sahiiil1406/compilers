%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

#define MAX_SYMBOLS 1000
#define MAX_CONSTANTS 1000
#define MAX_KEYWORDS 32

typedef struct {
    char name[100];
    char type[20];          // variable, function, array
    char data_type[20];     // int, char, float, etc.
    char dimensions[50];    // for arrays: [10][20]
    int size;               // calculated size for arrays
    int dimension_count;    // number of dimensions
    int frequency;
    char return_type[20];   // for functions only
    int param_count;        // for functions only (count not details)
    int line_declared;
} Symbol;

typedef struct {
    char value[100];
    char type[20];
    int line_number;
} Constant;

// Global arrays and counters
Symbol symbols[MAX_SYMBOLS];
Constant constants[MAX_CONSTANTS];
int symbol_count = 0;
int constant_count = 0;

// Global state variables
int line_number = 1;
int error_count = 0;
int comment_depth = 0;

// Parser state
char current_data_type[20] = "";
char current_identifier[100] = "";
int expecting_identifier = 0;
int in_function_params = 0;
int paren_depth = 0;
int bracket_depth = 0;
char dimension_buffer[50] = "";

// Function prototypes
void add_symbol(char* name, char* type, char* data_type, char* dimensions, char* return_type, int param_count);
void add_constant(char* value, char* type);
int find_symbol(char* name);
void print_tables();
void print_token(char* token_type, char* lexeme);
void handle_error(char* message);
int is_valid_identifier(char* str);
int is_keyword(char* str);
int is_data_type(char* str);
void process_function(char* name, char* return_type);
void process_array(char* name, char* data_type, char* dimensions);
void process_variable(char* name, char* data_type);
int calculate_array_size(char* dimensions, char* data_type);
int count_dimensions(char* dimensions);
void reset_state();

// Keywords array for validation
char* keywords[] = {
    "auto", "break", "case", "char", "const", "continue", "default", "do",
    "double", "else", "enum", "extern", "float", "for", "goto", "if",
    "int", "long", "register", "return", "short", "signed", "sizeof", "static",
    "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"
};

%}

%option noyywrap
%option yylineno

DIGIT           [0-9]
LETTER          [a-zA-Z_]
ALNUM           [a-zA-Z0-9_]
HEXDIGIT        [0-9a-fA-F]
OCTDIGIT        [0-7]

IDENTIFIER      {LETTER}{ALNUM}*
INTEGER         {DIGIT}+
FLOAT           {DIGIT}*"."{DIGIT}+([eE][+-]?{DIGIT}+)?
HEX_INTEGER     0[xX]{HEXDIGIT}+
OCT_INTEGER     0{OCTDIGIT}*
CHAR_LITERAL    '([^'\\]|\\[\\'"?abfnrtv]|\\[0-7]{1,3}|\\x{HEXDIGIT}+)'
STRING_LITERAL  \"([^\"\\]|\\[\\'"?abfnrtv]|\\[0-7]{1,3}|\\x{HEXDIGIT}+)*\"
WHITESPACE      [ \t]+
NEWLINE         \n

%x COMMENT
%x LINE_COMMENT

%%

    /* Preprocessor directives */
^[ \t]*#[ \t]*[a-zA-Z_][a-zA-Z0-9_]*.*    { print_token("PREPROCESSOR", yytext); }

    /* Keywords and data types */
auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while {
    print_token("KEYWORD", yytext);
    if (is_data_type(yytext)) {
        strncpy(current_data_type, yytext, sizeof(current_data_type) - 1);
        current_data_type[sizeof(current_data_type) - 1] = '\0';
        expecting_identifier = 1;
    }
}

    /* Comments */
"/*"            { 
                    comment_depth = 1; 
                    BEGIN(COMMENT); 
                }

<COMMENT>{
    "/*"        { comment_depth++; }
    "*/"        { 
                    comment_depth--; 
                    if (comment_depth == 0) {
                        BEGIN(INITIAL);
                    }
                }
    \n             { line_number++; }
    .               { /* consume comment content */ }
    <<EOF>>         { 
                    handle_error("Unterminated multi-line comment"); 
                    BEGIN(INITIAL); 
                    return 0; 
                }
}

    /* Single line comments */
"//"            { BEGIN(LINE_COMMENT); }

<LINE_COMMENT>{
    \n             { line_number++; BEGIN(INITIAL); }
    .               { /* consume comment content */ }
}

    /* Multi-character operators */
"++"|"--"|"+="|"-="|"*="|"/="|"%="|"=="|"!="|"<="|">="|"&&"|"||"|"<<"|">>"|"&="|"|="|"^="|"<<="|">>="|"->" {
    print_token("OPERATOR", yytext);
}

    /* Single character operators */
"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"!"|"&"|"|"|"^"|"~"|"?"|":"    { print_token("OPERATOR", yytext); }

    /* Punctuation with state management */
"(" {
    print_token("PUNCTUATION", yytext);
    if (expecting_identifier && strlen(current_identifier) > 0) {
        in_function_params = 1;
        paren_depth = 1;
    }
}

")" {
    print_token("PUNCTUATION", yytext);
    if (in_function_params) {
        paren_depth--;
        if (paren_depth == 0) {
            process_function(current_identifier, current_data_type);
            reset_state();
        }
    }
}

"[" {
    print_token("PUNCTUATION", yytext);
    if (expecting_identifier && strlen(current_identifier) > 0) {
        bracket_depth++;
        if (strlen(dimension_buffer) < sizeof(dimension_buffer) - 2) {
            strcat(dimension_buffer, "[");
        }
    }
}

"]" {
    print_token("PUNCTUATION", yytext);
    if (bracket_depth > 0) {
        if (strlen(dimension_buffer) < sizeof(dimension_buffer) - 2) {
            strcat(dimension_buffer, "]");
        }
        bracket_depth--;
        // Don't process array until all dimensions are closed
        // This handles multi-dimensional arrays like int arr[10][20][30];
    }
}

";" {
    print_token("PUNCTUATION", yytext);
    if (expecting_identifier && strlen(current_identifier) > 0) {
        if (strlen(dimension_buffer) > 0 && bracket_depth == 0) {
            // Multi-dimensional array declaration
            process_array(current_identifier, current_data_type, dimension_buffer);
        } else if (!in_function_params) {
            // Regular variable declaration
            process_variable(current_identifier, current_data_type);
        }
    }
    reset_state();
}

"{"|"}"             { print_token("PUNCTUATION", yytext); }

";" {
    print_token("PUNCTUATION", yytext);
    if (expecting_identifier && strlen(current_identifier) > 0) {
        if (strlen(dimension_buffer) > 0 && bracket_depth == 0) {
            // Multi-dimensional array declaration
            process_array(current_identifier, current_data_type, dimension_buffer);
        } else if (!in_function_params) {
            // Regular variable declaration
            process_variable(current_identifier, current_data_type);
        }
    }
    reset_state();
}

","|"."             { print_token("PUNCTUATION", yytext); }

    /* Constants */
{HEX_INTEGER} {
    print_token("HEX_CONSTANT", yytext);
    add_constant(yytext, "hex_integer");
    if (bracket_depth > 0 && strlen(dimension_buffer) + strlen(yytext) < sizeof(dimension_buffer) - 1) {
        strcat(dimension_buffer, yytext);
    }
}

{OCT_INTEGER} {
    print_token("OCT_CONSTANT", yytext);
    add_constant(yytext, "oct_integer");
    if (bracket_depth > 0 && strlen(dimension_buffer) + strlen(yytext) < sizeof(dimension_buffer) - 1) {
        strcat(dimension_buffer, yytext);
    }
}

{FLOAT} {
    print_token("FLOAT_CONSTANT", yytext);
    add_constant(yytext, "float");
}

{INTEGER} {
    print_token("INTEGER_CONSTANT", yytext);
    add_constant(yytext, "integer");
    if (bracket_depth > 0 && strlen(dimension_buffer) + strlen(yytext) < sizeof(dimension_buffer) - 1) {
        strcat(dimension_buffer, yytext);
    }
}

{CHAR_LITERAL} {
    print_token("CHAR_CONSTANT", yytext);
    add_constant(yytext, "char");
}

{STRING_LITERAL} {
    print_token("STRING_CONSTANT", yytext);
    add_constant(yytext, "string");
}

    /* Identifiers */
{IDENTIFIER} {
    if (is_valid_identifier(yytext)) {
        if (is_keyword(yytext)) {
            print_token("KEYWORD", yytext);
            if (is_data_type(yytext)) {
                strncpy(current_data_type, yytext, sizeof(current_data_type) - 1);
                current_data_type[sizeof(current_data_type) - 1] = '\0';
                expecting_identifier = 1;
            }
        } else {
            print_token("IDENTIFIER", yytext);
            if (expecting_identifier) {
                strncpy(current_identifier, yytext, sizeof(current_identifier) - 1);
                current_identifier[sizeof(current_identifier) - 1] = '\0';
            } else if (!in_function_params) {
                add_symbol(yytext, "identifier", "", "", "", 0);
            }
        }
    } else {
        handle_error("Invalid identifier format");
    }
}

    /* Whitespace and newlines */
{WHITESPACE}        { /* ignore whitespace */ }
{NEWLINE}           { line_number++; }

    /* Error handling for invalid characters */
.                   { 
                      char error_msg[150];
                      snprintf(error_msg, sizeof(error_msg), "Invalid character '%c' (ASCII %d)", *yytext, *yytext);
                      handle_error(error_msg);
                    }

%%

void print_token(char* token_type, char* lexeme) {
    printf("Line %d: %-20s %s\n", line_number, token_type, lexeme);
}

void handle_error(char* message) {
    printf("ERROR at line %d: %s\n", line_number, message);
    error_count++;
}

int is_valid_identifier(char* str) {
    if (!str || !*str) return 0;
    
    // First character must be letter or underscore
    if (!isalpha(*str) && *str != '_') return 0;
    
    // Check length
    if (strlen(str) > 99) return 0;
    
    // Rest must be alphanumeric or underscore
    for (int i = 1; str[i]; i++) {
        if (!isalnum(str[i]) && str[i] != '_') return 0;
    }
    
    return 1;
}

int is_keyword(char* str) {
    for (int i = 0; i < MAX_KEYWORDS; i++) {
        if (strcmp(str, keywords[i]) == 0) return 1;
    }
    return 0;
}

int is_data_type(char* str) {
    char* types[] = {"auto", "char", "const", "double", "extern", "float", "int", 
                     "long", "register", "short", "signed", "static", "struct", 
                     "typedef", "union", "unsigned", "void", "volatile"};
    
    for (int i = 0; i < 18; i++) {
        if (strcmp(str, types[i]) == 0) return 1;
    }
    return 0;
}

void reset_state() {
    memset(current_data_type, 0, sizeof(current_data_type));
    memset(current_identifier, 0, sizeof(current_identifier));
    memset(dimension_buffer, 0, sizeof(dimension_buffer));
    expecting_identifier = 0;
    in_function_params = 0;
    paren_depth = 0;
    bracket_depth = 0;
}

int calculate_array_size(char* dimensions, char* data_type) {
    if (!dimensions || !*dimensions || !data_type || !*data_type) return 0;
    
    int total_size = 1;
    int type_size;
    
    // Determine type size
    if (strcmp(data_type, "char") == 0) type_size = 1;
    else if (strcmp(data_type, "short") == 0) type_size = 2;
    else if (strcmp(data_type, "int") == 0) type_size = 4;
    else if (strcmp(data_type, "long") == 0) type_size = 8;
    else if (strcmp(data_type, "float") == 0) type_size = 4;
    else if (strcmp(data_type, "double") == 0) type_size = 8;
    else type_size = 4; // default
    
    // Parse all dimensions: [10][20][30] -> 10, 20, 30
    char temp[50];
    strncpy(temp, dimensions, sizeof(temp) - 1);
    temp[sizeof(temp) - 1] = '\0';
    
    char* ptr = temp;
    while (*ptr) {
        if (*ptr == '[') {
            ptr++; // skip '['
            char* start = ptr;
            
            // Find the closing ']'
            while (*ptr && *ptr != ']') ptr++;
            
            if (*ptr == ']') {
                *ptr = '\0'; // terminate the number string
                
                if (*start && isdigit(*start)) {
                    int dim_size = atoi(start);
                    if (dim_size > 0 && total_size <= INT_MAX / dim_size) {
                        total_size *= dim_size;
                    } else {
                        return -1; // overflow or invalid dimension
                    }
                }
                ptr++; // skip past ']'
            }
        } else {
            ptr++;
        }
    }
    
    if (total_size <= INT_MAX / type_size) {
        return total_size * type_size;
    }
    return -1; // overflow
}

int count_dimensions(char* dimensions) {
    if (!dimensions) return 0;
    
    int count = 0;
    char* ptr = dimensions;
    
    // Count opening brackets to determine dimension count
    while (*ptr) {
        if (*ptr == '[') {
            count++;
        }
        ptr++;
    }
    return count;
}

int find_symbol(char* name) {
    if (!name) return -1;
    
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void add_symbol(char* name, char* type, char* data_type, char* dimensions, char* return_type, int param_count) {
    if (!name || !*name || !type) return;
    
    if (symbol_count >= MAX_SYMBOLS) {
        handle_error("Symbol table overflow");
        return;
    }
    
    // Check if symbol already exists
    int existing = find_symbol(name);
    if (existing != -1) {
        symbols[existing].frequency++;
        return;
    }
    
    Symbol* s = &symbols[symbol_count];
    
    // Safe string copying
    strncpy(s->name, name, sizeof(s->name) - 1);
    s->name[sizeof(s->name) - 1] = '\0';
    
    strncpy(s->type, type, sizeof(s->type) - 1);
    s->type[sizeof(s->type) - 1] = '\0';
    
    strncpy(s->data_type, data_type ? data_type : "", sizeof(s->data_type) - 1);
    s->data_type[sizeof(s->data_type) - 1] = '\0';
    
    strncpy(s->dimensions, dimensions ? dimensions : "", sizeof(s->dimensions) - 1);
    s->dimensions[sizeof(s->dimensions) - 1] = '\0';
    
    strncpy(s->return_type, return_type ? return_type : "", sizeof(s->return_type) - 1);
    s->return_type[sizeof(s->return_type) - 1] = '\0';
    
    // Calculate array properties
    s->size = 0;
    s->dimension_count = 0;
    if (dimensions && *dimensions) {
        s->size = calculate_array_size(dimensions, data_type);
        s->dimension_count = count_dimensions(dimensions);
    }
    
    s->param_count = param_count;
    s->frequency = 1;
    s->line_declared = line_number;
    
    symbol_count++;
}

void process_function(char* name, char* return_type) {
    if (!name || !*name) return;
    add_symbol(name, "function", "", "", return_type, 0);
}

void process_array(char* name, char* data_type, char* dimensions) {
    if (!name || !*name || !data_type || !dimensions) return;
    add_symbol(name, "array", data_type, dimensions, "", 0);
}

void process_variable(char* name, char* data_type) {
    if (!name || !*name || !data_type) return;
    add_symbol(name, "variable", data_type, "", "", 0);
}

void add_constant(char* value, char* type) {
    if (!value || !*value || !type || constant_count >= MAX_CONSTANTS) return;
    
    Constant* c = &constants[constant_count];
    
    strncpy(c->value, value, sizeof(c->value) - 1);
    c->value[sizeof(c->value) - 1] = '\0';
    
    strncpy(c->type, type, sizeof(c->type) - 1);
    c->type[sizeof(c->type) - 1] = '\0';
    
    c->line_number = line_number;
    constant_count++;
}

void print_tables() {
    printf("\n==================== SYMBOL TABLE ====================\n");
    printf("%-20s %-10s %-12s %-12s %-8s %-5s %-4s %-8s\n", 
           "Name", "Type", "Data Type", "Dimensions", "Size", "Dims", "Freq", "Line");
    printf("------------------------------------------------------------------------------\n");
    
    for (int i = 0; i < symbol_count; i++) {
        printf("%-20s %-10s %-12s %-12s %-8d %-5d %-4d %-8d\n",
               symbols[i].name, symbols[i].type, symbols[i].data_type, 
               symbols[i].dimensions, symbols[i].size, symbols[i].dimension_count,
               symbols[i].frequency, symbols[i].line_declared);
    }
    
    printf("\n==================== FUNCTIONS ====================\n");
    printf("%-25s %-15s %-8s\n", "Function", "Return Type", "Line");
    printf("--------------------------------------------------\n");
    
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].type, "function") == 0) {
            printf("%-25s %-15s %-8d\n",
                   symbols[i].name, symbols[i].return_type, symbols[i].line_declared);
        }
    }
    
    printf("\n==================== ARRAYS ====================\n");
    printf("%-20s %-12s %-15s %-8s %-5s\n", "Array", "Data Type", "Dimensions", "Size", "Dims");
    printf("-----------------------------------------------------------\n");
    
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].type, "array") == 0) {
            printf("%-20s %-12s %-15s %-8d %-5d\n",
                   symbols[i].name, symbols[i].data_type, symbols[i].dimensions,
                   symbols[i].size, symbols[i].dimension_count);
        }
    }
    
    printf("\n==================== VARIABLES ====================\n");
    printf("%-20s %-15s %-8s\n", "Variable", "Data Type", "Line");
    printf("---------------------------------------------\n");
    
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbols[i].type, "variable") == 0) {
            printf("%-20s %-15s %-8d\n",
                   symbols[i].name, symbols[i].data_type, symbols[i].line_declared);
        }
    }
    
    printf("\n==================== CONSTANTS ====================\n");
    printf("%-30s %-15s %-8s\n", "Value", "Type", "Line");
    printf("-----------------------------------------------------\n");
    
    for (int i = 0; i < constant_count; i++) {
        printf("%-30s %-15s %-8d\n", 
               constants[i].value, constants[i].type, constants[i].line_number);
    }
    printf("==================================================\n");
}

int main(int argc, char** argv) {
    FILE* input_file = NULL;
    
    // Initialize global state
    symbol_count = 0;
    constant_count = 0;
    line_number = 1;
    error_count = 0;
    comment_depth = 0;
    reset_state();
    
    if (argc > 1) {
        input_file = fopen(argv[1], "r");
        if (!input_file) {
            fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
            return 1;
        }
        yyin = input_file;
        printf("==================== ANALYZING FILE: %s ====================\n", argv[1]);
    } else {
        printf("Usage: %s <filename>\n", argv[0]);
        printf("Or enter C code manually (Ctrl+D to end):\n");
        yyin = stdin;
    }
    
    printf("==================== TOKEN ANALYSIS ====================\n");
    
    // Run lexical analysis
    int result = yylex();
    
    if (input_file) {
        fclose(input_file);
    }
    
    printf("\n==================== ANALYSIS COMPLETE ====================\n");
    printf("Lines processed: %d\n", line_number - 1);
    printf("Symbols found: %d\n", symbol_count);
    printf("Constants found: %d\n", constant_count);
    printf("Errors found: %d\n", error_count);
    
    if (symbol_count > 0 || constant_count > 0) {
        print_tables();
    }
    
    printf("\n==================== SUMMARY ====================\n");
    printf("Analysis completed %s\n", error_count == 0 ? "successfully" : "with errors");
    
    return error_count > 0 ? 1 : 0;
}