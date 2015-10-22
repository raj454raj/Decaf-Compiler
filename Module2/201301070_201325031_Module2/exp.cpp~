#include <bits/stdc++.h>

using namespace std;

class Node
{	
public:	
	string type;
	list <Node *> children;
	
	Node() {}
	~Node() {}
	//virtual Node *clone() = 0;
	//virtual int value () = 0;
	virtual void print() {}
};

class Program : public Node
{
public:
	Program()
	{
		type = "program";
	}	
	~Program() {}
	virtual void print()
	{
		cout<<"<program>\n";
		for(auto it : children)
		{
			it->print();
		}
		cout<<"</program>\n";
	}
};

class Field: public Node
{
public:
	Field()
	{
		type = "Field";
	}
	~Field() {}
	virtual void print()
	{
		cout<<"<field_declarations count=\""<<(int)children.size()<<"\">\n";
		for(auto it : children)
		{
			it->print();
		}
		cout<<"</field_declarations>\n";
	}
};

class Statement: public Node
{
public:
	Statement()
	{
		type = "statement";
	}
	~Statement() {}
	virtual void print()
	{
		cout<<"<statement_declarations count=\""<<(int)children.size()<<"\">\n";
		for(auto it : children)
		{
			it->print();
		}
		cout<<"</statement_declarations>\n";
	}
};

class Declaration: public Node
{
private:
	string name;
	int count;

public:
	Declaration(string _type, string _name, int _count = 0)
	{
		type = _type;
		name = _name;
		count = _count;
	}
	~Declaration() {}
	virtual void print()
	{
		cout<<"<declaration name=\""<<name<<"\" ";
		if(count)
			cout<<"count=\""<<count<<"\" ";
		cout<<"type=\""<<type<<"\"/>\n";
	}
};

class Callout: public Node
{
private:
	string function;

public:
	Callout(string _function)
	{
		type = "callout";
		function = _function;
	}
	~Callout() {}
	virtual void print()
	{
		cout<<"<callout function=\""<<function<<"\">\n";
		for(auto it : children)
		{
			it->print();
		}
		cout<<"</callout>\n";
	}
};

class Location: public Node
{
private:
	string id;

public:
	Location(string _type, string _id)
	{
		type = _type;
		id = _id;
	}
	~Location() {}
	virtual void print()
	{
		if(type == "normal")
		{
			cout<<"<location id=\""<<id<<"\"/>\n";
		}
		else
		{
			cout<<"<location id=\""<<id<<"\">\n";
			cout<<"<position>\n";
			for(auto it : children)
			{
				it->print();
			}
			cout<<"</position>\n";
			cout<<"</location>\n";
		}
	}
};

class Assignment: public Node
{
public:
	Assignment()
	{
		type = "assignment";
	}
	~Assignment() {}
	virtual void print()
	{
		cout<<"<assignment>\n";
		for(auto it : children)
		{
			it->print();
		}
		cout<<"</assignment>\n";
	}
};

class Int_literal: public Node
{
private:
	int value;

public:
	Int_literal(int _value)
	{
		value = _value;
		type = "int_literal";
	}
	~Int_literal(){}
	
	virtual void print()
	{
		cout<<"<integer value=\""<<value<<"\"/>\n";
	}
	
};


class Char_literal: public Node
{
private:
	char value;

public:
	Char_literal(char _value)
	{
		value = _value;
		type = "char_literal";
	}
	~Char_literal(){}
	
	virtual void print()
	{
		cout<<"<character value=\""<<value<<"\"/>\n";
	}
	
};


class Bool_literal: public Node
{
private:
	bool value;

public:
	Bool_literal(bool _value)
	{
		value = _value;
		type = "bool_literal";
	}
	~Bool_literal(){}
	
	virtual void print()
	{
		cout<<"<boolean value=\""<<((value)?"true":"false")<<"\"/>\n";
	}
	
};


class String_literal: public Node
{
private:
	string value;

public:
	String_literal(string _value)
	{
		value = _value;
		type = "string_literal";
	}
	~String_literal(){}
	
	virtual void print()
	{
		cout<<"<string value=\""<<value<<"\"/>\n";
	}

};

class Expression: public Node
{

public:
	Expression(string _type)
	{
		type = _type;
	}
	~Expression(){}

	virtual void print()
	{
		if (children.size() == 1)
		{
			cout<<"<unary_expression type=\""<<type<<"\">\n";
			for(auto it : children)
			{
				it->print();
			}
			cout<<"</unary_expression>\n";
		}
		else
		{
			cout<<"<binary_expression type=\""<<type<<"\">\n";
			for(auto it : children)
			{
				it->print();
			}
			cout<<"</binary_expression>\n";

		}
	}

};

/*int main()
{
	Node *root = new Program();
	Node *fields = new Field();
	root->children.push_back(fields);
	root->print();
	return 0;
}*/