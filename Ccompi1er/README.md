# Ccompiler

### 已实现(可实现中间代码输出)
 
```
inline float test()
{
	int a;
	int b;
	float cc = a = b == 1+5*b,dd = cc * 2;
}
void main(int x,int y)
{
	int b=20;
}
```
### 另，已实现 if while for
---

编译命令

`bison -d -o compiler.cpp  compiler.y`

`flex -o mylex.cpp compiler.l`

`g++ -std=c++11 -o compiler compiler.cpp mylex.cpp main.cpp`
