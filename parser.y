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
    char *bool_val;
    char *str_val;
    char char_val;
    Node *node;
    std::list<Node*> *node_list;
};

%token <int_val> INT_VALUE
%token <str_val> CHAR_VALUE
%token <str_val> STR_VALUE
%token <str_val> BOOL_VALUE
%token <str_val> INT_DECL BOOL_DECL
%token <str_val> EQ LEQ GEQ EQEQ NEQ OR AND MEQ PEQ
%token RETURN CONTINUE BREAK IF ELSE FOR VOID CLASS CALLOUT
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
%type <node_list> field_declarations
%type <node_list> method_declarations
%type <node> method_declaration
%type <node_list> statements
%type <node> statement
%type <node> procedure_call
%type <node> location
%type <node_list> arg_list
%type <node_list> oarg_list
%type <node_list> multiple_var_ids
%type <node_list> var_declarations
%type <node> expression
%type <node> decl
%type <node> pgm_body
%type <node> block
%type <node> oreturn
%type <node> oelse
%type <str_val> type
%type <node_list> param_list
%type <node_list> oparam_list
%type <node_list> carg_list
%type <node_list> ocarg_list
%type <str_val> ass_op
%type <node> var_decl

%%

// Grammer - CFG's
program: CLASS ID '{' pgm_body '}' {
            root = $4;
         };

pgm_body: field_declarations {
            Node *field_dec = new FieldDeclarations(*($1));
            Node *pro = new Program(field_dec, (Node *)NULL);
            $$ = pro;
          } |
          method_declarations {
            Node *method_dec = new MethodDeclarations(*($1));
            Node *pro = new Program((Node *)NULL, method_dec);
            $$ = pro;
          } |
          field_declarations method_declarations {
            Node *field_dec = new FieldDeclarations(*($1));
            Node *method_dec = new MethodDeclarations(*($2));
            Node *pro = new Program(field_dec, method_dec);
            $$ = pro;
          } |
          {
              /* Empty */
              $$ = new Program((Node *)NULL, (Node *)NULL);
          };

field_declarations: field_declarations decl {
                       $1->push_back($2);
                       $$ = $1;
                    } |
                    decl {
                       list <Node*> *k = new list <Node*>();
                       k->push_back($1);
                       $$ = k;
                    } ;

method_declarations: method_declarations method_declaration {
                       $1->push_back($2);
                       $$ = $1;
                     } |
                     method_declaration {
                       list <Node*> *k = new list <Node*>();
                       k->push_back($1);
                       $$ = k;
                     };

method_declaration: type ID '(' oparam_list ')' block {
                        Node *n = new MethodDeclaration($1, $2, *($4), $6);
                        $$ = n;
                    } |
                    VOID ID '(' oparam_list ')' block {
                        Node *n = new MethodDeclaration("void", $2, *($4), $6);
                        $$ = n;
                    };

block: '{' var_declarations statements '}' {
            Node *var_decl = new VariableDeclarations(*($2));
            Node *statements = new Statements(*($3));
            Node *n = new Block(var_decl, statements);
            $$ = n;
       };

var_declarations: var_declarations var_decl {
                       $1->push_back($2);
                       $$ = $1;
                  } |
                  {
                      /* Empty */
                      list <Node*> *k = new list<Node*>();
                      $$ = k;
                  };

var_decl: type multiple_var_ids ';' {
             list<Node*>::iterator it;
             int i = 0;
             for(it = $2->begin() ; it!=$2->end() ; it++) {
                i++;
                if (i == 2)
                    break;
             }
             if (i == 1) {
               // only one declaration
                Node* n = *($2->begin());
                $$ = n;
             }
             else {
                Node* n = new VariableDeclarations(*($2));
                $$ = n;
             }
          };

type: INT_DECL {
          decl_type = "integer";
          $$ = $1;
      } |
      BOOL_DECL {
          decl_type = "boolean";
          $$ = $1;
      };

multiple_var_ids: ID {
                    list <Node*> *dec = new list <Node*>();
                    Node* n = new FieldDeclaration(decl_type, string($1), "normal");
                    dec->push_back(n);
                    $$ = dec;
                  } |
                  multiple_var_ids ',' ID {
                    list <Node*> *dec = new list <Node*>();
                    Node* n = new FieldDeclaration(decl_type, string($3), "normal");
                    dec->push_back(n);
                    $1->insert($1->end(), dec->begin(), dec->end());
                    $$ = $1;
                  } ;

oparam_list: param_list {
                $$ = $1;
             } |
            {
              list<Node*> *el = new list<Node*>();
              $$ = el;
            };

param_list: type ID {
            list<Node*> *el = new list<Node*>();
            Node *declaration = new FieldDeclaration($1, $2, "normal", 0);
            el->push_back(declaration);
            $$ = el;
          } |
          type ID ',' param_list {
            list<Node*> *el = new list<Node*>();
            Node *declaration = new FieldDeclaration($1, $2, "normal", 0);
            el->push_back(declaration);
            el->insert(el->end(), $4->begin(), $4->end());
            $$ = el;
          };

decl: type multiple_ids ';' {
        list<Node*>::iterator it = $2->begin();
        int i = 0;
        for(;it!=$2->end();it++) {
          i++;
          if (i == 2) break;
         }
         if (i == 1) {
          Node* n = *($2->begin());
          $$ = n;
         }
         else {
           Node* n = new FieldDeclarations(*($2));
           $$ = n;
        }
      };

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
              };

pid: ID {
       string var_name = $1;
       Node* n = new FieldDeclaration(decl_type, var_name, "normal");
       $$ = n;
       decl_count++;
     }
     |
     ID '[' INT_VALUE ']' {
       string var_name = $1;
       int size = $3;
       Node* n = new FieldDeclaration(decl_type, var_name, "array", size);
       $$ = n;
       decl_count++;
     } ;


statements: statements statement {
              $1->push_back($2);
            }
            | {
            /* empty */
              list <Node*> *k = new list<Node*>();
              $$ = k;
            };

statement: location ass_op expression ';' {
               Node* n = new Assignment($1, $2, $3);
               $$ = n;
               stm_count++;
           }
           |
           procedure_call ';' {
              $$ = $1;
              stm_count++;
           } |
           IF '(' expression ')'  block oelse {
              Node *i = new IFStatement($3, $5);
              Node *e = $6;
              Node *c = new Conditionals(i, e);
              $$ = c;
           } |
           RETURN oreturn ';' {
              $$ = $2;
           } |
           block {
              $$ = $1;
           } |
           FOR ID EQ expression ',' expression block {
              Node *l = new Location($2, "normal", NULL);
              Node *a = new Assignment(l, "=", $4);
              Node *n = new FORStatement(a, $6, $7);
              $$ = n;
           } |
           BREAK ';' {
              Node *n = new Break();
              $$ = n;
           } |
           CONTINUE ';' {
              Node *n = new Continue();
              $$ = n;
           } ;

oelse: ELSE block {
           Node *e = new ELSEStatement($2);
           $$ = e;
       } | {
           $$ = (Node *)NULL;
       };
oreturn: expression {
              Node *n = new Return($1);
              $$ = n;
         } | {
              Node *n = new Return(NULL);
              $$ = n;
         };

ass_op: PEQ {
            $$ = $1;
        } |
        MEQ {
            $$ = $1;
        } |
        EQ {
            $$ = $1;
        };

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

procedure_call: CALLOUT '(' STR_VALUE oarg_list ')' {
                    Node* n = new ProcedureCall("callout", $3, *($4));
                    $$ = n;
                } |
                ID '(' ocarg_list ')' {
                    Node* n = new ProcedureCall("normal", $1, *($3));
                    $$ = n;
                };

oarg_list: ',' arg_list {
             $$ = $2;
           } | {
             list<Node*> *k = new list<Node*>();
             $$ = k;
           } ;

arg_list: expression {
            list <Node*> *el = new list<Node*>();
            el->push_back($1);
            $$ = el;
          } |
          expression ',' arg_list {
            list<Node*> *el = new list <Node*>();
            el->push_back($1);
            el->insert(el->end(), $3->begin(), $3->end());
            $$ = el;
          }

ocarg_list: carg_list {
                $$ = $1;
             } |
            {
              list<Node*> *el = new list<Node*>();
              $$ = el;
            };

carg_list: expression {
            list<Node*> *el = new list<Node*>();
            el->push_back($1);
            $$ = el;
          } |
           expression ',' carg_list {
            list<Node*> *el = new list<Node*>();
            el->push_back($1);
            el->insert(el->end(), $3->begin(), $3->end());
            $$ = el;
          };

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
    do {
        yyparse();
    } while (!feof(yyin));
    // Output to a file
    std::ofstream out("XML_visitor.txt");
    std::streambuf *coutbuf = std::cout.rdbuf(); // save original cout buffer
    std::cout.rdbuf(out.rdbuf()); // redirect std::cout to XML_Visitor.txt
    root->print();
    std::cout.rdbuf(coutbuf); // revert changes
    CodeGenContext Visitor;
    Visitor.generateCode(root);
    Visitor.module->dump();
    return 0;
}

void yyerror(const char *s) {
    cout << s << endl;
    // might as well halt now:
    exit(-1);
}
