%{
#include <bits/stdc++.h>
#include "ast.h"
#include "parser.tab.h"
using namespace std;
#define YY_DECL extern "C" int yylex()
int line_num = 1;
FILE * flex_output = fopen("flex_output.txt", "w");
%}

%%
[ \t\n] {
    ;
}

"=" {
    yylval.str_val = strdup(yytext);
    return EQ;
}

\;|\}|\{|\[|\]|\(|\)|\+|\-|\!|\*|\/|\%|\<|\>|\, {
    return yytext[0];
}

"+=" {
    yylval.str_val = strdup(yytext);
    return PEQ;
}

"-=" {
    yylval.str_val = strdup(yytext);
    return MEQ;
}

"<=" {
    yylval.str_val = strdup(yytext);
    return LEQ;
}

">=" {
    yylval.str_val = strdup(yytext);
    return GEQ;
}

"==" {
    yylval.str_val = strdup(yytext);
    return EQEQ;
}

"!=" {
    yylval.str_val = strdup(yytext);
    return NEQ;
}

"&&" {
    yylval.str_val = strdup(yytext);
    return AND;
}

"||" {
    yylval.str_val = strdup(yytext);
    return OR;
}

"void" {
    fprintf(flex_output, "VOID\n");
    return VOID;
}

"class" {
    fprintf(flex_output, "CLASS\n");
    return CLASS;   // class keyword
}

"boolean" {
    yylval.str_val = strdup(yytext);
    fprintf(flex_output, "BOOLEAN_DECLARATION\n");
    return BOOL_DECL;   // bool keyword
}

"int" {
    yylval.str_val = strdup(yytext);
    fprintf(flex_output, "INT_DECLARATION\n");
    return INT_DECL;    // int keyword
}

"callout" {
    fprintf(flex_output, "CALLOUT\n");
    return CALLOUT;    // callout function call
}

"if" {
    fprintf(flex_output, "IF\n");
    return IF;
}

"else" {
    fprintf(flex_output, "ELSE\n");
    return ELSE;
}

"return" {
    fprintf(flex_output, "RETURN\n");
    return RETURN;
}


"for" {
    fprintf(flex_output, "FOR\n");
    return FOR;
}

"break" {
    fprintf(flex_output, "BREAK\n");
    return BREAK;
}

"continue" {
    fprintf(flex_output, "CONTINUE\n");
    return CONTINUE;
}

"true"|"false" {
    fprintf(flex_output, "BOOLEAN: %s\n", yytext);
    yylval.str_val = strdup(yytext);
    return BOOL_VALUE;    // bool literal
}

\"(\\.|[^"])*\" {
    fprintf(flex_output, "STRING: %s\n", yytext);
    yylval.str_val = strdup(yytext);
    return STR_VALUE;  // String literal
}

\'(\\.|[^"])\' {
    fprintf(flex_output, "CHAR: %s\n", yytext);
    yylval.str_val = strdup(yytext);
    return CHAR_VALUE;  // Character literal
}

[0-9]+ {
    fprintf(flex_output, "INT: %s\n", yytext);
    yylval.int_val = atoi(yytext);
    return INT_VALUE;     // Integer literal
}

[a-zA-Z]+[0-9]* {
    fprintf(flex_output, "ID: %s\n", yytext);
    yylval.str_val = strdup(yytext);
    return ID;  // Identifier
}

. ;
%%
