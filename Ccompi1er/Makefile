#! /bin/bash
bison -d -o compiler.cpp  compiler.y
flex -o mylex.cpp compiler.l
#g++ -std=c++11 -o compiler compiler.cpp mylex.cpp main.cpp
g++ -std=c++11 -o compiler compiler.cpp mylex.cpp main.cpp 
./compiler > ./MIPS/intercode.txt
echo "--------------AST代码----------------"
cat ./MIPS/intercode.txt
python ./MIPS/MIPS.py >> 2
echo ""
echo "--------------目标代码----------------"
cat ./MIPS/objectcode.asm
python ./FinalProcess.py
echo ""
echo "---------------错误报告-----------------"
cat ./ErrorLog.txt
