%{
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <string>
#include <list>
#include "exp.h"
#include "y.tab.h"
int error(char *c);
FILE *flex_output;
%}

type            int|boolean
assign_op       [\+\-]?=
arith_op_l1     [+\-]
arith_op_l2     [\*\/%]
rel_op          [<>]=?
eq_op           [=!]=
cond_op         &&|\|\|
id              {alpha}{alpha_num}*
alpha_num       {alpha}|{digit}
alpha           [a-zA-Z]
digit           [0-9]
hex_digit       {digit}|[a-fA-F]
int_literal     {decimal_literal}|{hex_literal}
decimal_literal {digit}+
hex_literal     0x{hex_digit}+
bool_literal    true|false
char_literal    '.'
string_literal  \".*\"

%%

class               {
                        fputs("CLASS\n", flex_output);
                        yylval.str_val = strdup("class"); return CLASS; 
                    }
callout             {
                        fputs("CALLOUT\n", flex_output);
                        yylval.str_val = strdup("callout"); return CALLOUT; 
                    }
{type}              {
                        if(yytext[0] == 'b')
                            fprintf(flex_output, "BOOLEAN");
                        else fprintf(flex_output, "INT");
                        fputs("_DECLARATION\n", flex_output);
                        yylval.str_val = strdup(yytext); return TYPE; 
                    }
{assign_op}         { yylval.str_val = strdup(yytext); return ASSIGN_OP; }
{arith_op_l1}       { yylval.str_val = strdup(yytext); return ARITH_OP_L1; }
{arith_op_l2}       { yylval.str_val = strdup(yytext); return ARITH_OP_L2; }
{rel_op}            { yylval.str_val = strdup(yytext); return REL_OP; }
{eq_op}             { yylval.str_val = strdup(yytext); return EQ_OP; }
{cond_op}           { yylval.str_val = strdup(yytext); return COND_OP; }
{int_literal}       {
                        fprintf(flex_output, "INT: %s\n", yytext);
                        yylval.int_val = atoi(yytext); return INT_LITERAL; 
                    }
{string_literal}    {
                        fprintf(flex_output, "STRING: %s\n", yytext);
                        yylval.str_val = strdup(yytext); return STRING_LITERAL; 
                    }
{bool_literal}      { 
                        fprintf(flex_output, "BOOLEAN: %s\n", yytext);
                        yylval.str_val = strdup(yytext); return BOOL_LITERAL; 
                    }
{char_literal}      { 
                        fprintf(flex_output, "CHARACTER: %s\n", yytext);
                        yylval.str_val = strdup(yytext); return CHAR_LITERAL; 
                    }
{id}                {
                        fprintf(flex_output, "ID: %s\n", yytext); 
                        yylval.str_val = strdup(yytext); return ID; 
                    }
\{                  { yylval.str_val = strdup(yytext); return OPEN_CURLY_BRACE; }
\}                  { yylval.str_val = strdup(yytext); return CLOSE_CURLY_BRACE; }
\[                  { yylval.str_val = strdup(yytext); return OPEN_SQUARE_BRACE; }
\]                  { yylval.str_val = strdup(yytext); return CLOSE_SQUARE_BRACE; }
\(                  { yylval.str_val = strdup(yytext); return OPEN_ROUND_BRACE; }
\)                  { yylval.str_val = strdup(yytext); return CLOSE_ROUND_BRACE; }
,                   { yylval.str_val = strdup(yytext); return COMMA; }
;                   { yylval.str_val = strdup(yytext); return SEMICOLON; }
!                   { yylval.str_val = strdup(yytext); return EXCLAMATION; }
[ \t]+
[\n]                yylineno++;
.                   { yylval.str_val = strdup(yytext); return CHAR; }

%%
