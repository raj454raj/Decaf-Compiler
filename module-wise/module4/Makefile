CCC = g++ -g
CCFLAGS= -std=c++11 `llvm-config --cxxflags --libs core --ldflags` -pthread -ltinfo -ldl
LEX = flex
LFLAGS= -8
YACC= bison
YFLAGS= -d -t -y

RM = /bin/rm -f

ast: y.tab.o lex.yy.o ast.o
	${CCC} -fno-rtti -std=c++0x lex.yy.o y.tab.o ast.o -o syntax_analyzer -L/usr/lib/llvm-3.4/lib -lfl -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -lrt -lLLVMCore -lLLVMSupport -pthread -ltinfo -ldl -lm -lz

ast.o: ast.cpp ast.h
	${CCC} ${CCFLAGS} -fno-rtti -c ast.cpp

y.tab.o: parser.y
	${YACC} ${YFLAGS} parser.y
	${CCC} ${CCFLAGS} -fno-rtti y.tab.c -c

lex.yy.o: scanner.l
	${LEX} $(LFLAGS) scanner.l
	${CCC} ${CCFLAGS} -fno-rtti lex.yy.c -c
clean:
	/bin/rm -f lex.yy.* y.tab.* *.o syntax_analyzer *.txt


