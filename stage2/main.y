%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
extern int line_num;
int yylex();
void yyerror(const char *s);

/* Symbol Table Structure */
typedef struct SymbolTable {
    char name[100];
    char type[50];
    char class[50];
    char boundaries[100];
    int array_dim;
    char params[200];
    int proc_def_flag;
    int nesting_level;
    int line_declared;
    int line_ref[100];
    int ref_count;
    struct SymbolTable *next;
} SymbolTable;

/* Constant Table Structure */
typedef struct ConstantTable {
    char var_name[100];
    int line_num;
    char value[100];
    char type[50];
    struct ConstantTable *next;
} ConstantTable;

/* Header Table Structure */
typedef struct HeaderTable {
    char header_name[200];
    int line_num;
    char type[20]; // "system" or "local"
    struct HeaderTable *next;
} HeaderTable;

/* Macro Table Structure */
typedef struct MacroTable {
    char macro_name[100];
    char macro_value[500];
    int line_num;
    struct MacroTable *next;
} MacroTable;

SymbolTable *symtab_head = NULL;
ConstantTable *consttab_head = NULL;
HeaderTable *headertab_head = NULL;
MacroTable *macrotab_head = NULL;
int current_nesting = 0;
char current_type[50] = "unknown";
char current_class[50] = "variable";

void add_symbol(char *name, char *type, char *class);
void add_constant(char *value, char *type);
void add_header(char *header_name, char *type);
void add_macro(char *name, char *value);
void update_symbol_type(char *name, char *type);
void print_symbol_table();
void print_constant_table();
void print_header_table();
void print_macro_table();
void print_all_tables();
%}

%union {
    char *str;
    int num;
}

/* Keywords */
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM
%token EXTERN FLOAT FOR GOTO IF INT LONG REGISTER RETURN SHORT SIGNED
%token SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE

/* Preprocessor Directives */
%token PREPROCESSOR_DIR PP_INCLUDE PP_DEFINE PP_UNDEF PP_IFDEF PP_IFNDEF
%token PP_IF PP_ELIF PP_ELSE PP_ENDIF PP_ERROR PP_PRAGMA PP_LINE
%token <str> HEADER_NAME

/* Identifiers and Constants */
%token <str> IDENTIFIER INT_CONSTANT FLOAT_CONSTANT CHAR_CONSTANT STRING_LITERAL

/* Operators */
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token PTR_OP ELLIPSIS

%start program

%%

/* Program can start with preprocessor directives */
program
    : translation_unit
    | preprocessor_section translation_unit
    | preprocessor_section
    ;

preprocessor_section
    : preprocessor_directive
    | preprocessor_section preprocessor_directive
    ;

preprocessor_directive
    : PREPROCESSOR_DIR PP_INCLUDE HEADER_NAME         { add_header($3, "system"); }
    | PREPROCESSOR_DIR PP_INCLUDE STRING_LITERAL      { add_header($3, "local"); }
    | PREPROCESSOR_DIR PP_DEFINE IDENTIFIER           { add_macro($3, ""); }
    | PREPROCESSOR_DIR PP_DEFINE IDENTIFIER macro_body
    | PREPROCESSOR_DIR PP_UNDEF IDENTIFIER
    | PREPROCESSOR_DIR PP_IFDEF IDENTIFIER
    | PREPROCESSOR_DIR PP_IFNDEF IDENTIFIER
    | PREPROCESSOR_DIR PP_IF
    | PREPROCESSOR_DIR PP_ELIF
    | PREPROCESSOR_DIR PP_ELSE
    | PREPROCESSOR_DIR PP_ENDIF
    | PREPROCESSOR_DIR PP_ERROR
    | PREPROCESSOR_DIR PP_PRAGMA
    | PREPROCESSOR_DIR PP_LINE
    | PREPROCESSOR_DIR IDENTIFIER                      /* Other preprocessor directives */
    ;

macro_body
    : IDENTIFIER
    | INT_CONSTANT
    | STRING_LITERAL
    | macro_body IDENTIFIER
    | macro_body INT_CONSTANT
    ;

/* Expressions */
primary_expression
    : IDENTIFIER                { add_symbol($1, current_type, current_class); }
    | INT_CONSTANT              { add_constant($1, "int"); }
    | FLOAT_CONSTANT            { add_constant($1, "float"); }
    | CHAR_CONSTANT             { add_constant($1, "char"); }
    | STRING_LITERAL            { add_constant($1, "string"); }
    | '(' expression ')'
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' ')'
    | postfix_expression '(' argument_expression_list ')'
    | postfix_expression '.' IDENTIFIER                { add_symbol($3, "member", "field"); }
    | postfix_expression PTR_OP IDENTIFIER             { add_symbol($3, "member", "field"); }
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator cast_expression
    | SIZEOF unary_expression
    | SIZEOF '(' type_name ')'
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

cast_expression
    : unary_expression
    | '(' type_name ')' cast_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression
    | multiplicative_expression '/' cast_expression
    | multiplicative_expression '%' cast_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression
    | relational_expression '>' shift_expression
    | relational_expression LE_OP shift_expression
    | relational_expression GE_OP shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression
    | equality_expression NE_OP relational_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LEFT_ASSIGN
    | RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

constant_expression
    : conditional_expression
    ;

/* Declarations */
declaration
    : declaration_specifiers ';'
    | declaration_specifiers init_declarator_list ';'
    ;

declaration_specifiers
    : storage_class_specifier                          { strcpy(current_class, "storage_class"); }
    | storage_class_specifier declaration_specifiers
    | type_specifier                                    { }
    | type_specifier declaration_specifiers
    | type_qualifier
    | type_qualifier declaration_specifiers
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator
    | declarator '=' initializer
    ;

storage_class_specifier
    : TYPEDEF       { strcpy(current_class, "typedef"); }
    | EXTERN        { strcpy(current_class, "extern"); }
    | STATIC        { strcpy(current_class, "static"); }
    | AUTO          { strcpy(current_class, "auto"); }
    | REGISTER      { strcpy(current_class, "register"); }
    ;

type_specifier
    : VOID          { strcpy(current_type, "void"); }
    | CHAR          { strcpy(current_type, "char"); }
    | SHORT         { strcpy(current_type, "short"); }
    | INT           { strcpy(current_type, "int"); }
    | LONG          { strcpy(current_type, "long"); }
    | FLOAT         { strcpy(current_type, "float"); }
    | DOUBLE        { strcpy(current_type, "double"); }
    | SIGNED        { strcpy(current_type, "signed"); }
    | UNSIGNED      { strcpy(current_type, "unsigned"); }
    | struct_or_union_specifier
    | enum_specifier
    | IDENTIFIER    { strcpy(current_type, $1); }
    ;

struct_or_union_specifier
    : struct_or_union IDENTIFIER '{' struct_declaration_list '}'  { 
        strcpy(current_type, "struct/union"); 
        add_symbol($2, "struct/union", "type"); 
    }
    | struct_or_union '{' struct_declaration_list '}'              { strcpy(current_type, "struct/union"); }
    | struct_or_union IDENTIFIER                                   { 
        strcpy(current_type, "struct/union"); 
        add_symbol($2, "struct/union", "type"); 
    }
    ;

struct_or_union
    : STRUCT
    | UNION
    ;

struct_declaration_list
    : struct_declaration
    | struct_declaration_list struct_declaration
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list ';'
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
    | type_specifier
    | type_qualifier specifier_qualifier_list
    | type_qualifier
    ;

struct_declarator_list
    : struct_declarator
    | struct_declarator_list ',' struct_declarator
    ;

struct_declarator
    : declarator
    | ':' constant_expression
    | declarator ':' constant_expression
    ;

enum_specifier
    : ENUM '{' enumerator_list '}'                     { strcpy(current_type, "enum"); }
    | ENUM IDENTIFIER '{' enumerator_list '}'          { 
        strcpy(current_type, "enum"); 
        add_symbol($2, "enum", "type"); 
    }
    | ENUM IDENTIFIER                                  { 
        strcpy(current_type, "enum"); 
        add_symbol($2, "enum", "type"); 
    }
    ;

enumerator_list
    : enumerator
    | enumerator_list ',' enumerator
    ;

enumerator
    : IDENTIFIER                                       { add_symbol($1, "enum_const", "constant"); }
    | IDENTIFIER '=' constant_expression               { add_symbol($1, "enum_const", "constant"); }
    ;

type_qualifier
    : CONST
    | VOLATILE
    ;

declarator
    : pointer direct_declarator
    | direct_declarator
    ;

direct_declarator
    : IDENTIFIER                                        { 
        add_symbol($1, current_type, current_class); 
    }
    | '(' declarator ')'
    | direct_declarator '[' constant_expression ']'
    | direct_declarator '[' ']'
    | direct_declarator '(' parameter_type_list ')'     { strcpy(current_class, "function"); }
    | direct_declarator '(' identifier_list ')'         { strcpy(current_class, "function"); }
    | direct_declarator '(' ')'                         { strcpy(current_class, "function"); }
    ;

pointer
    : '*'
    | '*' type_qualifier_list
    | '*' pointer
    | '*' type_qualifier_list pointer
    ;

type_qualifier_list
    : type_qualifier
    | type_qualifier_list type_qualifier
    ;

parameter_type_list
    : parameter_list
    | parameter_list ',' ELLIPSIS
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers abstract_declarator
    | declaration_specifiers
    ;

identifier_list
    : IDENTIFIER                                       { add_symbol($1, "param", "parameter"); }
    | identifier_list ',' IDENTIFIER                   { add_symbol($3, "param", "parameter"); }
    ;

type_name
    : specifier_qualifier_list
    | specifier_qualifier_list abstract_declarator
    ;

abstract_declarator
    : pointer
    | direct_abstract_declarator
    | pointer direct_abstract_declarator
    ;

direct_abstract_declarator
    : '(' abstract_declarator ')'
    | '[' ']'
    | '[' constant_expression ']'
    | direct_abstract_declarator '[' ']'
    | direct_abstract_declarator '[' constant_expression ']'
    | '(' ')'
    | '(' parameter_type_list ')'
    | direct_abstract_declarator '(' ')'
    | direct_abstract_declarator '(' parameter_type_list ')'
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list
    : initializer
    | initializer_list ',' initializer
    ;

/* Statements */
statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement                         { add_symbol($1, "label", "label"); }
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' '}'                                          { current_nesting++; current_nesting--; }
    | '{' statement_list '}'                           { current_nesting++; current_nesting--; }
    | '{' declaration_list '}'                         { current_nesting++; current_nesting--; }
    | '{' declaration_list statement_list '}'          { current_nesting++; current_nesting--; }
    ;

declaration_list
    : declaration
    | declaration_list declaration
    ;

statement_list
    : statement
    | statement_list statement
    ;

expression_statement
    : ';'
    | expression ';'
    ;

selection_statement
    : IF '(' expression ')' statement
    | IF '(' expression ')' statement ELSE statement
    | SWITCH '(' expression ')' statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression_statement expression_statement ')' statement
    | FOR '(' expression_statement expression_statement expression ')' statement
    ;

jump_statement
    : GOTO IDENTIFIER ';'                              { add_symbol($2, "label", "label"); }
    | CONTINUE ';'
    | BREAK ';'
    | RETURN ';'
    | RETURN expression ';'
    ;

/* External Definitions */
translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement  { strcpy(current_class, "function"); }
    | declaration_specifiers declarator compound_statement                   { strcpy(current_class, "function"); }
    | declarator declaration_list compound_statement                         { strcpy(current_class, "function"); }
    | declarator compound_statement                                          { strcpy(current_class, "function"); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", line_num, s);
}

void add_symbol(char *name, char *type, char *class) {
    // Check if symbol already exists
    SymbolTable *temp = symtab_head;
    while(temp != NULL) {
        if(strcmp(temp->name, name) == 0 && temp->nesting_level == current_nesting) {
            // Update existing symbol
            if(strcmp(type, "unknown") != 0) strcpy(temp->type, type);
            if(strcmp(class, "variable") != 0) strcpy(temp->class, class);
            if(temp->ref_count < 100) {
                temp->line_ref[temp->ref_count++] = line_num;
            }
            return;
        }
        temp = temp->next;
    }
    
    // Add new symbol
    SymbolTable *new = (SymbolTable*)malloc(sizeof(SymbolTable));
    strcpy(new->name, name);
    strcpy(new->type, type);
    strcpy(new->class, class);
    strcpy(new->boundaries, "");
    new->array_dim = 0;
    strcpy(new->params, "");
    new->proc_def_flag = 0;
    new->nesting_level = current_nesting;
    new->line_declared = line_num;
    new->ref_count = 1;
    new->line_ref[0] = line_num;
    new->next = symtab_head;
    symtab_head = new;
}

void add_constant(char *value, char *type) {
    ConstantTable *new = (ConstantTable*)malloc(sizeof(ConstantTable));
    sprintf(new->var_name, "const_%d", line_num);
    new->line_num = line_num;
    strcpy(new->value, value);
    strcpy(new->type, type);
    new->next = consttab_head;
    consttab_head = new;
}

void add_header(char *header_name, char *type) {
    HeaderTable *new = (HeaderTable*)malloc(sizeof(HeaderTable));
    strcpy(new->header_name, header_name);
    new->line_num = line_num;
    strcpy(new->type, type);
    new->next = headertab_head;
    headertab_head = new;
    
    printf("Header included: %s (type: %s) at line %d\n", header_name, type, line_num);
}

void add_macro(char *name, char *value) {
    MacroTable *new = (MacroTable*)malloc(sizeof(MacroTable));
    strcpy(new->macro_name, name);
    strcpy(new->macro_value, value);
    new->line_num = line_num;
    new->next = macrotab_head;
    macrotab_head = new;
}

void print_symbol_table() {
    printf("\n╔══════════════════════════════════════════════════════════════════════════════╗\n");
    printf("║                              SYMBOL TABLE                                    ║\n");
    printf("╠══════════════════════════════════════════════════════════════════════════════╣\n");
    printf("║ %-18s ║ %-10s ║ %-12s ║ %-8s ║ %-7s ║\n", 
           "Name", "Type", "Class", "Line", "Nesting");
    printf("╠════════════════════╬════════════╬══════════════╬══════════╬═════════╣\n");
    
    SymbolTable *temp = symtab_head;
    while(temp != NULL) {
        printf("║ %-18s ║ %-10s ║ %-12s ║ %-8d ║ %-7d ║\n",
               temp->name, temp->type, temp->class, 
               temp->line_declared, temp->nesting_level);
        temp = temp->next;
    }
    printf("╚════════════════════╩════════════╩══════════════╩══════════╩═════════╝\n");
}

void print_constant_table() {
    printf("\n╔══════════════════════════════════════════════════════════════════╗\n");
    printf("║                        CONSTANT TABLE                            ║\n");
    printf("╠══════════════════════════════════════════════════════════════════╣\n");
    printf("║ %-20s ║ %-8s ║ %-15s ║ %-8s ║\n", 
           "Variable Name", "Line", "Value", "Type");
    printf("╠══════════════════════╬══════════╬═════════════════╬══════════╣\n");
    
    ConstantTable *temp = consttab_head;
    while(temp != NULL) {
        printf("║ %-20s ║ %-8d ║ %-15s ║ %-8s ║\n",
               temp->var_name, temp->line_num, temp->value, temp->type);
        temp = temp->next;
    }
    printf("╚══════════════════════╩══════════╩═════════════════╩══════════╝\n");
}

void print_header_table() {
    printf("\n╔════════════════════════════════════════════════════════════════╗\n");
    printf("║                         HEADER TABLE                           ║\n");
    printf("╠════════════════════════════════════════════════════════════════╣\n");
    printf("║ %-45s ║ %-8s ║ %-10s ║\n", 
           "Header Name", "Line", "Type");
    printf("╠═══════════════════════════════════════════════╬══════════╬════════════╣\n");
    
    HeaderTable *temp = headertab_head;
    while(temp != NULL) {
        printf("║ %-45s ║ %-8d ║ %-10s ║\n",
               temp->header_name, temp->line_num, temp->type);
        temp = temp->next;
    }
    printf("╚═══════════════════════════════════════════════╩══════════╩════════════╝\n");
}

void print_macro_table() {
    printf("\n╔════════════════════════════════════════════════════════════════╗\n");
    printf("║                          MACRO TABLE                           ║\n");
    printf("╠════════════════════════════════════════════════════════════════╣\n");
    printf("║ %-30s ║ %-8s ║ %-20s ║\n", 
           "Macro Name", "Line", "Value");
    printf("╠════════════════════════════════╬══════════╬══════════════════════╣\n");
    
    MacroTable *temp = macrotab_head;
    while(temp != NULL) {
        printf("║ %-30s ║ %-8d ║ %-20s ║\n",
               temp->macro_name, temp->line_num, temp->macro_value);
        temp = temp->next;
    }
    printf("╚════════════════════════════════╩══════════╩══════════════════════╝\n");
}

void print_all_tables() {
    printf("\n");
    printf("================================================================================\n");
    printf("                    COMPILER ANALYSIS - ALL TABLES                              \n");
    printf("================================================================================\n");
    
    print_header_table();
    print_macro_table();
    print_symbol_table();
    print_constant_table();
    
    printf("\n================================================================================\n");
    printf("                           END OF ANALYSIS                                      \n");
    printf("================================================================================\n");
}

int main(int argc, char **argv) {
    if(argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if(!fp) {
            perror("File opening failed");
            return 1;
        }
        extern FILE *yyin;
        yyin = fp;
    }
    
    printf("\n");
    printf("================================================================================\n");
    printf("              C LANGUAGE PARSER - COMPILER DESIGN LAB PHASE II                 \n");
    printf("================================================================================\n");
    printf("Starting parsing...\n\n");
    
    int result = yyparse();
    
    if(result == 0) {
        printf("\n✓ Parsing completed successfully!\n");
        print_all_tables();
    } else {
        printf("\n✗ Parsing failed with errors!\n");
    }
    
    return result;
}