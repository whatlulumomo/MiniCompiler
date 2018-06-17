#ifndef _ELEMENT_H
#define _ELEMENT_H
#include<string>
using namespace std;
class element
{
public:
	int lineNum;
	string content;
	string name;
	element(int lineNum,string name,string content){
		this->lineNum = lineNum;
		this->name = name;
		this->content = content;	
	}
};
#endif
