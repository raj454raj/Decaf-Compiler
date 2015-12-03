bison -d parser.y
flex scanner.l
g++ -Wno-deprecated -g parser.tab.c lex.yy.c -lfl -o main
#g++ -std=c++11 parser.tab.c lex.yy.c -lfl -o main
./main
rm main
