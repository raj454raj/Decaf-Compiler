#include <bits/stdc++.h>

using namespace std;

class Node {
  public:
    string int_to_str(int value) {
      ostringstream ss;
      ss << value;
      return ss.str();
    };
    void printChildren(list<Node*> &children) {
      list <Node*>::iterator it;
      for(it=children.begin(); it!=children.end() ; it++) {
        (*(it))->print();
      }
    };
    virtual void print () = 0;
};

class Program : public Node {
  private:
    // left are declarations
    Node* left;
    // right are statements
    Node* right;
    int dcount;
    int scount;
  public:
    Program(Node* _left, int _dcount, Node* _right, int _scount) {
      left = _left;
      dcount = _dcount;
      right = _right;
      scount = _scount;
    };
    void print () {
      cout << "<program>" << endl;
      cout << "<field_declarations count=\"" + int_to_str(dcount) + "\">" << endl;
      left->print();
      cout << "</field_declarations>" << endl;
      cout << "<statement_declarations count=\"" + int_to_str(scount) + "\">" << endl;
      right->print();
      cout << "</statement_declarations>" << endl;
      cout << "</program>" << endl;
    };
};

class Declarations: public Node {
  private:
    list <Node*> ds;
  public:
    Declarations(list <Node*> _ds) {
      ds = _ds;
    };
    void print () {
      printChildren(ds);
    };
};

class Declaration: public Node {
  private:
    string decl_type;
    string var_name;
    string flag;
    int size;
  public:
    Declaration(string dtype, string name, string _flag, int _size = 0) {
      decl_type = dtype;
      var_name = name;
      flag = _flag;
      size = _size;
    };
    void print () {
      if (flag == "normal")
        cout << "<declaration name=\"" + var_name + "\" type=\"" + decl_type + "\" />" << endl;
      else
        cout << "<declaration name=\"" + var_name + "\" count=\"" + int_to_str(size) + "\" type=\"" + decl_type + "\" />" << endl;
    }
};

class Statements: public Node {
  private:
    list <Node*> ss;
  public:
    Statements(list <Node*> _ss) {
      ss = _ss;
    };
    void print () {
      printChildren(ss);
    };
};

class Assignment: public Node {
  private:
    Node* left;
    Node* right;
  public:
    Assignment(Node* _left, Node* _right) {
      left = _left;
      right = _right;
    };
    void print() {
      cout << "<assignment>\n";
      left->print();
      right->print();
      cout << "</assignment>\n";
    };
};

class Location: public Node {
  private:
    string var_name;
    // index for an array
    Node* exp;
    string flag;
  public:
    Location(string name, string _flag, Node* _exp = NULL) {
      var_name = name;
      exp = _exp;
      flag = _flag;
    };
    void print() {
      if (flag == "normal") {
        cout << "<location id=\"" + var_name + "\" />" << endl;
      } else {
        cout << "<location id=\"" + var_name + "\">" << endl;
        cout << "<position>\n";
        exp->print();
        cout << "</position>\n";
        cout << "</location>" << endl;
      }
    }
};

/*
class Expression: public Node {
  private:
    Node* child;
  public:
    Expression(Node* _child) {
      child = _child;
    };
    void print() {
      child->print();  
    };
};*/

class Literal: public Node {
  private:
    string type;
    string val;
  public:
    Literal(string t, string v) {
      type = t;
      val = v;
    };
    void print() {
      if (type == "string") cout << "<" + type + " value=" + val + " />" << endl; 
      else if (type == "character") cout << "<" + type + " value=\"" + val[1] + "\" />" << endl;
      else cout << "<" + type + " value=\"" + val + "\" />" << endl;
    };
};

class BinaryOp: public Node {
  private:
    string op;
    Node* lrand;
    Node* rrand;
  public:
    BinaryOp(string _op, Node* _lrand, Node* _rrand) {
      op = _op;
      lrand = _lrand;
      rrand = _rrand;
    };
    void print () {
      cout << "<binary_expression type=\"" + op + "\">" << endl;
      lrand->print();
      rrand->print();
      cout << "</binary_expression>" << endl;
    };
};

class UnaryOp: public Node {
  private:
    string op;
    Node* rrand;
  public:
    UnaryOp(string _op, Node* _rrand) {
      op = _op;
      rrand = _rrand;
    };
    void print() {
      cout << "<unary_expression type=\"" + op + "\">" << endl;
      rrand->print();
      cout << "</unary_expression>" << endl;
    }
};

class ProcedureCall: public Node {
  private:
    string fn_name;
    list<Node*> args;
  public:
    ProcedureCall(string fname, list<Node*> k) {
      fn_name = fname;
      args = k;
    };
    void print() {
      cout << "<callout function=" + fn_name + ">" << endl;
      printChildren(args);
      cout << "</callout>" << endl;
    };
};
