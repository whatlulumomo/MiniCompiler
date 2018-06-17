#include "mainwindow.h"
#include "QMenu"
#include "QMenuBar"
#include "QAction"
#include "QToolBar"
#include "QDebug"
#include "QPushButton"
#include<cstdlib>
#include<string>
#include<cstdio>
#include<cstring>
#include<iostream>
#include<algorithm>
#include<unistd.h>
#include "QTextBrowser"
#include<fstream>  //ifstream
#include<iostream>
#include"QString"
#include"QFile"

using namespace std ;

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent)
{
    this->setupUi(this);

    //菜单栏
       QMenuBar *mBar = menuBar();

       //添加菜单
       QMenu *pFile = mBar->addMenu("开始");
       pFile->addSeparator();
       QAction * pOpen = pFile->addAction("打开");

       //工具栏--菜单项的快捷方式
       QToolBar *toolBar = addToolBar("toolbar");//创建工具栏
       QPushButton * b = new QPushButton(this);
       b->setText("运行");
       toolBar->addWidget(b);//工具栏添加其他组件--按钮

       QTextBrowser* report = textBrowser;
       QTextBrowser* intercode = textBrowser_2;
       QTextBrowser* assembly = textBrowser_3;

       configEditor = new CodeEditor();
       configEditor->setMode(EDIT);
       gridLayout->addWidget(configEditor);
       MyHighLighter *highlighter = new MyHighLighter(configEditor->document());

       ifstream inf;
       string s;

       inf.open("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er/test.c");
       while (getline(inf, s)) {
           cout << s << endl;
           QString qstring = QString(QString::fromLocal8Bit(s.c_str()));
           configEditor->appendPlainText(qstring);
       }
       inf.close();




       connect(b,&QPushButton::clicked,
               [=](){


                    textBrowser->setPlainText("");
                    textBrowser_2->setPlainText("");
                    textBrowser_3->setPlainText("");

                    QString content = configEditor->toPlainText();
                    QFile outFile("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er/test.c");
                    outFile.open(QIODevice::WriteOnly);
                    QTextStream ts(&outFile);
                    ts << content << endl;

                    ifstream inf;
                    string s;
                    chdir("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er");
                    system("pwd");
                    system("bash Makefile");


                    inf.open("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er/ErrorLog.txt");
                    while (getline(inf, s)) {
                        cout << s << endl;
                        QString qstring = QString(QString::fromLocal8Bit(s.c_str()));
                        textBrowser->append(QString(qstring));
                    }
                    inf.close();

                    inf.open("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er/AST.txt");
                    while (getline(inf, s)) {
                        cout << s << endl;
                        QString qstring = QString(QString::fromLocal8Bit(s.c_str()));
                        textBrowser_2->append(QString(qstring));
                    }
                    inf.close();

                    inf.open("/Users/geshuaiqi/desktop/SyntaxHighlighterEditor/aweSomeEditorhiahia/Ccompi1er/MIPS/objectcode.asm");
                    while (getline(inf, s)) {
                        cout << s << endl;
                        QString qstring = QString(QString::fromLocal8Bit(s.c_str()));
                        textBrowser_3->append(QString(qstring));
                    }
                    inf.close();

                });





}

MainWindow::~MainWindow()
{
}
