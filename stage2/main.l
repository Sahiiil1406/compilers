%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

extern int yylineno;
void yyerror(const char *s);

int line_num = 1;
int comment_depth = 0;
%}

%option yylineno

%x COMMENT
%x PREPROCESSOR

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
HEX_DIGIT   [0-9a-fA-F]
OCT_DIGIT   [0-7]

/* Integer Constants */
DEC_INT     [1-9]{DIGIT}*
OCT_INT     0{OCT_DIGIT}*
HEX_INT     0[xX]{HEX_DIGIT}+
INTEGER     ({DEC_INT}|{OCT_INT}|{HEX_INT})[uUlL]*

/* Floating Constants */
FLOAT_DEC   ({DIGIT}+\.{DIGIT}*|{DIGIT}*\.{DIGIT}+)([eE][+-]?{DIGIT}+)?[fFlL]?
FLOAT_HEX   0[xX]({HEX_DIGIT}+\.{HEX_DIGIT}*|{HEX_DIGIT}*\.{HEX_DIGIT}+)[pP][+-]?{DIGIT}+[fFlL]?
FLOAT       {FLOAT_DEC}|{FLOAT_HEX}

/* Character and String Constants */
ESCAPE      \\(['"?\\abfnrtv]|{OCT_DIGIT}{1,3}|x{HEX_DIGIT}+)
CHAR        '([^'\\\n]|{ESCAPE})'
STRING      \"([^"\\\n]|{ESCAPE})*\"

WHITESPACE  [ \t\r]+
NEWLINE     \n

%%

<INITIAL>{
"/*"                    { comment_depth++; BEGIN(COMMENT); }
"//".*                  { /* Single-line comment */ }

^[ \t]*"#"              { BEGIN(PREPROCESSOR); return PREPROCESSOR_DIR; }

"auto"          { return AUTO; }
"break"         { return BREAK; }
"case"          { return CASE; }
"char"          { return CHAR; }
"const"         { return CONST; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"do"            { return DO; }
"double"        { return DOUBLE; }
"else"          { return ELSE; }
"enum"          { return ENUM; }
"extern"        { return EXTERN; }
"float"         { return FLOAT; }
"for"           { return FOR; }
"goto"          { return GOTO; }
"if"            { return IF; }
"int"           { return INT; }
"long"          { return LONG; }
"register"      { return REGISTER; }
"return"        { return RETURN; }
"short"         { return SHORT; }
"signed"        { return SIGNED; }
"sizeof"        { return SIZEOF; }
"static"        { return STATIC; }
"struct"        { return STRUCT; }
"switch"        { return SWITCH; }
"typedef"       { return TYPEDEF; }
"union"         { return UNION; }
"unsigned"      { return UNSIGNED; }
"void"          { return VOID; }
"volatile"      { return VOLATILE; }
"while"         { return WHILE; }

{ID}            { yylval.str = strdup(yytext); return IDENTIFIER; }
{INTEGER}       { yylval.str = strdup(yytext); return INT_CONSTANT; }
{FLOAT}         { yylval.str = strdup(yytext); return FLOAT_CONSTANT; }
{CHAR}          { yylval.str = strdup(yytext); return CHAR_CONSTANT; }
{STRING}        { yylval.str = strdup(yytext); return STRING_LITERAL; }

"++"            { return INC_OP; }
"--"            { return DEC_OP; }
"<<"            { return LEFT_OP; }
">>"            { return RIGHT_OP; }
"<="            { return LE_OP; }
">="            { return GE_OP; }
"=="            { return EQ_OP; }
"!="            { return NE_OP; }
"&&"            { return AND_OP; }
"||"            { return OR_OP; }
"*="            { return MUL_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }
"+="            { return ADD_ASSIGN; }
"-="            { return SUB_ASSIGN; }
"<<="           { return LEFT_ASSIGN; }
">>="           { return RIGHT_ASSIGN; }
"&="            { return AND_ASSIGN; }
"^="            { return XOR_ASSIGN; }
"|="            { return OR_ASSIGN; }
"->"            { return PTR_OP; }
"..."           { return ELLIPSIS; }

"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
"["             { return '['; }
"]"             { return ']'; }
";"             { return ';'; }
","             { return ','; }
":"             { return ':'; }
"="             { return '='; }
"."             { return '.'; }
"&"             { return '&'; }
"!"             { return '!'; }
"~"             { return '~'; }
"-"             { return '-'; }
"+"             { return '+'; }
"*"             { return '*'; }
"/"             { return '/'; }
"%"             { return '%'; }
"<"             { return '<'; }
">"             { return '>'; }
"^"             { return '^'; }
"|"             { return '|'; }
"?"             { return '?'; }

{WHITESPACE}    { /* Skip whitespace */ }
{NEWLINE}       { line_num++; }

.               { fprintf(stderr, "Unrecognized character: %s at line %d\n", yytext, line_num); }
}

<COMMENT>{
"/*"            { comment_depth++; }
"*/"            { comment_depth--; if(comment_depth == 0) BEGIN(INITIAL); }
\n              { line_num++; }
.               { /* Skip comment content */ }
<<EOF>>         { fprintf(stderr, "Unterminated comment at line %d\n", line_num); return 0; }
}

<PREPROCESSOR>{
"include"       { yylval.str = strdup(yytext); return PP_INCLUDE; }
"define"        { yylval.str = strdup(yytext); return PP_DEFINE; }
"undef"         { yylval.str = strdup(yytext); return PP_UNDEF; }
"ifdef"         { yylval.str = strdup(yytext); return PP_IFDEF; }
"ifndef"        { yylval.str = strdup(yytext); return PP_IFNDEF; }
"if"            { yylval.str = strdup(yytext); return PP_IF; }
"elif"          { yylval.str = strdup(yytext); return PP_ELIF; }
"else"          { yylval.str = strdup(yytext); return PP_ELSE; }
"endif"         { yylval.str = strdup(yytext); return PP_ENDIF; }
"error"         { yylval.str = strdup(yytext); return PP_ERROR; }
"pragma"        { yylval.str = strdup(yytext); return PP_PRAGMA; }
"line"          { yylval.str = strdup(yytext); return PP_LINE; }

"<"[^>\n]+">"   { yylval.str = strdup(yytext); return HEADER_NAME; }
{STRING}        { yylval.str = strdup(yytext); return STRING_LITERAL; }
{ID}            { yylval.str = strdup(yytext); return IDENTIFIER; }
{INTEGER}       { yylval.str = strdup(yytext); return INT_CONSTANT; }

\n              { line_num++; BEGIN(INITIAL); }
.               { /* Skip other preprocessor content */ }
}

%%

int yywrap() {
    return 1;
}