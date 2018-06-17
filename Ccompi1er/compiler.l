%option yylineno
D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			([Ee][+-]?{D}+)
P                       ([Pp][+-]?{D}+)
FS			(f|F|l|L)
IS                      ((u|U)|(u|U)?(l|L|ll|LL)|(l|L|ll|LL)(u|U))

%{
#include <stdio.h>
#include "compiler.hpp"
#include "element.h"
void count(void);
void comment();
int check_type();
void yyerror(char const *s);
%}

%%
"/*"			{ comment(); }
"//"[^\n]*              { /* consume //-comment */ }


"auto"			{ count(); yylval.Element = new element(yylineno,"storage_class_specifier","auto");return(AUTO); }
"_Bool"			{ count(); yylval.Element = new element(yylineno,"type_specifier","_Bool");return(BOOL); }
"break"			{ count(); yylval.Element = new element(yylineno,"reserved_keywords","break");return(BREAK); }
"case"			{ count(); return(CASE); }
"char"			{ count(); yylval.Element = new element(yylineno,"type_specifier","char"); return(CHAR); }
"_Complex"		{ count(); /*I abandon this. @txt*/return(COMPLEX); }
"const"			{ count(); yylval.Element = new element(yylineno,"type_qualifier","const");return(CONST); }
"continue"		{ count(); yylval.Element = new element(yylineno,"reserved_keywords","continue");return(CONTINUE); }
"default"		{ count(); return(DEFAULT); }
"do"			{ count(); yylval.Element = new element(yylineno, "iteration_specifier", "do"); return(DO); }
"double"		{ count(); yylval.Element = new element(yylineno,"type_specifier","double"); return(DOUBLE); }
"else"			{ count(); yylval.Element = new element(yylineno, "selection_specifier", "else"); return(ELSE); }
"enum"			{ count(); return(ENUM); }
"extern"		{ count(); yylval.Element = new element(yylineno,"storage_class_specifier","extern");return(EXTERN); }
"float"			{ count(); yylval.Element = new element(yylineno,"type_specifier","float"); return(FLOAT); }
"for"			{ count(); yylval.Element = new element(yylineno, "iteration_specifier", "for"); return(FOR); }
"goto"			{ count(); return(GOTO); }
"if"			{ count(); yylval.Element = new element(yylineno, "selection_specifier", "if"); return(IF); }
"_Imaginary"		{ count(); /*I abandon this. @txt*/return(IMAGINARY); }
"inline"		{ count(); yylval.Element = new element(yylineno,"function_specifier","inline");return(INLINE); }
"int"			{ count(); yylval.Element = new element(yylineno,"type_specifier","int"); return(INT); }
"long"			{ count(); yylval.Element = new element(yylineno,"type_specifier","long"); return(LONG); }
"register"		{ count(); yylval.Element = new element(yylineno,"storage_class_specifier","register");return(REGISTER); }
"restrict"		{ count(); yylval.Element = new element(yylineno,"type_qualifier","restrict");return(RESTRICT); }
"return"		{ count(); yylval.Element = new element(yylineno,"reserved_keywords","return");return(RETURN); }
"short"			{ count(); yylval.Element = new element(yylineno,"type_specifier","short"); return(SHORT); }
"signed"		{ count(); yylval.Element = new element(yylineno,"type_specifier","signed");return(SIGNED); }
"sizeof"		{ count(); return(SIZEOF); }
"static"		{ count(); yylval.Element = new element(yylineno,"storage_class_specifier","static");return(STATIC); }
"struct"		{ count(); return(STRUCT); }
"switch"		{ count(); yylval.Element = new element(yylineno, "selection_specifier", "swtich"); return(SWITCH); }
"typedef"		{ count(); yylval.Element = new element(yylineno,"storage_class_specifier","typedef");return(TYPEDEF); }
"union"			{ count(); return(UNION); }
"unsigned"		{ count(); yylval.Element = new element(yylineno,"type_specifier","unsigned");return(UNSIGNED); }
"void"			{ count(); yylval.Element = new element(yylineno,"type_specifier","void"); return(VOID); }
"volatile"		{ count(); yylval.Element = new element(yylineno,"type_qualifier","volatile");return(VOLATILE); }
"while"			{ count(); yylval.Element = new element(yylineno, "iteration_specifier", "while"); return(WHILE); }

{L}({L}|{D})*		{ count();yylval.Element = new element(yylineno,"IDENTIFIER",yytext); return(check_type()); }

0[xX]{H}+{IS}?		{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
0[0-7]*{IS}?		{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
[1-9]{D}*{IS}?		{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
L?'(\\.|[^\\'\n])+'	{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }

{D}+{E}{FS}?		{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
{D}*"."{D}+{E}?{FS}?	{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
{D}+"."{D}*{E}?{FS}?	{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
0[xX]{H}+{P}{FS}?	{ count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
0[xX]{H}*"."{H}+{P}{FS}?     { count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }
0[xX]{H}+"."{H}*{P}{FS}?     { count(); yylval.Element = new element(yylineno,"CONSTANT",yytext);return(CONSTANT); }


L?\"(\\.|[^\\"\n])*\"	{ count(); yylval.Element = new element(yylineno,"STRING_LITERAL",yytext);return(STRING_LITERAL); }

"..."			{ count(); yylval.Element = new element(yylineno,"ELLIPSIS",yytext);return(ELLIPSIS); }
">>="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(RIGHT_ASSIGN); }
"<<="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(LEFT_ASSIGN); }
"+="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(ADD_ASSIGN); }
"-="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(SUB_ASSIGN); }
"*="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(MUL_ASSIGN); }
"/="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(DIV_ASSIGN); }
"%="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(MOD_ASSIGN); }
"&="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(AND_ASSIGN); }
"^="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(XOR_ASSIGN); }
"|="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return(OR_ASSIGN); }
">>"			{ count(); yylval.Element = new element(yylineno,"RIGHT_OP",yytext);return(RIGHT_OP); }
"<<"			{ count(); yylval.Element = new element(yylineno,"LEFT_OP",yytext);return(LEFT_OP); }
"++"			{ count(); yylval.Element = new element(yylineno,"INC_OP",yytext);return(INC_OP); }
"--"			{ count(); yylval.Element = new element(yylineno,"DEC_OP",yytext);return(DEC_OP); }
"->"			{ count(); yylval.Element = new element(yylineno,"PTR_OP",yytext);return(PTR_OP); }
"&&"			{ count(); yylval.Element = new element(yylineno,"AND_OP",yytext);return(AND_OP); }
"||"			{ count(); yylval.Element = new element(yylineno,"OR_OP",yytext);return(OR_OP); }
"<="			{ count(); yylval.Element = new element(yylineno,"LE_OP",yytext);return(LE_OP); }
">="			{ count(); yylval.Element = new element(yylineno,"GE_OP",yytext);return(GE_OP); }
"=="			{ count(); yylval.Element = new element(yylineno,"EQ_OP",yytext);return(EQ_OP); }
"!="			{ count(); yylval.Element = new element(yylineno,"NE_OP",yytext);return(NE_OP); }
";"			{ count(); return(';'); }
("{"|"<%")		{ count(); return('{'); }
("}"|"%>")		{ count(); return('}'); }
","			{ count(); return(','); }
":"			{ count(); return(':'); }
"="			{ count(); yylval.Element = new element(yylineno,"assignment_operator",yytext);return('='); }
"("			{ count(); return('('); }
")"			{ count(); return(')'); }
("["|"<:")		{ count(); return('['); }
("]"|":>")		{ count(); return(']'); }
"."			{ count(); return('.'); }
"&"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('&'); }
"!"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('!'); }
"~"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('~'); }
"-"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('-'); }
"+"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('+'); }
"*"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('*'); }
"/"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('/'); }
"%"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('%'); }
"<"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('<'); }
">"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('>'); }
"^"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('^'); }
"|"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('|'); }
"?"			{ count(); yylval.Element = new element(yylineno,"unary_operator",yytext);return('?'); }

[ \t\v\n\f]		{ count(); }
.			{ /* Add code to complain about unmatched characters */ }

%%

int yywrap(void)
{
	return 1;
}


void comment(void)
{
	char c, prev = 0;
  
	while ((c = yyinput()) != 0)      /* (EOF maps to 0) */
	{
		if (c == '/' && prev == '*')
			return;
		prev = c;
	}
	yyerror("unterminated comment");
}


int column = 0;

void count(void)
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;

	ECHO;
}


int check_type(void)
{
/*
* pseudo code --- this is what it should check
*
*	if (yytext == type_name)
*		return TYPE_NAME;
*
*	return IDENTIFIER;
*/

/*
*	it actually will only return IDENTIFIER
*/

	return IDENTIFIER;
}
