#include <iostream>
#include <stdlib.h>
#include <string>
#include <map>
#include <list>
#include "exp.h"

using namespace std;

int depth = 0;

void print_tabs()
{
	for (int i=0; i<depth; i++)
		cout << "\t";
}

//literals start
int_lit::int_lit(int n) : val(n) {}

char_lit::char_lit(char *n) : val(n) {}

bool_lit::bool_lit(string n) : val(n) {}

string_lit::string_lit(string n) : val(n) {}

void int_lit::print()
{
	print_tabs();
	cout << "<integer value=" << val << " />\n";
}

string int_lit::toString()
{
	return to_string(val); 
}

void char_lit::print()
{
	print_tabs();
	cout << "<character value=" << val << " />\n";
}

string char_lit::toString()
{
	return string(val); 
}

void string_lit::print()
{
	print_tabs();
	cout << "<string value=" << val << " />\n";
}

string string_lit::toString()
{
	return val;
}

void bool_lit::print()
{
	print_tabs();
	cout << "<boolean value=";
	cout << val;
	cout << " />\n";
}

string bool_lit::toString()
{
	return val;
}
//literals end

//location start
location_node::location_node(string name, expr_node *pos)
	: id(name), position(pos) {}

void location_node::print()
{
	print_tabs();
	cout << "<location id=" << id;
	if (position != NULL)
	{
		cout << " position=" << position->toString();
	}
	cout << " />\n";
}

string location_node::toString()
{
	if (position != NULL)
	{
		return id + position->toString();
	}
	return id;
}
//location end

//binary exp start
bin_exp::bin_exp(string oper, expr_node *L, expr_node *R)
	: op(oper), left(L), right(R) {}

void bin_exp::print()
{
	print_tabs();
	cout << "<binary_expression type=";
	if (!op.compare("+"))
		cout << "addition";
	if (!op.compare("-"))
		cout << "subtraction";
	if (!op.compare("/"))
		cout << "division";
	if (!op.compare("*"))
		cout << "multiplication";
	if (!op.compare("%"))
		cout << "remainder";
	if (!op.compare("<"))
		cout << "less_than";
	if (!op.compare(">"))
		cout << "greater_than";
	if (!op.compare("<="))
		cout << "less_equal";
	if (!op.compare(">="))
		cout << "greater_equal";
	if (!op.compare("=="))
		cout << "is_equal";
	if (!op.compare("!="))
		cout << "is_not_equal";
	if (!op.compare("&&"))
		cout << "and";
	if (!op.compare("||"))
		cout << "or";
	cout << ">\n";
	
	depth++;
	
	left->print();
	right->print();
	
	depth--;
	
	print_tabs();
	cout << "</binary_expression>\n";
}

string bin_exp::toString()
{
	return left->toString() + op + right->toString();
}
//binary exp end

//unary exp start
un_exp::un_exp(string oper, expr_node *R)
	: op(oper), right(R) {}

void un_exp::print()
{
	print_tabs();
	cout << "<unary_expression type=";
	if (!op.compare("-"))
		cout << "minus";
	else
		cout << "not";
	cout << ">\n";
	depth++;

	right->print();

	depth--;

	print_tabs();
	cout << "</unary_expression>\n";
}

string un_exp::toString()
{
	return op + right->toString();
}
//unary exp end

//assign node start
assign_node::assign_node( expr_node *l, expr_node *expr )
	: loc(l), exp(expr) {}

void assign_node::print()
{
	print_tabs();
	cout << "<assignment>\n";
 	
	depth++;
	
	loc->print();
	exp->print();

	depth--;
	print_tabs();
	cout << "</assignment>\n";
}
//assign node end

//callout node start
callout_node::callout_node(string func_name, list <expr_node *> *arg_list)
	: func(func_name), args(arg_list) {}

void callout_node::print()
{
	print_tabs();
	cout << "<callout function=" << func << ">\n";
	list <expr_node *>::iterator iter;

	int i = 0;
	depth++;
	for (iter = args->begin(); i < args->size(); iter++, i++)
	{
		(*iter)->print();
	}
	depth--;

	print_tabs();
	cout << "</callout>\n";
}
//callout node end

//Field decl start
field_decl::field_decl(string id, string Type, int n)
	: name(id), type(Type), count(n) {}

void field_decl::print()
{
	print_tabs();
	cout << "<declaration name=" << name; 
	if (count != -1)
		cout << " count=" << count;	
	cout << " type=" << type << " />\n";
}
//Field decl end

//program start
pgm::pgm(list <field_decl *> *list1, list <stmt_node *> *list2) 
	: field_list (list1), stmt_list (list2) {}

void pgm::print()
{
	list <field_decl *>::iterator stmtIter1;
	
	cout << "<program>\n";

	depth++;
	
	int i = 0;
	print_tabs();
	cout << "<field_declarations count=" << field_list->size() << ">\n";
	
	depth++;
	for (i = 0, stmtIter1 = field_list->begin(); i < field_list->size(); stmtIter1++, i++) 
	{
		(*stmtIter1)->print();
	}
	depth--;
	
	print_tabs();
	cout << "</field_declarations>" << endl;
	
	list <stmt_node *>::iterator stmtIter2;
	print_tabs();
	cout << "<statement_declarations count=" << stmt_list->size() << ">\n";
	
	depth++;
	for (i = 0, stmtIter2 = stmt_list->begin(); i < field_list->size(); stmtIter2++, i++) 
	{
		(*stmtIter2)->print();
	}
	depth--;
	
	print_tabs();
	cout << "</statement_declarations>\n";
	
	cout << "</program>\n";
}
//program end
