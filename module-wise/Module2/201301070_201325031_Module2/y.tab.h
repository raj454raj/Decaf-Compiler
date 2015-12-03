/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    CLASS = 258,
    CALLOUT = 259,
    TYPE = 260,
    INT_LITERAL = 261,
    STRING_LITERAL = 262,
    BOOL_LITERAL = 263,
    CHAR_LITERAL = 264,
    ID = 265,
    CHAR = 266,
    ASSIGN_OP = 267,
    ARITH_SAIYAN = 268,
    ARITH_SUPER_SAIYAN = 269,
    REL_OP = 270,
    EQ_OP = 271,
    COND_OP = 272
  };
#endif
/* Tokens.  */
#define CLASS 258
#define CALLOUT 259
#define TYPE 260
#define INT_LITERAL 261
#define STRING_LITERAL 262
#define BOOL_LITERAL 263
#define CHAR_LITERAL 264
#define ID 265
#define CHAR 266
#define ASSIGN_OP 267
#define ARITH_SAIYAN 268
#define ARITH_SUPER_SAIYAN 269
#define REL_OP 270
#define EQ_OP 271
#define COND_OP 272

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 18 "exp.y" /* yacc.c:1909  */

    int     int_val;
    char    str_val[1024];

#line 93 "y.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
