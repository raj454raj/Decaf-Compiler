#include <iostream>
#include <stdlib.h>
#include <string>
#include <map>
#include <list>

using namespace std;


class stmt_node
{
	public:
		virtual void print() {}
};

class expr_node
{
	public:
		virtual void print() {}
		virtual string toString() {}
};

class location_node : public expr_node
{
	protected:
		string id;
		expr_node *position;
	public:
		location_node(string name, expr_node *pos);
	void print();
	string toString();
};

class int_lit : public expr_node
{
	public:
		int val;
		int_lit(int n);
	void print();
	string toString();
};

class char_lit : public expr_node
{
	protected:
		char *val;
	public:
		char_lit(char *n);
	void print();
	string toString();
};

class bool_lit : public expr_node
{
	protected:
		string val;
	public:
		bool_lit(string n);
	void print();
	string toString();
};

class string_lit : public expr_node
{
	protected:
		string val;
	public:
		string_lit(string n);
	void print();
	string toString();
};

class bin_exp : public expr_node
{
	protected:
		string op;
		expr_node *left;
		expr_node *right;
	public:
		bin_exp(string oper, expr_node *L, expr_node *R);
	void print();
	string toString();
};

class un_exp : public expr_node
{
	protected:
		string op;
		expr_node *right;
	public:
		un_exp(string oper, expr_node *R);
	void print();
	string toString();
};

class assign_node : public stmt_node
{
	protected:
		expr_node *loc;
		expr_node *exp;
	public:
		assign_node( expr_node *l, expr_node *expr );
	void print();
};

class callout_node : public stmt_node
{
	protected:
		string func;
		list <expr_node *> *args;
	public:
		callout_node( string func_name, list <expr_node *> *arg_list );
	void print();
};

class field_decl
{
	protected:
		string name;
		string type;
		int count;
	public:
		field_decl( string id, string Type, int n );
	void print();
};

class pgm
{
	protected:
		list <field_decl *> *field_list;
		list <stmt_node *> *stmt_list;
	public:
		pgm( list <field_decl *> *list1, list <stmt_node *> *list2 );
	void print();
};
