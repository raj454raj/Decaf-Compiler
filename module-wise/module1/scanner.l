%{
#include <bits/stdc++.h>
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

\;|\}|\{|\[|\]|\=|\(|\)|\+|\-|\!|\*|\/|\%|\<|\>|\, {
    return yytext[0];
}

"class" {
    fprintf(flex_output, "CLASS\n");
    return CLASS;   // class keyword
}

"boolean" {
    fprintf(flex_output, "BOOLEAN_DECLARATION\n");
    return BOOL_DECL;   // bool keyword
}

"int" {
    fprintf(flex_output, "INT_DECLARATION\n");
    return INT_DECL;    // int keyword
}

"callout" {
    fprintf(flex_output, "CALLOUT\n");
    return CALLOUT;    // callout function call
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

\-?[0-9]+ {
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
