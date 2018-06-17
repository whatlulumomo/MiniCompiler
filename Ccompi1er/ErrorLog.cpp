#include <iostream>
#include <vector>
#include <fstream>
using namespace std;

struct line{
    string content;
    int linenum;
};

class ErrorLog{
    vector<struct line> log;
public:

    void addLog(string content, int linenum){
        struct line t;
        t.content = content;
        t.linenum = linenum;
        log.push_back(t);
    }
    void printErrorLog(){
        ofstream mycout("ErrorLog.txt");
        //cout << endl << "----------------错误报告----------------" << endl;
        //mycout << "----------------错误报告----------------" << endl;
        for(int i=0; i<log.size();i++){
            mycout << log[i].linenum << " : " << log[i].content << endl;
        }
        //mycout << endl << log.size() << " errors, " << log.size() << " warnings" << endl;
        mycout.close();
    }
};