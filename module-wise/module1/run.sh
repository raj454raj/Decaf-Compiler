bison -d parser.y
flex scanner.l
g++ -Wno-deprecated -g lex.yy.c parser.tab.c -lfl -o main
#g++ -std=c++11 parser.tab.c lex.yy.c -lfl -o main
./main
rm main
