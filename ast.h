#include <bits/stdc++.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/PassManager.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/CallingConv.h>
#include <llvm/Bitcode/ReaderWriter.h>
#include <llvm/Analysis/Verifier.h>
#include <llvm/Assembly/PrintModulePass.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/Support/raw_ostream.h>
// Hopefully both the namespaces do not provide any common method/Class
// For C++ standard namespace
using namespace std;
// For llvm API
using namespace llvm;

class CodeGenBlock;
class CodeGenContext;
static IRBuilder<> Builder(getGlobalContext());

class Node {
  public:
    string class_type;
    virtual Value *codeGen(CodeGenContext &context) {}
    string int_to_str(int value) {
      ostringstream ss;
      ss << value;
      return ss.str();
    };
    void printChildren(list<Node*> &children) {
      list <Node*>::iterator it;
      for(it=children.begin(); it!=children.end() ; it++) {
        (*it)->print();
      }
    };
    virtual void print () = 0;
};

class Program : public Node {
  public:
    // left are declarations
    Node* left;
    // right are statements
    Node* right;
    virtual Value *codeGen(CodeGenContext &context);
    Program(Node* _left, Node* _right) {
      left = _left;
      right = _right;
      class_type = "program";
    };
    void print () {
      cout << "<program>" << endl;
      if(left)
        left->print();
      if(right)
        right->print();
      cout << "</program>" << endl;
    };
};

class FieldDeclarations: public Node {
  public:
    list <Node*> ds;
    virtual Value *codeGen(CodeGenContext &context);
    FieldDeclarations(list <Node*> _ds) {
      ds = _ds;
      class_type = "field_declarations";
    };
    void print () {
        cout << "<field_declarations>\n";
        printChildren(ds);
        cout << "</field_declarations>\n";
    };
};

class MethodDeclarations: public Node {
    public:
        list <Node *> ds;
        virtual Value *codeGen(CodeGenContext &context);
        MethodDeclarations(list<Node *> _ds) {
            ds = _ds;
            class_type = "method_declarations";
        }
        void print () {
            cout << "<method_declarations>\n";
            printChildren(ds);
            cout << "</method_declarations>\n";
        }
};

class FieldDeclaration: public Node {
  public:
    string decl_type;
    string var_name;
    string flag;
    int size;
    virtual Value *codeGen(CodeGenContext &context);
    FieldDeclaration(string dtype, string name, string _flag, int _size = 0) {
      decl_type = dtype;
      var_name = name;
      flag = _flag;
      size = _size;
      class_type = "field_declaration";
    };
    void print () {
      if (flag == "normal")
        cout << "<field_declaration name='" + var_name + "' type='" + decl_type + "' />" << endl;
      else
        cout << "<field_declaration name='" + var_name + "' count='" + int_to_str(size) + "' type='" + decl_type + "' />" << endl;
    }
};

class MethodDeclaration: public Node {
    public:
        list<Node*> params;
        string fn_name, return_type;
        Node *body;
        virtual Value *codeGen(CodeGenContext &context);
        MethodDeclaration(string _rettype, string id, list<Node*> _params, Node* _body) {
            return_type = _rettype;
            params = _params;
            fn_name = id;
            body = _body;
            class_type = "method_declaration";
        }
        void print() {
            cout << "<method_declaration return_type='" + return_type + "' fn_name='" + fn_name + "'>\n";
            list<Node*>::iterator it;
            for(it = params.begin() ; it != params.end() ; ++it) {
                (*it)->print();
            }
            cout << "<method-body>\n";
            body->print();
            cout << "</method-body>\n";
            cout << "</method_declaration>\n";
        }
};

class Block: public Node {
    public:
        // Variable Declarations
        Node *left;
        // Statements
        Node *right;
        virtual Value *codeGen(CodeGenContext &context);
        Block(Node* _left, Node* _right) {
            left = _left;
            right = _right;
            class_type = "block";
        }
        void print() {
            cout << "<block>\n";
            left->print();
            right->print();
            cout << "</block>\n";
        }
};

class Statements: public Node {
  public:
    list <Node*> ss;
    virtual Value *codeGen(CodeGenContext &context);
    Statements(list <Node*> _ss) {
      ss = _ss;
      class_type = "statements";
    };
    void print () {
        cout << "<statements>\n";
        printChildren(ss);
        cout << "</statements>\n";
    };
};

class VariableDeclarations: public Node {
    public:
        list<Node *> declarations;
        virtual Value *codeGen(CodeGenContext &context);
        VariableDeclarations(list<Node *> _ds) {
            declarations = _ds;
            class_type = "variable_declarations";
        }
        void print() {
            cout << "<variable_declarations>\n";
            printChildren(declarations);
            cout << "</variable_declarations>\n";
        }
};

class Assignment: public Node {
  public:
    Node* left;
    Node* right;
    string assgn_op;
    virtual Value *codeGen(CodeGenContext &context);
    Assignment(Node* _left, string _assgn_op, Node* _right) {
      left = _left;
      right = _right;
      assgn_op = _assgn_op;
      class_type = "assignment";
    };
    void print() {
      cout << "<assignment op='" + assgn_op + "'>\n";
      left->print();
      right->print();
      cout << "</assignment>\n";
    };
};

class Location: public Node {
  public:
    string var_name;
    // index for an array
    Node* exp;
    string flag;
    virtual Value *codeGen(CodeGenContext &context);
    string getVarName() {
        return var_name;
    }
    Location(string name, string _flag, Node* _exp = NULL) {
      var_name = name;
      exp = _exp;
      flag = _flag;
      class_type = "location";
    };
    void print() {
      if (flag == "normal") {
        cout << "<location id='" + var_name + "' />" << endl;
      } else {
        cout << "<location id='" + var_name + "'>" << endl;
        cout << "<position>\n";
        exp->print();
        cout << "</position>\n";
        cout << "</location>" << endl;
      }
    }
};

class Literal: public Node {
  public:
    string type;
    string val;
    virtual Value *codeGen(CodeGenContext &context);
    Literal(string t, string v) {
      type = t;
      val = v;
      class_type = "literal";
    };
    void print() {
      if (type == "string") cout << "<" + type + " value='" + val + "' />" << endl;
      else if (type == "character") cout << "<" + type + " value='" + val[1] + "' />" << endl;
      else cout << "<" + type + " value='" + val + "' />" << endl;
    };
};

class BinaryOp: public Node {
  public:
    string op;
    Node* lrand;
    Node* rrand;
    virtual Value *codeGen(CodeGenContext &context);
    BinaryOp(string _op, Node* _lrand, Node* _rrand) {
      op = _op;
      lrand = _lrand;
      rrand = _rrand;
      class_type = "binary_op";
    };
    void print () {
      cout << "<binary_expression type='" + op + "'>" << endl;
      lrand->print();
      rrand->print();
      cout << "</binary_expression>" << endl;
    };
};

class UnaryOp: public Node {
  public:
    string op;
    Node* rrand;
    virtual Value *codeGen(CodeGenContext &context);
    UnaryOp(string _op, Node* _rrand) {
      op = _op;
      rrand = _rrand;
      class_type = "unary_op";
    };
    void print() {
      cout << "<unary_expression type='" + op + "'>" << endl;
      rrand->print();
      cout << "</unary_expression>" << endl;
    }
};

class ProcedureCall: public Node {
  public:
    string fn_name;
    list<Node*> args;
    string flag;
    virtual Value *codeGen(CodeGenContext &context);
    ProcedureCall(string f, string fname, list<Node*> k) {
      if(f == "callout") {
        fn_name = fname.substr(1, fname.size() - 2);
      }
      else {
        fn_name = fname;
      }
      args = k;
      flag = f;
      class_type = "procedure_call";
    };
    void print() {
        if(flag == "callout") {
            cout << "<callout function='" + fn_name + "'>" << endl;
            printChildren(args);
            cout << "</callout>" << endl;
        }
        else {
            cout << "<function-call name='" + fn_name + "'>\n";
            printChildren(args);
            cout << "</function-call>\n";
        }
    };
};

class Conditionals: public Node {
    public:
        Node *ifpart;
        Node *elsepart;
        virtual Value *codeGen(CodeGenContext &context);
        Conditionals(Node *_ifp, Node *_elsep) {
            ifpart = _ifp;
            elsepart = _elsep;
            class_type = "conditionals";
        }
        void print() {
            ifpart->print();
            // If only if is given
            if(elsepart) {
                elsepart->print();
            }
        }
};

class IFStatement: public Node {
    public:
        Node *test;
        Node *body;
        virtual Value *codeGen(CodeGenContext &context) {};
        IFStatement(Node* _test, Node* _body) {
            test = _test;
            body = _body;
            class_type = "if_statement";
        }
        void print() {
            cout << "<if>\n";
            cout << "<if-test>\n";
            test->print();
            cout << "</if-test>\n";
            cout << "<if-body>\n";
            body->print();
            cout << "</if-body>\n";
            cout << "</if>\n";
        }
};

class ELSEStatement: public Node {
    public:
        Node *body;
        virtual Value *codeGen(CodeGenContext &context) {};
        ELSEStatement(Node* _body) {
            body = _body;
            class_type = "else_statement";
        }
        void print() {
            cout << "<else>\n";
            cout << "<else-body>\n";
            body->print();
            cout << "</else-body>\n";
            cout << "</else>\n";
        }
};

class FORStatement: public Node {
    public:
        Node *assignment;
        Node *end;
        Node *body;
        virtual Value *codeGen(CodeGenContext &context);
        FORStatement(Node* _assgn, Node* _end, Node* _body) {
            assignment = _assgn;
            end = _end;
            body = _body;
            class_type = "for_statement";
        }
        void print() {
            cout << "<for>\n";
            cout << "<start>\n";
            assignment->print();
            cout << "</start>\n";
            cout << "<end>\n";
            end->print();
            cout << "</end>\n";
            cout << "<for-body>\n";
            body->print();
            cout << "</for-body>\n";
            cout << "</for>\n";
        }
};

class Return: public Node {
    public:
        Node *value;
        virtual Value *codeGen(CodeGenContext &context);
        Return(Node* _exp) {
            value = _exp;
            class_type = "return";
        }
        void print() {
            cout << "<return>\n";
            // If there is some return value
            if(value)
                value->print();
            cout << "</return>\n";
        }
};

class Break: public Node {
    public:
        virtual Value *codeGen(CodeGenContext &context) {};
        Break() {
            class_type = "break";
        }
        void print() {
            cout << "<break />\n";
        }
};

class Continue: public Node {
    public:
        virtual Value *codeGen(CodeGenContext &context) {};
        Continue() {
            class_type = "continue";
        }
        void print() {
            cout << "<continue />\n";
        }
};
class CodeGenBlock {
    public:
        BasicBlock *block;
        map<string, Value*> locals;
};

class CodeGenContext {
    public:
        list<CodeGenBlock *> blocks;
        Function *mainFunction;
        Module *module;
        void generateCode(Node *root);
        // Constructor
        CodeGenContext() {
            module = new Module("main", getGlobalContext());
        }

        Value* load(Value* v, string n) {
            list<CodeGenBlock *>::iterator it;
            for(it=blocks.begin(); it!=blocks.end(); it++) {
                return Builder.CreateLoad(v);
            }
            return NULL;
        }

        map<string, Value*>& locals() {
            return blocks.back()->locals;
        }

        void pushBlock(BasicBlock *block) {
            blocks.push_back(new CodeGenBlock());
            blocks.back()->block = block;
        }

        Value* getVar(string id) {
            list<CodeGenBlock *>::iterator it;
            for(it = blocks.begin() ; it != blocks.end(); it++) {
                if((*it)->locals.find(id) != (*it)->locals.end())
                    return (*it)->locals[id];
            }
            return module->getGlobalVariable(id);
        }
        void popBlock() {
            CodeGenBlock *topBlock = blocks.back();
            blocks.pop_back();
            // Free the memory allocated to the block
            delete topBlock;
        }
        BasicBlock *currentBlock() {
            return blocks.back()->block;
        }

};
