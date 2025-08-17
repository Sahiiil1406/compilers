%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Symbol Table Structure */
typedef struct symbol {
    char name[100];
    char type[50];
    char dimensions[50];
    int frequency;
    char return_type[50];
    char parameters[200];
    struct symbol* next;
} Symbol;

/* Constant Table Structure */
typedef struct constant {
    char name[100];
    int line_number;
    char value[100];
    char type[50];
    struct constant* next;
} Constant;

/* Global variables */
Symbol* symbol_head = NULL;
Constant* constant_head = NULL;
int line_count = 1;
int token_count = 0;

/* Function prototypes */
void add_symbol(char* name, char* type);
void add_constant(char* name, char* value, char* type);
void print_symbol_table();
void print_constant_table();
Symbol* find_symbol(char* name);
void increment_frequency(char* name);
void print_token(char* token_name, char* lexeme);
%}

/* Options */
%option noyywrap

/* Regular expressions for tokens */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]
HEXDIGIT    [0-9a-fA-F]
OCTDIGIT    [0-7]

/* Integer constants */
INTEGER     {DIGIT}+
HEX_INT     0[xX]{HEXDIGIT}+
OCT_INT     0{OCTDIGIT}+

/* Float constants */
FLOAT       {DIGIT}+\.{DIGIT}+([eE][+-]?{DIGIT}+)?
FLOAT_EXP   {DIGIT}+[eE][+-]?{DIGIT}+

/* Identifiers */
IDENTIFIER  {LETTER}{ALNUM}*

/* String and character literals */
STRING      \"([^\"\\]|\\.)*\"
CHAR        \'([^\'\\]|\\.)\'

/* Whitespace */
WHITESPACE  [ \t]+
NEWLINE     \n

/* Single line comment */
SINGLE_COMMENT  \/\/.*

/* Multi-line comment states */
%x COMMENT

%%

/* Keywords */
"auto"          { print_token("KEYWORD", yytext); }
"break"         { print_token("KEYWORD", yytext); }
"case"          { print_token("KEYWORD", yytext); }
"char"          { print_token("KEYWORD", yytext); }
"const"         { print_token("KEYWORD", yytext); }
"continue"      { print_token("KEYWORD", yytext); }
"default"       { print_token("KEYWORD", yytext); }
"do"            { print_token("KEYWORD", yytext); }
"double"        { print_token("KEYWORD", yytext); }
"else"          { print_token("KEYWORD", yytext); }
"enum"          { print_token("KEYWORD", yytext); }
"extern"        { print_token("KEYWORD", yytext); }
"float"         { print_token("KEYWORD", yytext); }
"for"           { print_token("KEYWORD", yytext); }
"goto"          { print_token("KEYWORD", yytext); }
"if"            { print_token("KEYWORD", yytext); }
"int"           { print_token("KEYWORD", yytext); }
"long"          { print_token("KEYWORD", yytext); }
"register"      { print_token("KEYWORD", yytext); }
"return"        { print_token("KEYWORD", yytext); }
"short"         { print_token("KEYWORD", yytext); }
"signed"        { print_token("KEYWORD", yytext); }
"sizeof"        { print_token("KEYWORD", yytext); }
"static"        { print_token("KEYWORD", yytext); }
"struct"        { print_token("KEYWORD", yytext); }
"switch"        { print_token("KEYWORD", yytext); }
"typedef"       { print_token("KEYWORD", yytext); }
"union"         { print_token("KEYWORD", yytext); }
"unsigned"      { print_token("KEYWORD", yytext); }
"void"          { print_token("KEYWORD", yytext); }
"volatile"      { print_token("KEYWORD", yytext); }
"while"         { print_token("KEYWORD", yytext); }

/* Preprocessor directives */
^#.*            { print_token("PREPROCESSOR", yytext); }

/* Operators */
"+"             { print_token("OPERATOR", yytext); }
"-"             { print_token("OPERATOR", yytext); }
"*"             { print_token("OPERATOR", yytext); }
"/"             { print_token("OPERATOR", yytext); }
"%"             { print_token("OPERATOR", yytext); }
"++"            { print_token("OPERATOR", yytext); }
"--"            { print_token("OPERATOR", yytext); }
"="             { print_token("OPERATOR", yytext); }
"+="            { print_token("OPERATOR", yytext); }
"-="            { print_token("OPERATOR", yytext); }
"*="            { print_token("OPERATOR", yytext); }
"/="            { print_token("OPERATOR", yytext); }
"%="            { print_token("OPERATOR", yytext); }
"=="            { print_token("OPERATOR", yytext); }
"!="            { print_token("OPERATOR", yytext); }
"<"             { print_token("OPERATOR", yytext); }
">"             { print_token("OPERATOR", yytext); }
"<="            { print_token("OPERATOR", yytext); }
">="            { print_token("OPERATOR", yytext); }
"&&"            { print_token("OPERATOR", yytext); }
"||"            { print_token("OPERATOR", yytext); }
"!"             { print_token("OPERATOR", yytext); }
"&"             { print_token("OPERATOR", yytext); }
"|"             { print_token("OPERATOR", yytext); }
"^"             { print_token("OPERATOR", yytext); }
"~"             { print_token("OPERATOR", yytext); }
"<<"            { print_token("OPERATOR", yytext); }
">>"            { print_token("OPERATOR", yytext); }
"<<="           { print_token("OPERATOR", yytext); }
">>="           { print_token("OPERATOR", yytext); }
"&="            { print_token("OPERATOR", yytext); }
"|="            { print_token("OPERATOR", yytext); }
"^="            { print_token("OPERATOR", yytext); }
"?"             { print_token("OPERATOR", yytext); }
":"             { print_token("OPERATOR", yytext); }
"->"            { print_token("OPERATOR", yytext); }
"."             { print_token("OPERATOR", yytext); }

/* Punctuation symbols */
"("             { print_token("PUNCTUATION", yytext); }
")"             { print_token("PUNCTUATION", yytext); }
"{"             { print_token("PUNCTUATION", yytext); }
"}"             { print_token("PUNCTUATION", yytext); }
"["             { print_token("PUNCTUATION", yytext); }
"]"             { print_token("PUNCTUATION", yytext); }
";"             { print_token("PUNCTUATION", yytext); }
","             { print_token("PUNCTUATION", yytext); }

/* Constants */
{HEX_INT}       { print_token("HEX_CONSTANT", yytext); 
                  add_constant(yytext, yytext, "HEX_INTEGER"); }

{OCT_INT}       { print_token("OCT_CONSTANT", yytext); 
                  add_constant(yytext, yytext, "OCT_INTEGER"); }

{INTEGER}       { print_token("INTEGER_CONSTANT", yytext); 
                  add_constant(yytext, yytext, "INTEGER"); }

{FLOAT}         { print_token("FLOAT_CONSTANT", yytext); 
                  add_constant(yytext, yytext, "FLOAT"); }

{FLOAT_EXP}     { print_token("FLOAT_CONSTANT", yytext); 
                  add_constant(yytext, yytext, "FLOAT"); }

{STRING}        { print_token("STRING_LITERAL", yytext); 
                  add_constant(yytext, yytext, "STRING"); }

{CHAR}          { print_token("CHAR_LITERAL", yytext); 
                  add_constant(yytext, yytext, "CHARACTER"); }

/* Identifiers */
{IDENTIFIER}    { print_token("IDENTIFIER", yytext); 
                  if (find_symbol(yytext) == NULL) {
                      add_symbol(yytext, "UNKNOWN");
                  } else {
                      increment_frequency(yytext);
                  }
                }

/* Comments */
{SINGLE_COMMENT} { /* Ignore single line comments */ }

"/*"            { BEGIN(COMMENT); }

<COMMENT>{
    "*/"        { BEGIN(INITIAL); }
    "/*"        { /* Handle nested comments */ }
    [^*\n]+     { /* Ignore comment content */ }
    "*"         { /* Ignore single * */ }
    \n          { line_count++; }
}

/* Whitespace and newlines */
{WHITESPACE}    { /* Ignore whitespace */ }
{NEWLINE}       { line_count++; }

/* Error handling */
.               { printf("ERROR: Invalid token '%s' at line %d\n", yytext, line_count); }

%%

/* Function implementations */
void print_token(char* token_name, char* lexeme) {
    printf("%-20s : %-20s (Line: %d)\n", token_name, lexeme, line_count);
    token_count++;
}

void add_symbol(char* name, char* type) {
    Symbol* new_symbol = (Symbol*)malloc(sizeof(Symbol));
    strcpy(new_symbol->name, name);
    strcpy(new_symbol->type, type);
    strcpy(new_symbol->dimensions, "-");
    new_symbol->frequency = 1;
    strcpy(new_symbol->return_type, "-");
    strcpy(new_symbol->parameters, "-");
    new_symbol->next = symbol_head;
    symbol_head = new_symbol;
}

void add_constant(char* name, char* value, char* type) {
    Constant* new_constant = (Constant*)malloc(sizeof(Constant));
    strcpy(new_constant->name, name);
    new_constant->line_number = line_count;
    strcpy(new_constant->value, value);
    strcpy(new_constant->type, type);
    new_constant->next = constant_head;
    constant_head = new_constant;
}

Symbol* find_symbol(char* name) {
    Symbol* current = symbol_head;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void increment_frequency(char* name) {
    Symbol* symbol = find_symbol(name);
    if (symbol != NULL) {
        symbol->frequency++;
    }
}

void print_symbol_table() {
    printf("\n\n=== SYMBOL TABLE ===\n");
    printf("%-15s %-10s %-12s %-10s %-12s %-20s\n", 
           "Name", "Type", "Dimensions", "Frequency", "Return Type", "Parameters");
    printf("---------------------------------------------------------------------------------\n");
    
    Symbol* current = symbol_head;
    while (current != NULL) {
        printf("%-15s %-10s %-12s %-10d %-12s %-20s\n", 
               current->name, current->type, current->dimensions, 
               current->frequency, current->return_type, current->parameters);
        current = current->next;
    }
}

void print_constant_table() {
    printf("\n\n=== CONSTANT TABLE ===\n");
    printf("%-20s %-12s %-20s %-15s\n", 
           "Variable Name", "Line Number", "Value", "Type");
    printf("-----------------------------------------------------------------------\n");
    
    Constant* current = constant_head;
    while (current != NULL) {
        printf("%-20s %-12d %-20s %-15s\n", 
               current->name, current->line_number, current->value, current->type);
        current = current->next;
    }
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            printf("Error: Cannot open file %s\n", argv[1]);
            return 1;
        }
        yyin = file;
        printf("Analyzing file: %s\n", argv[1]);
    } else {
        printf("Reading from standard input...\n");
    }
    
    printf("\n=== LEXICAL ANALYSIS ===\n");
    printf("%-20s : %-20s\n", "TOKEN TYPE", "LEXEME");
    printf("--------------------------------------------------------\n");
    
    yylex();
    
    printf("\n\nAnalysis complete!");
    printf("\nTotal tokens found: %d", token_count);
    printf("\nTotal lines processed: %d\n", line_count);
    
    print_symbol_table();
    print_constant_table();
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}