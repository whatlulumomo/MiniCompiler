%{
#include"node.h"
#include"element.h"
#include<stdio.h>
#include<iostream>
extern char yytext[];
extern int column;
extern FILE *yyin;
void yyerror(char const *s);
int yylex();
node* root = NULL;
bool hasError = false;
int errorNum = 0;
%}
%union{
	class node* Node;
	class element* Element;
}
%token <Element> IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token <Element> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token <Element> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <Element> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token <Element> XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token <Element> TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token <Element> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token <Element> BOOL COMPLEX IMAGINARY
%token <Element> STRUCT UNION ENUM ELLIPSIS
%token <Element> '&' '*' '+' '-' '~' '!' '/' '<' '>' '^' '|' '%' '='
%token <Element> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%type <Node> primary_expression postfix_expression argument_expression_list unary_expression unary_operator
%type <Node> multiplicative_expression additive_expression shift_expression relational_expression equality_expression cast_expression 
%type <Node> and_expression exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression 
%type <Node> assignment_expression assignment_operator expression conditional_expression constant_expression
%type <Node> declaration init_declarator_list init_declarator type_specifier declaration_specifiers storage_class_specifier type_qualifier function_specifier
%type <Node> declarator direct_declarator 
%type <Node> parameter_list parameter_declaration identifier_list parameter_type_list
%type <Node> abstract_declarator initializer initializer_list designation designator_list
%type <Node> designator statement labeled_statement compound_statement block_item_list block_item expression_statement
%type <Node> selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition
%type <Node> declaration_list
%type <Node> start
%start start
%%

primary_expression
	: IDENTIFIER			{$$=new node("primary_expression",NULL,1,$1);}
	| CONSTANT			{$$=new node("primary_expression",NULL,1,$1);}
	| STRING_LITERAL		{$$=new node("primary_expression",NULL,1,$1);}
	| '(' expression ')'		{$$=$2;}
	;

postfix_expression
	: primary_expression						{$$=$1;}
	| postfix_expression '[' expression ']'				{node* t=$1;while(t->next)t=t->next;t->next=$3;}
	| postfix_expression '(' ')'					{$$=new node("function_call",NULL,0);$$->addSub(1,$1);}
	| postfix_expression '(' argument_expression_list ')'		{$$=new node("function_call",NULL,0);$$->addSub(2,$1,$3);}
	| postfix_expression '.' IDENTIFIER				//abandoned
	| postfix_expression PTR_OP IDENTIFIER				//abandoned
	| postfix_expression INC_OP					//wait to be updated
	| postfix_expression DEC_OP					//wait to be updated
	| '(' type_name ')' '{' initializer_list '}'			//abandoned
	| '(' type_name ')' '{' initializer_list ',' '}'		//abandoned
	;

argument_expression_list
	: assignment_expression						{$$=$1;}
	| argument_expression_list ',' assignment_expression		{node* t=$1;while(t->next)t=t->next;t->next=$3;}
	;

unary_expression
	: postfix_expression						{$$=$1;}
	| INC_OP unary_expression					//wait to be updated
	| DEC_OP unary_expression					//wait to be updated
	| unary_operator cast_expression				//abandoned?
	| SIZEOF unary_expression					//abandoned
	| SIZEOF '(' type_name ')'					//abandoned
	;

unary_operator
	: '&'								{$$=new node("unary_operator",NULL,1,$1);}
	| '*'								{$$=new node("unary_operator",NULL,1,$1);}
	| '+'								{$$=new node("unary_operator",NULL,1,$1);}
	| '-'								{$$=new node("unary_operator",NULL,1,$1);}
	| '~'								{$$=new node("unary_operator",NULL,1,$1);}
	| '!'								{$$=new node("unary_operator",NULL,1,$1);}
	;

cast_expression
	: unary_expression						{$$=$1;}
	| '(' type_name ')' cast_expression				//abandoned
	;

multiplicative_expression
	: cast_expression						{$$=$1;}
	| multiplicative_expression '*' cast_expression			{$$=new node("multiplicative_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| multiplicative_expression '/' cast_expression			{$$=new node("multiplicative_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| multiplicative_expression '%' cast_expression			{$$=new node("multiplicative_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

additive_expression
	: multiplicative_expression					{$$=$1;}
	| additive_expression '+' multiplicative_expression		{$$=new node("additive_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| additive_expression '-' multiplicative_expression		{$$=new node("additive_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

shift_expression
	: additive_expression						{$$=$1;}
	| shift_expression LEFT_OP additive_expression			{$$=new node("shift_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| shift_expression RIGHT_OP additive_expression			{$$=new node("shift_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

relational_expression
	: shift_expression						{$$=$1;}
	| relational_expression '<' shift_expression			{$$=new node("relational_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| relational_expression '>' shift_expression			{$$=new node("relational_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| relational_expression LE_OP shift_expression			{$$=new node("relational_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| relational_expression GE_OP shift_expression			{$$=new node("relational_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

equality_expression
	: relational_expression						{$$=$1;}
	| equality_expression EQ_OP relational_expression		{$$=new node("equality_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	| equality_expression NE_OP relational_expression		{$$=new node("equality_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

and_expression
	: equality_expression						{$$=$1;}
	| and_expression '&' equality_expression			{$$=new node("and_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

exclusive_or_expression
	: and_expression						{$$=$1;}
	| exclusive_or_expression '^' and_expression			{$$=new node("exclusive_or_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

inclusive_or_expression
	: exclusive_or_expression					{$$=$1;}
	| inclusive_or_expression '|' exclusive_or_expression		{$$=new node("exclusive_or_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

logical_and_expression
	: inclusive_or_expression					{$$=$1;}
	| logical_and_expression AND_OP inclusive_or_expression		{$$=new node("logical_and_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

logical_or_expression
	: logical_and_expression					{$$=$1;}
	| logical_or_expression OR_OP logical_and_expression		{$$=new node("logical_or_expression",NULL,0); $$->addSub(3,$1,new node("unary_operator",NULL,1,$2),$3);}
	;

conditional_expression
	: logical_or_expression							{$$=$1;}
	| logical_or_expression '?' expression ':' conditional_expression	{$$=new node("conditional_expression2",NULL,0); $$->addSub(3,$1,$3,$5);}
	;

assignment_expression
	: conditional_expression					{$$=$1;}
	| unary_expression assignment_operator assignment_expression	{$$=new node("assignment_expression",NULL,0);$$->addSub(3,$1,$2,$3);}
	;

assignment_operator
	: '='								{$$=new node("assignment_operator",NULL,1,$1);}
	| MUL_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| DIV_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| MOD_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| ADD_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| SUB_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| LEFT_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| RIGHT_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| AND_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| XOR_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	| OR_ASSIGN							{$$=new node("assignment_operator",NULL,1,$1);}
	;

expression
	: assignment_expression		{$$=$1;}
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression							{$$=$1;}
	;

declaration
	: declaration_specifiers ';'							//I don't think we will use this, which supports "int;".
	| declaration_specifiers init_declarator_list ';'				{$$=new node("declaration",NULL,0);$$->addSub(2,$1,$2);}
	;

declaration_specifiers
	: storage_class_specifier							{$$=$1;}
	| storage_class_specifier declaration_specifiers				{$$=new node("declaration_specifiers",NULL,0);$$->addContents(2,$1,$2);}//Risk of "auto auto int"
	| type_specifier								{$$=$1;}
	| type_specifier declaration_specifiers						{$$=new node("declaration_specifiers",NULL,0);$$->addContents(2,$1,$2);}//It's a sweet drug."int int" "int const"
	| type_qualifier								{$$=$1;}
	| type_qualifier declaration_specifiers						{$$=new node("declaration_specifiers",NULL,0);$$->addContents(2,$1,$2);}//Also a sweet drug.
	| function_specifier								{$$=$1;}//inline
	| function_specifier declaration_specifiers					{$$=new node("declaration_specifiers",NULL,0);$$->addContents(2,$1,$2);}//Risk of "inline inline int"
	;

init_declarator_list
	: init_declarator								{$$=new node("init_declarator_list",NULL,0);$$->addSub(1,$1);}
	| init_declarator_list ',' init_declarator					{$1->addSub(1,$3);$$=$1;}						
	;

init_declarator
	: declarator									{$$=$1;}
	| declarator '=' initializer							{$$ = $1;node* t = new node("initializer_expression",NULL,0);t->addSub(3,$1->copy(),new node("assignment_operator",NULL,1,$2),$3);$$->addSub(1,t);}
	;

storage_class_specifier
	: TYPEDEF									{$$=new node("storage_class_specifier",NULL,1,$1);}//Maybe we will not deal with this.
	| EXTERN									{$$=new node("storage_class_specifier",NULL,1,$1);}
	| STATIC									{$$=new node("storage_class_specifier",NULL,1,$1);}
	| AUTO										{$$=new node("storage_class_specifier",NULL,1,$1);}
	| REGISTER									{$$=new node("storage_class_specifier",NULL,1,$1);}
	;

type_specifier
	: VOID										{$$=new node("type_specifier",NULL,1,$1);}
	| CHAR										{$$=new node("type_specifier",NULL,1,$1);}
	| SHORT										{$$=new node("type_specifier",NULL,1,$1);}
	| INT										{$$=new node("type_specifier",NULL,1,$1);}
	| LONG										{$$=new node("type_specifier",NULL,1,$1);}
	| FLOAT										{$$=new node("type_specifier",NULL,1,$1);}
	| DOUBLE									{$$=new node("type_specifier",NULL,1,$1);}
	| SIGNED									{$$=new node("type_specifier",NULL,1,$1);}
	| UNSIGNED									{$$=new node("type_specifier",NULL,1,$1);}
	| BOOL										{$$=new node("type_specifier",NULL,1,$1);}
	| COMPLEX									//Does C supports this? 
	| IMAGINARY									//Ignore
	| struct_or_union_specifier							//Ignore. Should we deal with it?
	| enum_specifier								//Ignore. Should we deal with it?
	| TYPE_NAME									//lex will not generate TYPE_NAME				
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST												{$$=new node("type_qualifier",NULL,1,$1);}
	| RESTRICT											{$$=new node("type_qualifier",NULL,1,$1);}
	| VOLATILE											{$$=new node("type_qualifier",NULL,1,$1);}
	;

function_specifier
	: INLINE											{$$=new node("function_specifier",NULL,1,$1);}
	;

declarator
	: pointer direct_declarator									//wait to be updated...
	| direct_declarator										{$$=$1;}
	;


direct_declarator
	: IDENTIFIER											{$$=new node("direct_declarator",NULL,1,$1);}
	| '(' declarator ')'
	| direct_declarator '[' type_qualifier_list assignment_expression ']'				//wait to be updated...
	| direct_declarator '[' type_qualifier_list ']'							//wait to be updated...
	| direct_declarator '[' assignment_expression ']'						//wait to be updated...
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'			//wait to be updated...
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'			//wait to be updated...
	| direct_declarator '[' type_qualifier_list '*' ']'						//wait to be updated...
	| direct_declarator '[' '*' ']'									//wait to be updated...
	| direct_declarator '[' ']'									//wait to be updated...
	| direct_declarator '(' parameter_type_list ')'							{$$=$1;$$->addSub(1,$3);}
	| direct_declarator '(' identifier_list ')'							//wait to be updated...
	| direct_declarator '(' ')'									{$$=$1;}	
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list										{$$=$1;}
	| parameter_list ',' ELLIPSIS									//This means "void main(int xx,...)". Shall we give up?
	;

parameter_list
	: parameter_declaration										{$$=$1;}
	| parameter_list ',' parameter_declaration							{node* t=$1;while(t->next)t=t->next;t->next=$3;}
	;

parameter_declaration
	: declaration_specifiers declarator								{$$=new node("parameter_declaration",NULL,0);$$->addContents(2,$1,$2);}
	| declaration_specifiers abstract_declarator							//wait to be updated...
	| declaration_specifiers									//It's be abandoned.
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '[' '*' ']'
	| direct_abstract_declarator '[' '*' ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression										{$$=$1;}
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| designation initializer
	| initializer_list ',' initializer
	| initializer_list ',' designation initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement	{$$=$1;}
	| selection_statement	{$$=$1;}
	| iteration_statement	{$$=$1;}
	| jump_statement
	| error
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'														//This case means nothing.
	| '{' block_item_list '}'												{$$=$2;}
	;

block_item_list
	: block_item														{$$=$1;}
	| block_item_list block_item												{node* t=$1;while(t->next)t=t->next;t->next=$2;}
	;

block_item
	: declaration														{$$=$1;}
	| statement														{$$=$1;}
	;

expression_statement
	: ';'			{$$=new node("null", NULL, 0);}
	| expression ';'	{$$=$1;}
	;

selection_statement
	: IF '(' expression ')' statement					{$$=new node("if_statement", NULL, 0); $$->addSub(2,$3,$5);}
	| IF '(' expression ')' statement ELSE statement	{$$=new node("if_else_statement", NULL, 0); $$->addSub(3,$3,$5,$7);}
	| SWITCH '(' expression ')' statement				{$$=new node("switch_statement", NULL, 0); $$->addSub(2,$3,$5);}
	;

iteration_statement
	: WHILE '(' expression ')' statement				{$$=new node("while_statement", NULL, 0); $$->addSub(2,$3,$5);}
	| DO statement WHILE '(' expression ')' ';'			{$$=new node("do_while_statement", NULL, 0); $$->addSub(2,$2,$5);}
	| FOR '(' expression_statement expression_statement ')' statement		{$$=new node("for_statement_exp2", NULL, 0); $$->addSub(3,$3,$4,$6);}
	| FOR '(' expression_statement expression_statement expression ')' statement		{$$=new node("for_statement_exp3", NULL, 0); $$->addSub(4,$3,$4,$5,$7);}
	| FOR '(' declaration expression_statement ')' statement				{$$=new node("for_statement_dcl2", NULL, 0); $$->addSub(3,$3,$4,$6);}
	| FOR '(' declaration expression_statement expression ')' statement		{$$=new node("for_statement_dcl3", NULL, 0); $$->addSub(4,$3,$4,$5,$7);}
	;

jump_statement
	: GOTO IDENTIFIER ';'										//no use
	| CONTINUE ';'											{$$=new node("continue",NULL,1,$1);}
	| BREAK ';'												{$$=new node("break",NULL,1,$1);}
	| RETURN ';'											{$$=new node("return_statement",NULL,1,$1);}
	| RETURN expression ';'									{$$=new node("return_statement",NULL,1,$1); $$->addSub(1,$2);}
	;
start
	:
	translation_unit														{root=$1;}
	;
translation_unit
	: external_declaration														{$$=$1;}
	| translation_unit external_declaration												{node* t=$1;while(t->next)t=t->next;t->next=$2;}
	| error																
	;

external_declaration
	: function_definition														{$$=$1;}
	| declaration															{$$=$1;}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement				//We will not deal with this case!
	| declaration_specifiers declarator compound_statement						{$$=new node("function_definition",NULL,0);$$->addContents(2,$1,$2);$$->addSub(1,$3);}
	;

declaration_list											//This case is abandoned.
	: declaration
	| declaration_list declaration
	| error
	;


%%
void yyerror(char const *s)
{
	fflush(stdout);
	//printf("\n%*s\n%*s\n", column, "^", column, s);
	printf("%----------s--------error here!\n",s);
	hasError = true;
	errorNum++;
}

