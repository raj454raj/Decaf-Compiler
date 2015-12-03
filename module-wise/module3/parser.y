%{
#include <cstdio>
#include <list>
#include <iostream>
#include <string>
#include <cstdlib>
#include <vector>
#include "ast.h"

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int line_num;
void yyerror(const char *s);
FILE * bison_output = fopen("bison_output.txt", "w");
string decl_type;
int decl_count = 0;
int stm_count = 0;

Node* root;

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
    Node *node;
    std::list<Node*> *node_list;
};

%token <int_val> INT_VALUE
%token <str_val> CHAR_VALUE
%token <str_val> STR_VALUE
%token <str_val> BOOL_VALUE
%token <str_val> LEQ GEQ EQEQ NEQ OR AND
%token <str_val> ID
%token END ENDL

%left OR
%left AND
%left EQEQ NEQ
%left '<' LEQ GEQ '>'
%left '+' '-'
%left '*' '/' '%'
%left '!'
%left UNARY_MINUS

%type <node_list> multiple_ids
%type <node> pid
%type <node_list> declarations
%type <node_list> statements
%type <node> statement
%type <node> procedure_call
%type <node> location
%type <node_list> arg_list
%type <node_list> oarg_list
%type <node> expression
%type <node> decl

%token CLASS INT_DECL BOOL_DECL CALLOUT
%%

// Grammer - CFG's
program: CLASS ID '{' declarations statements '}' {
           // program consists of left child as declarations
           // and right child as statements
           Node* declarations = new Declarations(*($4));
           Node* statements = new Statements(*($5));
           Node* n = new Program(declarations, decl_count, statements, stm_count);
           root = n;
         } ;

declarations: declarations decl {
                $1->push_back($2);
                $$ = $1;
              }
              | {
                /* empty */
                list <Node*> *k = new list<Node*>();
                $$ = k;
              } ;

decl: type multiple_ids ';' {
        list<Node*>::iterator it = $2->begin();
        int i = 0;
        for(;it!=$2->end();it++) {
          i++;
          if (i == 2) break;
        }
        if (i == 1) {
          // only one declaration
          Node* n = *($2->begin());
          $$ = n;
        } else {
          Node* n = new Declarations(*($2));
          $$ = n;
        }
      };

type: INT_DECL { decl_type = "integer"; } |
      BOOL_DECL { decl_type = "boolean"; }

multiple_ids: pid { 
                list <Node*> *dec = new list <Node*>();
                dec->push_back($1);
                $$ = dec;
              } |
              multiple_ids ',' pid {
                list <Node*> *dec = new list <Node*>();
                dec->push_back($3);
                $1->insert($1->end(), dec->begin(), dec->end());
                $$ = $1;
              } ; 

pid: ID { 
       string var_name = $1;
       Node* n = new Declaration(decl_type, var_name, "normal");
       $$ = n;
       decl_count++;
     } 
     |
     ID '[' INT_VALUE ']' {
       string var_name = $1;
       int size = $3;
       Node* n = new Declaration(decl_type, var_name, "array", size);
       $$ = n;
       decl_count++;
     } ;


statements: statements statement {
              $1->push_back($2);
              $$ = $1;
            }
            | {
            /* empty */
              list <Node*> *k = new list<Node*>();
              $$ = k;
            } ;

statement: location '=' expression ';' {
             Node* n = new Assignment($1, $3);
             $$ = n; 
             stm_count++;
           }
           |
           procedure_call {
             $$ = $1;
             stm_count++;
           } ;

location: ID '[' expression ']' {
            Node* n = new Location($1, "array", $3);
            $$ = n;
          } |
          ID { 
            Node* n = new Location($1, "normal");
            $$ = n;
          } ;

expression: location {
              $$ = $1;
            } |
            '(' expression ')' {
              $$ = $2;
            } |
            INT_VALUE {
              ostringstream ss;
              ss << $1;
              Node* n = new Literal("integer", ss.str());
              $$ = n;
              //Node* exp = new Expression(n);
              //$$ = exp;
            } |
            BOOL_VALUE {
              Node* n = new Literal("boolean", $1);
              $$ = n;
            } |
            CHAR_VALUE { 
              Node* n = new Literal("character", $1);
              $$ = n;
            } |
            STR_VALUE {
              Node* n = new Literal("string", $1);
              $$ = n;
            } |
            procedure_call { 
              $$ = $1;
            } |
            '!' expression {
              Node* n = new UnaryOp("not", $2);
              $$ = n;
            } |
            '-' expression %prec UNARY_MINUS {
              Node* n = new UnaryOp("minus", $2);
              $$ = n;
            } |
            expression '+' expression {
              Node* n = new BinaryOp("addition", $1, $3);
              $$ = n;
            } |
            expression '-' expression {
              Node* n = new BinaryOp("subtraction", $1, $3);
              $$ = n;
            } |
            expression '*' expression { 
              Node* n = new BinaryOp("multiplication", $1, $3);
              $$ = n;
            } |
            expression '/' expression {
              Node* n = new BinaryOp("division", $1, $3);
              $$ = n;
            } |
            expression '%' expression {
              Node* n = new BinaryOp("remainder", $1, $3);
              $$ = n;
            } |
            expression '>' expression { 
              Node* n = new BinaryOp("greater_than", $1, $3);
              $$ = n;
            } |
            expression '<' expression {
              Node* n = new BinaryOp("less_than", $1, $3);
              $$ = n;
            } |
            expression LEQ expression {
              Node* n = new BinaryOp("less_equal", $1, $3);
              $$ = n;
            } |
            expression GEQ expression {
              Node* n = new BinaryOp("greater_equal", $1, $3);
              $$ = n;
            } |
            expression EQEQ expression {
              Node* n = new BinaryOp("is_equal", $1, $3);
              $$ = n;
            } |
            expression NEQ expression {
              Node* n = new BinaryOp("is_not_equal", $1, $3);
              $$ = n;
            } |
            expression AND expression {
              Node* n = new BinaryOp("and", $1, $3);
              $$ = n;
            } |
            expression OR expression {
              Node* n = new BinaryOp("or", $1, $3);
              $$ = n;
            } ;

procedure_call: CALLOUT '(' STR_VALUE oarg_list ')' ';' {
                  Node* n = new ProcedureCall($3, *($4));
                  $$ = n;
                };

oarg_list: ',' arg_list {
            $$ = $2;
           } | {
            /* empty */
            list<Node*> *k = new list<Node*>();
            $$ = k;
           } ;

arg_list: expression {
            list <Node*> *el = new list <Node*>();
            el->push_back($1);
            $$ = el;
          } |
          expression ',' arg_list {
            list<Node*> *el = new list <Node*>();
            el->push_back($1);
            el->insert(el->end(), $3->begin(), $3->end());
            $$ = el;
          }
%%

int main(int, char**) {
    // open a file handle to a particular file:
    FILE *myfile = fopen("test_program", "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open testcase!, filename should be 'test_program'." << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // parse through the input until there is no more:
    cout << "201301065\n";
    cout << "201301048\n";
    do {
        yyparse();
    } while (!feof(yyin));
    cout << "Success\n";
    // Output to a file
    std::ofstream out("XML_visitor.txt");
    std::streambuf *coutbuf = std::cout.rdbuf(); // save original cout buffer
    std::cout.rdbuf(out.rdbuf()); // redirect std::cout to XML_Visitor.txt
    root->print();
    std::cout.rdbuf(coutbuf); // revert changes

    return 0;
}

void yyerror(const char *s) {
    cout << "Syntax Error" << endl;
    // might as well halt now:
    exit(-1);
}
