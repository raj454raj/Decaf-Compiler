%{
#include "exp.h"
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<math.h>
using namespace std;

int yyerror(const char *s);
int yylex(void);
extern int yylineno;
FILE *bison_output;
int ttype = 2;

Node *root;

%}

%define parse.error verbose

%union {
    int     int_val;
    string  str_val;
}

%start program

%token  <str_val>   CLASS
%token  <str_val>   CALLOUT
%token  <str_val>   TYPE
%token  <int_val>   INT_LITERAL
%token  <str_val>   STRING_LITERAL BOOL_LITERAL CHAR_LITERAL ID
%token  <str_val>   CHAR
%token  <str_val>   ASSIGN_OP
%left   <str_val>   ARITH_SAIYAN
%left   <str_val>   ARITH_SUPER_SAIYAN
%left   <str_val>   REL_OP
%left   <str_val>   EQ_OP
%left   <str_val>   COND_OP
%left   ','
%%

int_literal:    INT_LITERAL {
                    fprintf(bison_output, "INT ENCOUNTERED=%d\n", $1);

                }
                ;
bool_literal:   BOOL_LITERAL {
                    fprintf(bison_output, "BOOLEAN ENCOUNTERED=%s\n", $1);
                    bool tmp = ($1 == ) 
                    Node *bool_lit = new Bool_literal($1);
                    $$ = bool_lit;
                }
                ;
char_literal:   CHAR_LITERAL {
                    fprintf(bison_output, "CHARACTER ENCOUNTERED=%s\n", $1);
                    Node *char_lit = new Char_literal($1);
                    $$ = char_lit;
                }
                ;
program:        CLASS ID '{' field_list stmt_list '}' {
                    fputs("PROGRAM ENCOUNTERED\n", bison_output);
                    puts("Success"); 
                    root = new Program();
                    root->children.pb($4);
                    root->children.pb($5);
                }
                ;
stmt_list:     stmt_list stmt_decl {
                    $1.children.pb($2);
                    $$ = $1;
                }
                | /*empty*/ {
                    node *stmt = new Statement();
                    $$ = stmt;
                }
                ;
field_list:     field_list field_decl {
                    for(auto it:$2)
                        $1.children.pb(it);
                    $$ = $1;
                }
                | /*empty*/ {
                    node *field = new Field();
                    $$ = field;
                }
                ;
type:           TYPE {
                    if($1[0] == 'i')
                        ttype = 1;
                    else ttype = 0;
                }
field_list:     field_li
field_list:     field_li
                ;
loc_list:       ID {
                    if(ttype != 2) {
                        Node *decl;
                        if(ttype == 1)
                        {
                            fputs("INT DECLARATION ENCOUNTERED. ", bison_output);
                            decl = new Declaration("int", $1);
                        }
                        else 
                        {
                            fputs("BOOLEAN DECLARATION ENCOUNTERED. ", bison_output);
                            decl = new Declaration("bool", $1);
                        }
                        fprintf(bison_output, "ID=%s\n", $1);
                        list <Node *> ret;
                        ret.pb(decl);
                        $$ = ret;
                    }
                }
                | ID '[' INT_LITERAL ']' {
                    if(ttype != 2) {
                        Node *decl;
                        if(ttype == 1)
                        {
                            fputs("INT DECLARATION ENCOUNTERED. ", bison_output);
                            decl = new Declaration("int", $1, $3);
                        }
                        else
                        { 
                            fputs("BOOLEAN DECLARATION ENCOUNTERED. ", bison_output);
                            decl = new Declaration("bool", $1, $3);
                        }
                        fprintf(bison_output, "ID=%s SIZE=%d\n", $1, $3);
                        list <Node *> ret;
                        ret.pb(decl);
                        $$ = ret;
                    }
                }
                | loc_list ',' loc_list {
                        $$ = $1.insert($1.end(), $2.begin(), $2.end());
                }
                ;
field_decl:     type loc_list ';' {
                    ttype = 2;
                    $$ = $2;
                }
                ;
callout:        CALLOUT '(' STRING_LITERAL ')' {
                    fprintf(bison_output, "CALLOUT TO %s ENCOUNTERED\n", $3);
                    Node *callu = new Callout($3);
                    $$ = callu;
                }
                | CALLOUT '(' STRING_LITERAL ',' args ')' {
                    fprintf(bison_output, "CALLOUT TO %s ENCOUNTERED\n", $3);
                    Node *callu = new Callout($3);
                    for(auto it:$5){
                        callu.children.pb(it);
                    }
                    $$ = callu;
                }
                ;
stmt_decl:      location ASSIGN_OP expr_saiyan_god ';' {
                    fputs("ASSIGNMENT OPERATION ENCOUNTERED\n", bison_output);
                    Node *ass = new Assignment();
                    ass.children.pb($1);
                    ass.children.pb($3);
                    $$ = ass;
                }
                | callout ';' {
                    $$ = $1;
                }
                ;
location:       ID {
                    fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1);
                    Node *loc = new Location("normal", $1);
                    $$ = loc;
                }
                | ID '[' expr_saiyan_god ']' {
                    fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1);
                    Node *loc = new Location("array", $1);
                    loc.children.pb($3);
                }
                ;
expr:           location 
                | char_literal
                | int_literal
                | bool_literal
                | '-' expr
                | '!' expr
                | '(' expr_saiyan_god ')'
                ;
expr_saiyan:        expr
                | expr_saiyan ARITH_SAIYAN expr_saiyan {
                    if($2[0] == '*')
                        fputs("MULTIPLICATION ENCOUNTERED\n", bison_output);
                    else if($2[0] == '/')
                        fputs("DIVISION ENCOUNTERED\n", bison_output);
                    else fputs("MOD ENCOUNTERED\n", bison_output);
                }
                ;
expr_super_saiyan:        expr_saiyan 
                | expr_super_saiyan ARITH_SUPER_SAIYAN expr_super_saiyan {
                    if($2[0] == '+')
                        fputs("ADDITION ENCOUNTERED\n", bison_output);
                    else fputs("SUBTRACTION ENCOUNTERED\n", bison_output);
                }
                ;
expr_saiyan_god:        expr_super_saiyan
                | expr_saiyan_god REL_OP expr_saiyan_god {
                    if(!strcmp($2, "<"))
                        fputs("LESS THAN ENCOUNTERED\n", bison_output);
                    else if(!strcmp($2, ">"))
                        fputs("GREATER THAN ENCOUNTERED\n", bison_output);
                }
                | expr_saiyan_god COND_OP expr_saiyan_god
                | expr_saiyan_god EQ_OP expr_saiyan_god
                ;
args:           expr_saiyan_god
                | args ',' args
                ;
%%

int yyerror(const char *c) {
    extern char *yytext;
    printf("Syntax Error\n");
    fprintf(stderr, "%d: %s\n", yylineno, c);
    exit(1);
}

int main(int argc, char *argv[]) {
    extern FILE *flex_output, *bison_output, *yyin;
    flex_output = fopen("flex_output.txt", "w");
    bison_output = fopen("bison_output.txt", "w");
    FILE *f = fopen(argv[1], "r");
    yyin = f;
    yyparse();
    return 0;
}