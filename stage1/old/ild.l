%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* Enhanced Symbol Table Structure */
typedef struct symbol {
    char name[100];
    char type[50];           // variable, function, array
    char data_type[50];      // int, char, float, void, etc.
    char dimensions[100];    // for arrays: [10][20] or [10]
    int size;               // calculated size for arrays
    int dimension_count;    // number of dimensions
    int frequency;
    char return_type[50];   // for functions
    char parameters[300];   // for functions: detailed parameter list
    int param_count;        // number of parameters
    int line_declared;
    struct symbol* next;
} Symbol;

/* Constant Table Structure */
typedef struct constant {
    char name[100];
    int line_number;
    char value[200];
    char type[50];
    struct constant* next;
} Constant;

/* Global variables */
Symbol* symbol_head = NULL;
Constant* constant_head = NULL;
int line_number = 1;
int error_count = 0;
int comment_depth = 0;
int in_multiline_comment = 0;

/* Parser state variables */
char current_data_type[50] = "";
char current_identifier[100] = "";
int expecting_identifier = 0;
int in_function_params = 0;
int paren_depth = 0;
int bracket_depth = 0;
char param_buffer[300] = "";
char dimension_buffer[100] = "";

/* Function declarations */
void add_symbol(char* name, char* type, char* data_type, char* dimensions, 
                char* return_type, char* parameters, int param_count);
void add_constant(char* name, char* value, char* type);
Symbol* find_symbol(char* name);
void print_symbol_table();
void print_constant_table();
void print_function_table();
void print_array_table();
void print_token(char* token_type, char* lexeme);
void handle_error(char* message);
char* get_keyword_type(char* keyword);
int is_valid_identifier(char* str);
void process_function_declaration(char* name, char* return_type, char* params);
void process_array_declaration(char* name, char* data_type, char* dimensions);
void process_variable_declaration(char* name, char* data_type);
int calculate_array_size(char* dimensions, char* data_type);
int count_array_dimensions(char* dimensions);
void reset_parser_state();
int is_data_type(char* str);

%}

/* Flex options */
%option noyywrap
%option yylineno

/* Regular expressions */
DIGIT           [0-9]
LETTER          [a-zA-Z_]
ALNUM           [a-zA-Z0-9_]
HEXDIGIT        [0-9a-fA-F]
OCTDIGIT        [0-7]

/* Token definitions */
IDENTIFIER      {LETTER}{ALNUM}*
INTEGER         {DIGIT}+
FLOAT           {DIGIT}+"."{DIGIT}+([eE][+-]?{DIGIT}+)?
HEX_INTEGER     0[xX]{HEXDIGIT}+
OCT_INTEGER     0{OCTDIGIT}+
CHAR_LITERAL    '([^'\\]|\\.)'
STRING_LITERAL  \"([^\"\\]|\\.)*\"
WHITESPACE      [ \t]+
NEWLINE         \n

/* States for comments */
%x COMMENT
%x LINE_COMMENT

%%

    /* Preprocessor directives */
^[ \t]*#[ \t]*include.*          { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*define.*           { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*ifdef.*            { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*ifndef.*           { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*if.*               { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*else.*             { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*elif.*             { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*endif.*            { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*undef.*            { print_token("PREPROCESSOR", yytext); }
^[ \t]*#[ \t]*pragma.*           { print_token("PREPROCESSOR", yytext); }

    /* Data type keywords */
auto            { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
char            { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
const           { print_token("KEYWORD", yytext); }
double          { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
extern          { print_token("KEYWORD", yytext); }
float           { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
int             { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
long            { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
register        { print_token("KEYWORD", yytext); }
short           { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
signed          { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
static          { print_token("KEYWORD", yytext); }
struct          { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
typedef         { print_token("KEYWORD", yytext); }
union           { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
unsigned        { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
void            { print_token("KEYWORD", yytext); strcpy(current_data_type, yytext); expecting_identifier = 1; }
volatile        { print_token("KEYWORD", yytext); }

    /* Other keywords */
break           { print_token("KEYWORD", yytext); }
case            { print_token("KEYWORD", yytext); }
continue        { print_token("KEYWORD", yytext); }
default         { print_token("KEYWORD", yytext); }
do              { print_token("KEYWORD", yytext); }
else            { print_token("KEYWORD", yytext); }
enum            { print_token("KEYWORD", yytext); }
for             { print_token("KEYWORD", yytext); }
goto            { print_token("KEYWORD", yytext); }
if              { print_token("KEYWORD", yytext); }
return          { print_token("KEYWORD", yytext); }
sizeof          { print_token("KEYWORD", yytext); }
switch          { print_token("KEYWORD", yytext); }
while           { print_token("KEYWORD", yytext); }

    /* Multi-line comments with nesting support */
"/*"            { 
                  comment_depth = 1; 
                  in_multiline_comment = 1;
                  BEGIN(COMMENT); 
                }

<COMMENT>{
    "/*"        { comment_depth++; }
    "*/"        { 
                  comment_depth--; 
                  if (comment_depth == 0) {
                      in_multiline_comment = 0;
                      BEGIN(INITIAL);
                  }
                }
    \n          { line_number++; }
    .           { /* consume comment content */ }
    <<EOF>>     { 
                  handle_error("Unterminated comment"); 
                  BEGIN(INITIAL); 
                  return 0; 
                }
}

    /* Single line comments */
"//"            { BEGIN(LINE_COMMENT); }

<LINE_COMMENT>{
    \n          { line_number++; BEGIN(INITIAL); }
    .           { /* consume comment content */ }
}

    /* Operators */
"++"            { print_token("OPERATOR", yytext); }
"--"            { print_token("OPERATOR", yytext); }
"+="            { print_token("OPERATOR", yytext); }
"-="            { print_token("OPERATOR", yytext); }
"*="            { print_token("OPERATOR", yytext); }
"/="            { print_token("OPERATOR", yytext); }
"%="            { print_token("OPERATOR", yytext); }
"=="            { print_token("OPERATOR", yytext); }
"!="            { print_token("OPERATOR", yytext); }
"<="            { print_token("OPERATOR", yytext); }
">="            { print_token("OPERATOR", yytext); }
"&&"            { print_token("OPERATOR", yytext); }
"||"            { print_token("OPERATOR", yytext); }
"<<"            { print_token("OPERATOR", yytext); }
">>"            { print_token("OPERATOR", yytext); }
"&="            { print_token("OPERATOR", yytext); }
"|="            { print_token("OPERATOR", yytext); }
"^="            { print_token("OPERATOR", yytext); }
"<<="           { print_token("OPERATOR", yytext); }
">>="           { print_token("OPERATOR", yytext); }
"->"            { print_token("OPERATOR", yytext); }

"+"             { print_token("OPERATOR", yytext); }
"-"             { print_token("OPERATOR", yytext); }
"*"             { print_token("OPERATOR", yytext); }
"/"             { print_token("OPERATOR", yytext); }
"%"             { print_token("OPERATOR", yytext); }
"="             { print_token("OPERATOR", yytext); }
"<"             { print_token("OPERATOR", yytext); }
">"             { print_token("OPERATOR", yytext); }
"!"             { print_token("OPERATOR", yytext); }
"&"             { print_token("OPERATOR", yytext); }
"|"             { print_token("OPERATOR", yytext); }
"^"             { print_token("OPERATOR", yytext); }
"~"             { print_token("OPERATOR", yytext); }
"?"             { print_token("OPERATOR", yytext); }
":"             { print_token("OPERATOR", yytext); }

    /* Punctuation with enhanced parsing */
"("             { 
                  print_token("PUNCTUATION", yytext); 
                  if (expecting_identifier && strlen(current_identifier) > 0) {
                      in_function_params = 1;
                      paren_depth = 1;
                      strcpy(param_buffer, "");
                  }
                }
")"             { 
                  print_token("PUNCTUATION", yytext); 
                  if (in_function_params) {
                      paren_depth--;
                      if (paren_depth == 0) {
                          process_function_declaration(current_identifier, current_data_type, param_buffer);
                          reset_parser_state();
                      }
                  }
                }
"["             { 
                  print_token("PUNCTUATION", yytext); 
                  if (expecting_identifier && strlen(current_identifier) > 0) {
                      bracket_depth++;
                      strcat(dimension_buffer, "[");
                  }
                }
"]"             { 
                  print_token("PUNCTUATION", yytext); 
                  if (bracket_depth > 0) {
                      bracket_depth--;
                      strcat(dimension_buffer, "]");
                      if (bracket_depth == 0) {
                          process_array_declaration(current_identifier, current_data_type, dimension_buffer);
                          reset_parser_state();
                      }
                  }
                }
"{"             { print_token("PUNCTUATION", yytext); }
"}"             { print_token("PUNCTUATION", yytext); }
";"             { 
                  print_token("PUNCTUATION", yytext); 
                  if (expecting_identifier && strlen(current_identifier) > 0 && 
                      !in_function_params && bracket_depth == 0) {
                      process_variable_declaration(current_identifier, current_data_type);
                  }
                  reset_parser_state();
                }
","             { 
                  print_token("PUNCTUATION", yytext); 
                  if (in_function_params) {
                      strcat(param_buffer, ", ");
                  }
                }
"."             { print_token("PUNCTUATION", yytext); }

    /* Constants */
{HEX_INTEGER}   { 
                  print_token("HEX_CONSTANT", yytext); 
                  add_constant("", yytext, "hex_integer");
                  if (bracket_depth > 0) {
                      strcat(dimension_buffer, yytext);
                  }
                }
{OCT_INTEGER}   { 
                  print_token("OCT_CONSTANT", yytext); 
                  add_constant("", yytext, "oct_integer");
                  if (bracket_depth > 0) {
                      strcat(dimension_buffer, yytext);
                  }
                }
{FLOAT}         { 
                  print_token("FLOAT_CONSTANT", yytext); 
                  add_constant("", yytext, "float");
                }
{INTEGER}       { 
                  print_token("INTEGER_CONSTANT", yytext); 
                  add_constant("", yytext, "integer");
                  if (bracket_depth > 0) {
                      strcat(dimension_buffer, yytext);
                  }
                }
{CHAR_LITERAL}  { 
                  print_token("CHAR_CONSTANT", yytext); 
                  add_constant("", yytext, "char");
                }
{STRING_LITERAL} { 
                  print_token("STRING_CONSTANT", yytext); 
                  add_constant("", yytext, "string");
                }

    /* Identifiers */
{IDENTIFIER}    { 
                  if (is_valid_identifier(yytext)) {
                      print_token("IDENTIFIER", yytext);
                      if (expecting_identifier) {
                          strcpy(current_identifier, yytext);
                      } else if (in_function_params) {
                          strcat(param_buffer, yytext);
                      } else {
                          add_symbol(yytext, "identifier", "", "", "", "", 0);
                      }
                  } else {
                      handle_error("Invalid identifier");
                  }
                }

    /* Whitespace */
{WHITESPACE}    { 
                  if (in_function_params) {
                      strcat(param_buffer, " ");
                  }
                }
{NEWLINE}       { line_number++; }

    /* Error handling */
.               { 
                  char error_msg[200];
                  sprintf(error_msg, "Invalid token '%s'", yytext);
                  handle_error(error_msg);
                  if (bracket_depth > 0) {
                      strcat(dimension_buffer, yytext);
                  }
                }

%%

/* Function implementations */
void print_token(char* token_type, char* lexeme) {
    printf("Line %d: %-20s %s\n", line_number, token_type, lexeme);
}

void handle_error(char* message) {
    printf("ERROR at line %d: %s\n", line_number, message);
    error_count++;
}

int is_valid_identifier(char* str) {
    if (!str || strlen(str) == 0) return 0;
    
    // First character must be letter or underscore
    if (!isalpha(str[0]) && str[0] != '_') return 0;
    
    // Rest must be alphanumeric or underscore
    for (int i = 1; i < strlen(str); i++) {
        if (!isalnum(str[i]) && str[i] != '_') return 0;
    }
    
    return 1;
}

int is_data_type(char* str) {
    char* types[] = {"int", "char", "float", "double", "void", "short", "long", 
                     "signed", "unsigned", "auto", "struct", "union"};
    int num_types = sizeof(types) / sizeof(types[0]);
    
    for (int i = 0; i < num_types; i++) {
        if (strcmp(str, types[i]) == 0) return 1;
    }
    return 0;
}

void reset_parser_state() {
    strcpy(current_data_type, "");
    strcpy(current_identifier, "");
    strcpy(param_buffer, "");
    strcpy(dimension_buffer, "");
    expecting_identifier = 0;
    in_function_params = 0;
    paren_depth = 0;
    bracket_depth = 0;
}

int calculate_array_size(char* dimensions, char* data_type) {
    int size = 1;
    int type_size = 4; // default
    
    // Determine type size
    if (strcmp(data_type, "char") == 0) type_size = 1;
    else if (strcmp(data_type, "short") == 0) type_size = 2;
    else if (strcmp(data_type, "int") == 0) type_size = 4;
    else if (strcmp(data_type, "long") == 0) type_size = 8;
    else if (strcmp(data_type, "float") == 0) type_size = 4;
    else if (strcmp(data_type, "double") == 0) type_size = 8;
    
    // Parse dimensions and calculate total size
    char* dim_copy = strdup(dimensions);
    char* token = strtok(dim_copy, "[]");
    
    while (token != NULL) {
        if (strlen(token) > 0 && isdigit(token[0])) {
            size *= atoi(token);
        }
        token = strtok(NULL, "[]");
    }
    
    free(dim_copy);
    return size * type_size;
}

int count_array_dimensions(char* dimensions) {
    int count = 0;
    for (int i = 0; i < strlen(dimensions); i++) {
        if (dimensions[i] == '[') count++;
    }
    return count;
}

void add_symbol(char* name, char* type, char* data_type, char* dimensions, 
                char* return_type, char* parameters, int param_count) {
    Symbol* existing = find_symbol(name);
    if (existing) {
        existing->frequency++;
        return;
    }
    
    Symbol* new_symbol = (Symbol*)malloc(sizeof(Symbol));
    strcpy(new_symbol->name, name);
    strcpy(new_symbol->type, type);
    strcpy(new_symbol->data_type, data_type ? data_type : "");
    strcpy(new_symbol->dimensions, dimensions ? dimensions : "");
    strcpy(new_symbol->return_type, return_type ? return_type : "");
    strcpy(new_symbol->parameters, parameters ? parameters : "");
    
    new_symbol->size = 0;
    new_symbol->dimension_count = 0;
    if (dimensions && strlen(dimensions) > 0) {
        new_symbol->size = calculate_array_size(dimensions, data_type);
        new_symbol->dimension_count = count_array_dimensions(dimensions);
    }
    
    new_symbol->param_count = param_count;
    new_symbol->frequency = 1;
    new_symbol->line_declared = line_number;
    new_symbol->next = symbol_head;
    symbol_head = new_symbol;
}

void process_function_declaration(char* name, char* return_type, char* params) {
    int param_count = 0;
    if (strlen(params) > 0) {
        param_count = 1;
        for (int i = 0; i < strlen(params); i++) {
            if (params[i] == ',') param_count++;
        }
    }
    
    add_symbol(name, "function", "", "", return_type, params, param_count);
}

void process_array_declaration(char* name, char* data_type, char* dimensions) {
    add_symbol(name, "array", data_type, dimensions, "", "", 0);
}

void process_variable_declaration(char* name, char* data_type) {
    add_symbol(name, "variable", data_type, "", "", "", 0);
}

void add_constant(char* name, char* value, char* type) {
    Constant* new_constant = (Constant*)malloc(sizeof(Constant));
    strcpy(new_constant->name, name);
    strcpy(new_constant->value, value);
    strcpy(new_constant->type, type);
    new_constant->line_number = line_number;
    new_constant->next = constant_head;
    constant_head = new_constant;
}

Symbol* find_symbol(char* name) {
    Symbol* current = symbol_head;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void print_symbol_table() {
    printf("\n==================== COMPLETE SYMBOL TABLE ====================\n");
    printf("%-15s %-10s %-12s %-15s %-8s %-8s %-8s %-12s %-30s\n", 
           "Name", "Type", "Data Type", "Dimensions", "Size", "Dims", "Freq", "Return Type", "Parameters");
    printf("---------------------------------------------------------------------------------------------");
    printf("---------------------------------------------------------------------------------------------\n");
    
    Symbol* current = symbol_head;
    while (current) {
        printf("%-15s %-10s %-12s %-15s %-8d %-8d %-8d %-12s %-30s\n",
               current->name,
               current->type,
               current->data_type,
               current->dimensions,
               current->size,
               current->dimension_count,
               current->frequency,
               current->return_type,
               current->parameters);
        current = current->next;
    }
    printf("================================================================================================\n");
}

void print_function_table() {
    printf("\n==================== FUNCTION TABLE ====================\n");
    printf("%-20s %-15s %-8s %-40s\n", 
           "Function Name", "Return Type", "Params", "Parameter Details");
    printf("-------------------------------------------------------------------------\n");
    
    Symbol* current = symbol_head;
    while (current) {
        if (strcmp(current->type, "function") == 0) {
            printf("%-20s %-15s %-8d %-40s\n",
                   current->name,
                   current->return_type,
                   current->param_count,
                   current->parameters);
        }
        current = current->next;
    }
    printf("=========================================================\n");
}

void print_array_table() {
    printf("\n==================== ARRAY TABLE ====================\n");
    printf("%-20s %-12s %-15s %-8s %-8s %-8s\n", 
           "Array Name", "Data Type", "Dimensions", "Size", "Dims", "Line");
    printf("---------------------------------------------------------------\n");
    
    Symbol* current = symbol_head;
    while (current) {
        if (strcmp(current->type, "array") == 0) {
            printf("%-20s %-12s %-15s %-8d %-8d %-8d\n",
                   current->name,
                   current->data_type,
                   current->dimensions,
                   current->size,
                   current->dimension_count,
                   current->line_declared);
        }
        current = current->next;
    }
    printf("======================================================\n");
}

void print_constant_table() {
    printf("\n==================== CONSTANT TABLE ====================\n");
    printf("%-20s %-12s %-30s %-15s\n", 
           "Name", "Line Number", "Value", "Type");
    printf("-----------------------------------------------------------------\n");
    
    Constant* current = constant_head;
    while (current) {
        printf("%-20s %-12d %-30s %-15s\n",
               current->name,
               current->line_number,
               current->value,
               current->type);
        current = current->next;
    }
    printf("=========================================================\n");
}

int main(int argc, char** argv) {
    FILE* input_file;
    
    if (argc > 1) {
        input_file = fopen(argv[1], "r");
        if (!input_file) {
            fprintf(stderr, "Error: Cannot open file %s\n", argv[1]);
            return 1;
        }
        yyin = input_file;
    } else {
        printf("Enter C code (Ctrl+D to end):\n");
        yyin = stdin;
    }
    
    printf("==================== TOKEN ANALYSIS ====================\n");
    yylex();
    
    if (argc > 1) {
        fclose(input_file);
    }
    
    printf("\n==================== ANALYSIS COMPLETE ====================\n");
    printf("Total lines processed: %d\n", line_number - 1);
    printf("Total errors found: %d\n", error_count);
    
    print_symbol_table();
    print_function_table();
    print_array_table();
    print_constant_table();
    
    // Free memory
    Symbol* sym_current = symbol_head;
    while (sym_current) {
        Symbol* temp = sym_current;
        sym_current = sym_current->next;
        free(temp);
    }
    
    Constant* const_current = constant_head;
    while (const_current) {
        Constant* temp = const_current;
        const_current = const_current->next;
        free(temp);
    }
    
    return 0;
}