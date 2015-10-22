%{
#include "bison.tab.h"
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
int error(char *c);
FILE *flex_output;
%}

type            int|boolean
assign_op       [\+\-]?=
arith_saiyan     [\*\/%]
arith_super_saiyan     [+\-]
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
                        strcpy( yylval.str_val, "class"); return CLASS; 
                    }
callout             {
                        fputs("CALLOUT\n", flex_output);
                        strcpy( yylval.str_val, "callout"); return CALLOUT; 
                    }
{type}              {
                        if(yytext[0] == 'b')
                            fprintf(flex_output, "BOOLEAN");
                        else fprintf(flex_output, "INT");
                        fputs("_DECLARATION\n", flex_output);
                        strcpy( yylval.str_val, yytext); return TYPE; 
                    }
{assign_op}         { strcpy( yylval.str_val, yytext); return ASSIGN_OP; }
{arith_saiyan}       { strcpy( yylval.str_val, yytext); return ARITH_SAIYAN; }
{arith_super_saiyan}       { strcpy( yylval.str_val, yytext); return ARITH_SUPER_SAIYAN; }
{rel_op}            { strcpy( yylval.str_val, yytext); return REL_OP; }
{eq_op}             { strcpy( yylval.str_val, yytext); return EQ_OP; }
{cond_op}           { strcpy( yylval.str_val, yytext); return COND_OP; }
{int_literal}       {
                        fprintf(flex_output, "INT: %s\n", yytext);
                        yylval.int_val = atoi(yytext); return INT_LITERAL; 
                    }
{string_literal}    {
                        fprintf(flex_output, "STRING: %s\n", yytext);
                        strcpy( yylval.str_val, yytext); return STRING_LITERAL; 
                    }
{bool_literal}      { 
                        fprintf(flex_output, "BOOLEAN: %s\n", yytext);
                        strcpy( yylval.str_val, yytext); return BOOL_LITERAL; 
                    }
{char_literal}      { 
                        fprintf(flex_output, "CHARACTER: %s\n", yytext);
                        strcpy( yylval.str_val, yytext); return CHAR_LITERAL; 
                    }
{id}                {
                        fprintf(flex_output, "ID: %s\n", yytext); 
                        strcpy( yylval.str_val, yytext); return ID; 
                    }
[ \t]+
[\n]                yylineno++;
.                   { strcpy( yylval.str_val, yytext); return yytext[0]; }

%%
