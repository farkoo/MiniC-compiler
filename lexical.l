%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<math.h>
	#include "parse.tab.h"
	#include "LinkedList.h"
	
	char flexError = 0;
	int fileno(FILE *stream);

%}

LT	[a-zA-Z_]
DG	[0-9]

%option noyywrap
%option yylineno
%x C_COMMENT

%%
while 			{ return T_WHILE; }
for 			{ return T_FOR; }
int 			{ strcpy(yylval.str, "int"); return T_INT; }
void 			{ strcpy(yylval.str, "void"); return T_VOID; }
continue 		{ return T_CONTINUE; }
break 			{ return T_BREAK; }
if 				{ return T_IF; }
else 			{ return T_ELSE; }
elseif 			{ return T_ELSEIF; }
char 			{ strcpy(yylval.str, "char"); return T_CHAR; }
main 			{ return T_MAIN; }
return 			{ return T_RETURN; }
">="            { return T_GE;}
"<="            { return T_LE;}
"=="            { return T_EQ;}
"!="            { return T_NEQ;}
"&&"            { return T_ANDAND;}
"||"            { return T_OROR;}
[>]             { return T_GT;}
[;]		{ return T_COLON;}
[<]             { return T_LT;}
[!]             { return T_NEGATION;}
[$]             { return T_DOLLAR;}
[,]             { return T_COMMA ;}
[+]             { return T_PLUS;}
[-]             { return T_MINUS;}
[*]             { return T_ASTERISK;}
[/]             { return T_SLASH;}
[=]             { return T_EQUAL;}
[(]             { return T_PARENTHI;}
[)]             { return T_PARENTHD;}
[{]             { return T_ACCOLADEI;}
[}]             { return T_ACCOLADED;}
[|]             { return T_OR;}
[&]             { return T_AND;}
"["             { return T_BRACKETI;}
"]"             { return T_BRACKETD;}
"^"             { return T_POW;}

"'"+.+"'"		{ yylval.number = yytext[1]; return CHARACHTER;}

"#"[^*].* 			{/*do nothing*/}

[ \n\r\t]+ 			{ /**/ }

{LT}({LT}|{DG})* {strcpy(yylval.str, yytext); return ID;}
{DG}{DG}*({LT})+ {printf("ID ERROR!\n"); flexError = 1; exit(0);}

{DG}+ {
	if (labs(atol(yytext)) > pow(2,31)) {
		fprintf(stderr,"ERROR [%i]: |%s| greater than 2^31\n",yylineno,yytext);
		flexError = 1;
		exit(0);
	}
	else {
		yylval.number = atoi(yytext);
		return NUMBER;
	}
}

"#*"            { BEGIN(C_COMMENT); }
<C_COMMENT>"*#" { BEGIN(INITIAL); }
<C_COMMENT>\n   { }
<C_COMMENT>.    { }
<C_COMMENT><<EOF>> {printf("Comment Error!\n"); exit(0);}

[^\n\r\t&|!<> *a-zA-Z0-9_/(),;{}+"=\\-]+ {
	fprintf(stderr,"Unknow token [%d]: %s\n",yylineno,yytext); 
	flexError = 1;
	exit(0);
}

%%


/*int yywrap(){}
int main(int argc, char* argv[])
{
	FILE * fr = fopen(argv[1], "r");
	yyin = fr;
	yylex();
	return 0;
}*/
