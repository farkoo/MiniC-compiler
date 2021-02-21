%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "LinkedList.h"

	int yyerror(char const *s);
	extern int yylex(void);
	extern int yylineno;
	extern FILE * yyin;
	
	var_list *variables;
	func_list *functions;
	
	void check_var_nex(char *name);
	void check_func_nex(char *name, int num);
	void check_var_ex(char *name);
	void check_func_ex(char *name);
	void check_func_ret(char *name, int num);
	void init();
	
	int scope = -1;
	char temp_var[100][50] = {0};
	int temp_val[100] = {-1};
	int i=0;
	int flag = 0;
%}

%define parse.error verbose

%union{
	char str[50];
	int number;
	struct arguments{
		int num;
		char type[4][10];
	}argu;
}

%token<number> T_WHILE
%token<number> T_FOR
%token<str> T_INT
%token<str> T_VOID
%token<number> T_CONTINUE
%token<number> T_BREAK
%token<number> T_IF
%token<number> T_ELSE
%token<number> T_ELSEIF
%token<str> T_CHAR
%token<number> T_MAIN
%token<number> T_RETURN
%token<number> T_GE
%token<number> T_LE
%token<number> T_EQ
%token<number> T_NEQ
%token<number> T_ANDAND
%token<number> T_OROR
%token<number> T_GT
%token<number> T_LT
%token<number> T_NEGATION
%token<number> T_DOLLAR
%token<number> T_COMMA
%token<number> T_PLUS
%token<number> T_MINUS
%token<number> T_ASTERISK
%token<number> T_SLASH
%token<number> T_EQUAL
%token<number> T_PARENTHI
%token<number> T_PARENTHD
%token<number> T_ACCOLADEI
%token<number> T_ACCOLADED
%token<number> T_OR
%token<number> T_AND
%token<number> T_BRACKETI
%token<number> T_BRACKETD
%token<number> T_POW
%token<number> T_COLON
%token<number> CHARACHTER
%token<str> ID
%token<number> NUMBER

%type<argu> args
%type<str> type
%type<str> arg
%type<str> ret_type
%type<str> ids
%type<number> exp
%type<number> call_args

%left T_OROR
%left T_ANDAND
%left T_OR
%left T_POW
%left T_AND
%left T_EQ T_NEQ
%left T_LT T_LE T_GT T_GE
%left T_PLUS T_MINUS
%left T_ASTERISK T_SLASH
%left T_NEGATION
%left T_PARENTHI T_PARENTHD T_BRACKETI T_BRACKETD

%%

pgm : funcs main
funcs : ret_type
	|func funcs
func : ret_type ID T_PARENTHI args T_PARENTHD {check_func_ex($2); push_func_list(functions, $2, $4.num, $4.type, $1);} T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;}
args : {$$.num = 0;}
	| arg {$$.num = 1; strcpy($$.type[0], $1);}
	| arg T_COMMA arg {$$.num = 2; strcpy($$.type[0], $1); strcpy($$.type[1], $3);}
	| arg T_COMMA arg T_COMMA arg {$$.num = 3; strcpy($$.type[0], $1); strcpy($$.type[1], $3); strcpy($$.type[2], $5);}
	| arg T_COMMA arg T_COMMA arg T_COMMA arg {$$.num = 4; strcpy($$.type[0], $1); strcpy($$.type[1], $3); strcpy($$.type[2], $5); strcpy($$.type[3], $7);}

arg : type ID {strcpy($$, $1); push_var_list(variables, $2, $1, scope + 1, -1);}
main : T_MAIN T_PARENTHI T_PARENTHD T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;}
stmts : 
	|stmt stmts
stmt : stmt_declare 
	| stmt_assign 
	| stmt_return 
	| stmt_if 
	| stmt_while 
	| stmt_func_call 
	| stmt_for
	| T_COLON
exp : exp T_LT exp {}
exp : exp T_LE exp {}
exp : exp T_GT exp {}
exp : exp T_GE exp {}
exp : exp T_EQ exp {}
exp : exp T_PLUS exp {$$ = $1 + $3;}
exp : exp T_MINUS exp {$$ = $1 - $3;}
exp : exp T_ASTERISK exp {$$ = $1 * $3;}
exp : exp T_SLASH exp {if($3 == 0){fprintf(stderr, "WARNING: divide by zero, line %d\n",yylineno);} if($3 != 0){$$ = $1 / $3;}}
exp : exp T_ANDAND exp {}
exp : exp T_OROR exp {}
exp : exp T_OR exp {$$ = $1 | $3;}
exp : exp T_AND exp {$$ = $1 | $3;}
exp : exp T_POW exp {$$ = $1 ^ $3;}
exp : exp T_NEQ exp {}
exp : T_NEGATION exp {}
exp : T_MINUS exp {$$ = $2 * (-1);}
exp : T_PARENTHI exp T_PARENTHD {}
exp : ID {check_var_nex($1); var * t = find_var_list(variables, $1); $$ = t->var_value;}
exp : NUMBER {$$ = $1;}
	| CHARACHTER {$$ = $1;}
stmt_declare : type ID ids 
			{check_var_ex($2); push_var_list(variables, $2, $1, scope, -1); for(int j=0 ; j<i ; j++){check_var_ex(temp_var[j]); push_var_list(variables, temp_var[j], $1, scope, temp_val[j]);} i=0;}
			| type declare_assign ids {for(int j=0 ; j<i ; j++){check_var_ex(temp_var[j]); push_var_list(variables, temp_var[j], $1, scope, temp_val[j]);} i=0;}
ids : T_COLON {}
	| T_COMMA ID ids {strcpy(temp_var[i], $2); i++;}
	| T_COMMA declare_assign ids {} 
declare_assign : ID T_EQUAL exp {strcpy(temp_var[i], $1); temp_val[i] = $3; i++;}
				| ID T_EQUAL ID T_PARENTHI call_args T_PARENTHD {strcpy(temp_var[i], $1); i++;}{check_func_ret($3, $5);}
stmt_assign : ID T_EQUAL exp T_COLON {check_var_nex($1); update_var_val(variables, $1, $3);}
stmt_return : T_RETURN exp T_COLON
stmt_if : T_IF T_PARENTHI exp T_PARENTHD T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;} elseifs else
elseifs : 
	 |elseif elseifs
elseif : T_ELSEIF T_PARENTHI exp T_PARENTHD T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;}
else : 
	|T_ELSE T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;}
stmt_while : T_WHILE T_PARENTHI exp T_PARENTHD T_ACCOLADEI {scope++;} stmts T_ACCOLADED {free_scope(variables, scope); scope--;}
stmt_for : T_FOR T_PARENTHI {scope++;} type ID T_EQUAL NUMBER  {check_var_ex($5); push_var_list(variables, $5, $4, scope, $7);} T_COLON exp T_COLON ID T_EQUAL exp T_PARENTHD T_ACCOLADEI  stmts T_ACCOLADED {free_scope(variables, scope); scope--;} 
stmt_func_call : ID T_EQUAL ID T_PARENTHI call_args T_PARENTHD T_COLON {check_var_nex($1); check_func_ret($3, $5);}
		| ID T_PARENTHI call_args T_PARENTHD T_COLON {check_func_nex($1, $3);}
call_args : {$$ = 0;}
		| exp {$$ = 1;}
		| exp T_COMMA exp {$$ = 2;}
		| exp T_COMMA exp T_COMMA exp {$$ = 3;}
		| exp T_COMMA exp T_COMMA exp T_COMMA exp {$$ = 4;}
ret_type : T_INT {strcpy($$, $1); init();}
		| T_VOID {strcpy($$, $1); init();}
type : T_INT {strcpy($$, $1); init();}
		| T_CHAR {strcpy($$, $1); init();}

%%

int main(int argc, char **argv)
{
	FILE * fr = fopen(argv[1], "r");
	yyin = fr;
	yyparse();
	return 0;
}

void init(){
	if(flag == 0){
		variables = init_var_list();
		functions = init_func_list();
		flag = 1;
	}
}

int yyerror(char const *s)
{
  printf("%d: %s\n",yylineno, s);
}

void check_var_nex(char *name){
	var * t = find_var_list(variables, name);
	if(t == NULL){
		fprintf(stderr,"Error: undeclared var %s, line %d\n",name,yylineno);
		exit(0);
	}
}

void check_var_ex(char *name){
	var * t = find_var_list(variables, name);
	if(t != NULL){
		fprintf(stderr,"Error: redeclared var %s, line %d\n",name,yylineno);
		exit(0);
	}
}

void check_func_nex(char *name, int num){
	func * t = find_func_list(functions, name);
	if(t == NULL){
		fprintf(stderr,"Error: undeclared function %s, line %d\n",name,yylineno);
		exit(0);
	}
	else if(t->arg_num != num){
		fprintf(stderr,"Error: Number of arguments are not match in function %s, line %d\n",name,yylineno);
		exit(0);
	}
}

void check_func_ex(char *name){
	func * t = find_func_list(functions, name);
	if(t != NULL){
		fprintf(stderr,"Error: redeclared function %s, line %d\n",name,yylineno);
		exit(0);
	}
}

void check_func_ret(char *name, int num){
	func * t = find_func_list(functions, name);
	if(t == NULL){
		fprintf(stderr,"Error: undeclared function %s, line %d\n",name,yylineno);
		exit(0);
	}
	else if(strcmp(t->ret_type, "void") == 0){
		fprintf(stderr,"Error: function %s return nothing, line %d\n",name,yylineno);
		exit(0);
	}
	else if(t->arg_num != num){
		fprintf(stderr,"Error: Number of arguments are not matched in function %s, line %d\n",name,yylineno);
		exit(0);
	}
}
