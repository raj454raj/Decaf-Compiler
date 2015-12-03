%{
#include <cstdio>
#include<bits/stdc++.h>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int line_num;
void yyerror(const char *s);
FILE * bison_output = fopen("bison_output.txt", "w");
%}


// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype":
%union {
    int int_val;
    char* bool_val;
    char* str_val;
    char char_val;
}

%token <int_val> INT_VALUE
%token <str_val> CHAR_VALUE
%token <str_val> STR_VALUE
%token <str_val> BOOL_VALUE
%token <str_val> ID
%token END ENDL

%left '<' '>'
%left '+' '-'
%left '*' '/' '%'
%left '!'
%left UNARY_MINUS

%token CLASS INT_DECL BOOL_DECL CALLOUT
%%
// Grammer - CFG's
program: CLASS ID '{' body '}' { fprintf(bison_output, "PROGRAM ENCOUNTERED\n"); };

body: body INT_DECL ID ';' { fprintf(bison_output, "INT DECLARATION ENCOUNTERED. ID=%s\n", $3); } |
      body INT_DECL ID '[' INT_VALUE ']' ';' { fprintf(bison_output, "INT DECLARATION ENCOUNTERED. ID=%s SIZE=%d\n", $3, $5); } |
      body BOOL_DECL ID ';' { fprintf(bison_output, "BOOLEAN DECLARATION ENCOUNTERED. ID=%s\n", $3); } |
      body BOOL_DECL ID '[' INT_VALUE ']' ';' { fprintf(bison_output, "BOOLEAN DECLARATION ENCOUNTERED. ID=%s SIZE=%d\n", $3, $5); } |
      body location '=' expression ';' { fprintf(bison_output, "ASSIGNMENT OPERATION ENCOUNTERED\n"); } |
      body procedure_call |;

location: ID '[' expression ']' { fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1); } |
          ID { fprintf(bison_output, "LOCATION ENCOUNTERED=%s\n", $1); } ;

expression: location |
            '(' expression ')' |
            INT_VALUE { fprintf(bison_output, "INT ENCOUNTERED=%d\n", $1); } |
            BOOL_VALUE { fprintf(bison_output, "BOOLEAN ENCOUNTERED=%s\n", $1); } |
            CHAR_VALUE { fprintf(bison_output, "CHAR ENCOUNTERED=%s\n", $1); } |
            STR_VALUE { fprintf(bison_output, "STRING ENCOUNTERED=%s\n", $1); } |
            procedure_call |
            '!' expression |
            '-' expression %prec UNARY_MINUS |
            expression '+' expression { fprintf(bison_output, "ADDITION ENCOUNTERED\n"); } |
            expression '-' expression { fprintf(bison_output, "SUBTRACTION ENCOUNTERED\n"); } |
            expression '*' expression { fprintf(bison_output, "MULTIPLICATION ENCOUNTERED\n"); } |
            expression '/' expression { fprintf(bison_output, "DIVISION ENCOUNTERED\n"); } |
            expression '%' expression { fprintf(bison_output, "MOD ENCOUNTERED\n"); } |
            expression '>' expression { fprintf(bison_output, "GREATER THAN ENCOUNTERED\n"); } |
            expression '<' expression { fprintf(bison_output, "LESS THAN ENCOUNTERED\n"); } ;

procedure_call: CALLOUT '(' STR_VALUE oarg_list ')' ';' { fprintf(bison_output, "CALLOUT TO %s ENCOUNTERED\n", $3); } ;

oarg_list: | ',' arg_list ;

arg_list: expression |
          expression ',' arg_list ;

%%

int main(int, char**) {
    // open a file handle to a particular file:
    FILE *myfile = fopen("test_program", "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open testcase!" << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

}

void yyerror(const char *s) {
    cout << "EEK, parse error on line " << line_num << "!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
