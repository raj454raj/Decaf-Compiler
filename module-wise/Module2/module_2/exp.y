%{
#include<cstdlib>
#include<cstdio>
#include<cstring>
#include<string>
#include<list>
#include "exp.h"
using namespace std;
int yyerror(const char *s);
int yylex(void);
extern int yylineno;
FILE *bison_output;
int ttype = 2;

pgm *root;
%}

%define parse.error verbose

%union {
    int     int_val;
    char*   str_val;
    stmt_node *stmt;
    expr_node *exp_node;
    field_decl *field_node;
    list <field_decl *> *list1;
    list <stmt_node *> *list2;
    list <expr_node *> *expr_list;
    pgm *prog;
}

%start program

%token	<str_val>	CLASS
%token	<str_val>	CALLOUT
%token	<str_val>	TYPE
%token	<str_val>	ASSIGN_OP
%left	<str_val>	ARITH_OP_L1
%left	<str_val>	ARITH_OP_L2
%left	<str_val>	REL_OP
%left	<str_val>	EQ_OP
%left	<str_val>	COND_OP
%token	<int_val>	INT_LITERAL
%token	<str_val>	STRING_LITERAL
%token	<str_val>	BOOL_LITERAL
%token	<str_val>	CHAR_LITERAL
%token	<str_val>	ID
%token	<str_val>	OPEN_CURLY_BRACE
%token	<str_val>	CLOSE_CURLY_BRACE
%token	<str_val>	OPEN_SQUARE_BRACE
%token	<str_val>	CLOSE_SQUARE_BRACE
%token	<str_val>	OPEN_ROUND_BRACE
%token	<str_val>	CLOSE_ROUND_BRACE
%left	<str_val>	COMMA
%token	<str_val>	SEMICOLON
%token	<str_val>	MINUS
%token	<str_val>	EXCLAMATION
%token	<str_val>	CHAR
%type	<stmt>		stmt_decl
%type	<stmt>		callout
%type	<stmt>		method_call
%type	<list2>		stmt_list
%type	<field_node>	field_decl
%type	<list1>		field_list
%type	<exp_node>	expr
%type	<exp_node>	expr_l1
%type	<exp_node>	expr_l2
%type	<exp_node>	expr_l3
%type	<exp_node>	location
%type	<exp_node>	int_literal
%type	<exp_node>	char_literal
%type	<exp_node>	bool_literal
%type	<expr_list>	args
%type	<prog>		program

%%

int_literal:    INT_LITERAL {
                    fprintf(bison_output, "INT ENCOUNTERED=%d\n", $1);
		    $$ = new int_lit($1);
                }
                ;
bool_literal:   BOOL_LITERAL {
                    fprintf(bison_output, "BOOLEAN ENCOUNTERED=%s\n", $1);
		    $$ = new bool_lit($1);
                }
                ;
char_literal:   CHAR_LITERAL {
                    fprintf(bison_output, "CHAR ENCOUNTERED=%s\n", $1);
		    $$ = new char_lit($1);
                }
                ;
program:        CLASS ID OPEN_CURLY_BRACE field_list stmt_list CLOSE_CURLY_BRACE {
                    fputs("PROGRAM ENCOUNTERED\n", bison_output);
                    puts("Success"); 
		    $$ = new pgm($4, $5);
		    root = $$;
                }
                ;
stmt_list:     stmt_list stmt_decl 
		{
			$$ = $1; 
			$1->push_back($2); 
		}
                | /*empty*/
		 {
			 $$ = new list <stmt_node *>();
		 }
                ;
field_list:     field_list field_decl
		{
			$$ = $1; 
			$1->push_back($2); 
		}
                | /*empty*/
		 {
			 $$ = new list <field_decl *>();
		 }
                ;
field_decl:     TYPE ID OPEN_SQUARE_BRACE INT_LITERAL CLOSE_SQUARE_BRACE SEMICOLON {
                    if($1[0] == 'i')
                        fputs("INT DECLARATION ENCOUNTERED. ", bison_output);
                    else fputs("BOOLEAN DECLARATION ENCOUNTERED. ", bison_output);
                    fprintf(bison_output, "ID=%s SIZE=%d\n", $2, $4);
		    $$ = new field_decl(string($2), string($1), $4);
                }
                | TYPE ID SEMICOLON {
                    if($1[0] == 'i')
                        fputs("INT DECLARATION ENCOUNTERED. ", bison_output);
                    else fputs("BOOLEAN DECLARATION ENCOUNTERED. ", bison_output);
                    fprintf(bison_output, "ID=%s\n", $2);
		    $$ = new field_decl(string($2), string($1), -1);
                }
                ;
callout:        CALLOUT OPEN_ROUND_BRACE STRING_LITERAL CLOSE_ROUND_BRACE {
                    fprintf(bison_output, "CALLOUT TO %s ENCOUNTERED\n", $3);
		    $$ = new callout_node(string($3), new list <expr_node *>());
                }
                | CALLOUT OPEN_ROUND_BRACE STRING_LITERAL args CLOSE_ROUND_BRACE {
                    fprintf(bison_output, "CALLOUT TO %s ENCOUNTERED\n", $3);
		    $$ = new callout_node(string($3), $4);
                }
                ;
stmt_decl:      location ASSIGN_OP expr_l3 SEMICOLON {
                    fputs("ASSIGNMENT OPERATION ENCOUNTERED\n", bison_output);
		    $$ = new assign_node($1, $3);
                }
                | callout SEMICOLON { $$ = $1; }
                ;
location:       ID {
                    fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1);
		    $$ = new location_node(string($1), NULL);
                }
                | ID OPEN_SQUARE_BRACE expr_l3 CLOSE_SQUARE_BRACE {
                    fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1);
		    $$ = new location_node(string($1), $3);
                }
                ;
expr:           location { $$ = $1; }
                | STRING_LITERAL { new string_lit($1); }
                | int_literal {$$ = $1; }
                | char_literal {$$ = $1; }
                | method_call 
                | bool_literal {$$ = $1; }
                | MINUS expr { $$ = new un_exp($1, $2); }
                | EXCLAMATION expr { $$ = new un_exp($1, $2); }
                | OPEN_ROUND_BRACE expr_l3 CLOSE_ROUND_BRACE { $$ = $2; }
                ;
method_call:    ID OPEN_ROUND_BRACE method_args CLOSE_ROUND_BRACE 
                | callout { $$ = $1; }
                ;
expr_l1:        expr { $$ = $1; }
                | expr_l1 ARITH_OP_L2 expr_l1 {
                    if($2[0] == '*')
                        fputs("MULTIPLICATION ENCOUNTERED\n", bison_output);
                    else if($2[0] == '/')
                        fputs("DIVISION ENCOUNTERED\n", bison_output);
                    else fputs("MOD ENCOUNTERED\n", bison_output);
		    $$ = new bin_exp($2, $1, $3);
                }
                ;
expr_l2:        expr_l1 { $$ = $1; }
                | expr_l2 ARITH_OP_L1 expr_l2 {
                    if($2[0] == '+')
                        fputs("ADDITION ENCOUNTERED\n", bison_output);
                    else fputs("SUBTRACTION ENCOUNTERED\n", bison_output);
		    $$ = new bin_exp($2, $1, $3);
                }
                ;
expr_l3:        expr_l2 { $$ = $1; }
                | expr_l3 REL_OP expr_l3 {
                    if(!strcmp($2, "<"))
                        fputs("LESS THAN ENCOUNTERED\n", bison_output);
                    else if(!strcmp($2, ">"))
                        fputs("GREATER THAN ENCOUNTERED\n", bison_output);
		    $$ = new bin_exp($2, $1, $3);
                }
                | expr_l3 COND_OP expr_l3 { $$ = new bin_exp($2, $1, $3); }
                | expr_l3 EQ_OP expr_l3 { $$ = new bin_exp($2, $1, $3); }
                ;
method_args:	| /* empty */
		| expr_l3 args
		;
args:		args COMMA expr_l3 { $$ = $1; $1->push_back($3); }
		| /* empty */ { $$ = new list <expr_node *>(); }
		;

%%

int yyerror(const char *c) {
    extern char *yytext;
    printf("Syntax Error\n");
    fprintf(stderr, "%d: %s\n", yylineno, c);
    exit(1);
}

main() {
    extern FILE *flex_output, *bison_output;
    flex_output = fopen("flex_output.txt", "w");
    bison_output = fopen("bison_output.txt", "w");
    yyparse();
    root->print();
    return 0;
}

