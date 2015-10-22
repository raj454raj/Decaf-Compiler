CCC = g++
CCFLAGS= -std=c++11
LEX = flex
LFLAGS= -8     
YACC= bison 
YFLAGS= -d -t -y

RM = /bin/rm -f

exp: y.tab.o lex.yy.o exp.o
	${CCC} ${CCFLAGS} lex.yy.o y.tab.o exp.o -o syntax_analyzer -lfl

exp.o: exp.cpp
	${CCC} ${CCFLAGS} -c exp.cpp
	
y.tab.o: exp.y
	${YACC} ${YFLAGS} exp.y
	${CCC} ${CCFLAGS} y.tab.c -c 

lex.yy.o: exp.lex
	${LEX} $(LFLAGS) exp.lex
	${CCC} ${CCFLAGS} lex.yy.c -c 
clean:
	/bin/rm -f lex.yy.* y.tab.* *.o syntax_analyzer *.txt

							
