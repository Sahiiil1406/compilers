/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    AUTO = 258,                    /* AUTO  */
    BREAK = 259,                   /* BREAK  */
    CASE = 260,                    /* CASE  */
    CHAR = 261,                    /* CHAR  */
    CONST = 262,                   /* CONST  */
    CONTINUE = 263,                /* CONTINUE  */
    DEFAULT = 264,                 /* DEFAULT  */
    DO = 265,                      /* DO  */
    DOUBLE = 266,                  /* DOUBLE  */
    ELSE = 267,                    /* ELSE  */
    ENUM = 268,                    /* ENUM  */
    EXTERN = 269,                  /* EXTERN  */
    FLOAT = 270,                   /* FLOAT  */
    FOR = 271,                     /* FOR  */
    GOTO = 272,                    /* GOTO  */
    IF = 273,                      /* IF  */
    INT = 274,                     /* INT  */
    LONG = 275,                    /* LONG  */
    REGISTER = 276,                /* REGISTER  */
    RETURN = 277,                  /* RETURN  */
    SHORT = 278,                   /* SHORT  */
    SIGNED = 279,                  /* SIGNED  */
    SIZEOF = 280,                  /* SIZEOF  */
    STATIC = 281,                  /* STATIC  */
    STRUCT = 282,                  /* STRUCT  */
    SWITCH = 283,                  /* SWITCH  */
    TYPEDEF = 284,                 /* TYPEDEF  */
    UNION = 285,                   /* UNION  */
    UNSIGNED = 286,                /* UNSIGNED  */
    VOID = 287,                    /* VOID  */
    VOLATILE = 288,                /* VOLATILE  */
    WHILE = 289,                   /* WHILE  */
    PREPROCESSOR_DIR = 290,        /* PREPROCESSOR_DIR  */
    PP_INCLUDE = 291,              /* PP_INCLUDE  */
    PP_DEFINE = 292,               /* PP_DEFINE  */
    PP_UNDEF = 293,                /* PP_UNDEF  */
    PP_IFDEF = 294,                /* PP_IFDEF  */
    PP_IFNDEF = 295,               /* PP_IFNDEF  */
    PP_IF = 296,                   /* PP_IF  */
    PP_ELIF = 297,                 /* PP_ELIF  */
    PP_ELSE = 298,                 /* PP_ELSE  */
    PP_ENDIF = 299,                /* PP_ENDIF  */
    PP_ERROR = 300,                /* PP_ERROR  */
    PP_PRAGMA = 301,               /* PP_PRAGMA  */
    PP_LINE = 302,                 /* PP_LINE  */
    HEADER_NAME = 303,             /* HEADER_NAME  */
    IDENTIFIER = 304,              /* IDENTIFIER  */
    INT_CONSTANT = 305,            /* INT_CONSTANT  */
    FLOAT_CONSTANT = 306,          /* FLOAT_CONSTANT  */
    CHAR_CONSTANT = 307,           /* CHAR_CONSTANT  */
    STRING_LITERAL = 308,          /* STRING_LITERAL  */
    INC_OP = 309,                  /* INC_OP  */
    DEC_OP = 310,                  /* DEC_OP  */
    LEFT_OP = 311,                 /* LEFT_OP  */
    RIGHT_OP = 312,                /* RIGHT_OP  */
    LE_OP = 313,                   /* LE_OP  */
    GE_OP = 314,                   /* GE_OP  */
    EQ_OP = 315,                   /* EQ_OP  */
    NE_OP = 316,                   /* NE_OP  */
    AND_OP = 317,                  /* AND_OP  */
    OR_OP = 318,                   /* OR_OP  */
    MUL_ASSIGN = 319,              /* MUL_ASSIGN  */
    DIV_ASSIGN = 320,              /* DIV_ASSIGN  */
    MOD_ASSIGN = 321,              /* MOD_ASSIGN  */
    ADD_ASSIGN = 322,              /* ADD_ASSIGN  */
    SUB_ASSIGN = 323,              /* SUB_ASSIGN  */
    LEFT_ASSIGN = 324,             /* LEFT_ASSIGN  */
    RIGHT_ASSIGN = 325,            /* RIGHT_ASSIGN  */
    AND_ASSIGN = 326,              /* AND_ASSIGN  */
    XOR_ASSIGN = 327,              /* XOR_ASSIGN  */
    OR_ASSIGN = 328,               /* OR_ASSIGN  */
    PTR_OP = 329,                  /* PTR_OP  */
    ELLIPSIS = 330                 /* ELLIPSIS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define AUTO 258
#define BREAK 259
#define CASE 260
#define CHAR 261
#define CONST 262
#define CONTINUE 263
#define DEFAULT 264
#define DO 265
#define DOUBLE 266
#define ELSE 267
#define ENUM 268
#define EXTERN 269
#define FLOAT 270
#define FOR 271
#define GOTO 272
#define IF 273
#define INT 274
#define LONG 275
#define REGISTER 276
#define RETURN 277
#define SHORT 278
#define SIGNED 279
#define SIZEOF 280
#define STATIC 281
#define STRUCT 282
#define SWITCH 283
#define TYPEDEF 284
#define UNION 285
#define UNSIGNED 286
#define VOID 287
#define VOLATILE 288
#define WHILE 289
#define PREPROCESSOR_DIR 290
#define PP_INCLUDE 291
#define PP_DEFINE 292
#define PP_UNDEF 293
#define PP_IFDEF 294
#define PP_IFNDEF 295
#define PP_IF 296
#define PP_ELIF 297
#define PP_ELSE 298
#define PP_ENDIF 299
#define PP_ERROR 300
#define PP_PRAGMA 301
#define PP_LINE 302
#define HEADER_NAME 303
#define IDENTIFIER 304
#define INT_CONSTANT 305
#define FLOAT_CONSTANT 306
#define CHAR_CONSTANT 307
#define STRING_LITERAL 308
#define INC_OP 309
#define DEC_OP 310
#define LEFT_OP 311
#define RIGHT_OP 312
#define LE_OP 313
#define GE_OP 314
#define EQ_OP 315
#define NE_OP 316
#define AND_OP 317
#define OR_OP 318
#define MUL_ASSIGN 319
#define DIV_ASSIGN 320
#define MOD_ASSIGN 321
#define ADD_ASSIGN 322
#define SUB_ASSIGN 323
#define LEFT_ASSIGN 324
#define RIGHT_ASSIGN 325
#define AND_ASSIGN 326
#define XOR_ASSIGN 327
#define OR_ASSIGN 328
#define PTR_OP 329
#define ELLIPSIS 330

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 72 "main.y"

    char *str;
    int num;

#line 222 "y.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
