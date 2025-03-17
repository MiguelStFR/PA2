/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <stdio.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
ASSIGN          <-
LE              <=
/* Definição de padrões de identificadores e palavras-chave */
ID              [a-zA-Z][a-zA-Z0-9_]*
TYPEID          [A-Z][a-zA-Z0-9_]*
INT_CONST       [0-9]+

%%

 /*
  *  Nested comments
  */

[ \t\r\f]+       { /* Ignorar */ }

\n              { curr_lineno++; }

--.*           { /* Comentário de linha, ignorar */ }

"(*" {
    int nested = 1;  // Contador de comentários aninhados
    char c;

    while (nested > 0) {
        c = yyinput(); // Lê um caractere diretamente
        if (c == EOF) {
            fprintf(stderr, "Lexical Error in line %d: EOF in comment\n", curr_lineno);
            return ERROR;
        } else if (c == '\n') {
            curr_lineno++;
        } else if (c == '(') {
            if ((c = yyinput()) == '*') nested++; // Detecta comentários aninhados
        } else if (c == '*') {
            if ((c = yyinput()) == ')') nested--; // Fecha comentário
        }
    }
}


\"([^\"\\\n]|\\.)*[\n] {
    fprintf(stderr, "Erro léxico na linha %d: string não fechada\n", curr_lineno);
    return ERROR;
}

\"([^\"\\\n]|\\.)*\" {
    int length = yyleng - 2; // Remove aspas
    if (length >= MAX_STR_CONST) {
        fprintf(stderr, "Erro léxico na linha %d: string muito longa\n", curr_lineno);
        return ERROR;
    }
    
    for (int i = 1; i < length + 1; i++) {
        if (yytext[i] == '\0') {
            fprintf(stderr, "Erro léxico na linha %d: string contém caractere nulo\n", curr_lineno);
            return ERROR;
        }
    }
    
    strncpy(string_buf, yytext + 1, length);
    string_buf[length] = '\0';
    cool_yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
}

 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
{ASSIGN}        { return ASSIGN; }
{LE}            { return LE; }

class           { return CLASS; }
inherits        { return INHERITS; }
if              { return IF; }
then            { return THEN; }
else            { return ELSE; }
while           { return WHILE; }
loop            { return LOOP; }
pool            { return POOL; }
let             { return LET; }
in              { return IN; }
case            { return CASE; }
of              { return OF; }
esac            { return ESAC; }
new             { return NEW; }
isvoid          { return ISVOID; }
not             { return NOT; }
true            { cool_yylval.boolean = 1; return BOOL_CONST; }
false           { cool_yylval.boolean = 0; return BOOL_CONST; }

"*)"	{ 
			  fprintf(stderr, "Lexical Error in line %d: Unmatched *)'\n", curr_lineno); 
			  return ERROR;
		}
		
";"     { return ';'; }
"{"     { return '{'; }
"}"     { return '}'; }
"("     { return '('; }
")"     { return ')'; }
":"     { return ':'; }
"."     { return '.'; }
","     { return ','; }
"@"     { return '@'; }
"~"     { return '~'; }
"="     { return '='; }
"<"     { return '<'; }
">"     { return '<'; }
"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }
"["     { return '['; }
"]"     { return ']'; }

{TYPEID}        { cool_yylval.symbol = stringtable.add_string(yytext); return TYPEID; }
{ID}            { cool_yylval.symbol = stringtable.add_string(yytext); return OBJECTID; }
{INT_CONST}     { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }

.               { 
                  fprintf(stderr, "Erro léxico na linha %d: caractere inválido '%c'\n", curr_lineno, yytext[0]); 
                  return ERROR;
                }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

%%

int yywrap(){
  return 1;
}