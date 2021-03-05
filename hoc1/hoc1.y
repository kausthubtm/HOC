%{
#define YYSTYPE double /* data type of the stack */    
%}
%token NUMBER /* declaring tokens */
%left '+' '-' /* left assoc., and same precedence along the line */
%left '*' '/' /* left assoc., higher precedence than '+' and '-' */

/* grammar */
%%
line : line '\n'
     | line expr '\n' { printf("\t%.8g\n", $2); }
     | /* empty */
     ;
    
expr : NUMBER { $$ = $1; }
     | expr '+' expr { $$ = $1 + $3; }
     | expr '-' expr { $$ = $1 - $3; }
     | expr '*' expr { $$ = $1 * $3; }
     | expr '/' expr { $$ = $1 / $3; }
     | '(' expr ')' { $$ = $2; }
     ;  
%%

/* C code */
#include <stdio.h>
#include <ctype.h>
char *progname; /* for error messages */
int lineno = 1;

int main(argc, argv)
    char *argv[];
{
    progname = argv[0];
    yyparse();
}    

/* lex code */

yylex()
{
    int c;
    while ((c=getchar()) == ' ' || c == '\t'); /* ignore blankspaces */
    if (c == EOF) return 0;
    if(c=='.' || isdigit(c)){
        ungetc(c,stdin);
        scanf("%lf", &yylval);     /* number */
        return NUMBER;
    }
    if(c == '\n') lineno++;
    return c;
}

/* errors */
int yyerror (s) 
    char *s;
{
    warning(s, (char *) 0);
}

int warning(s, t)
    char *s, *t;
{
    fprintf(stderr, "%s: %s", progname, s);
    if(t)
        fprintf(stderr, "%s",t);
    fprintf(stderr, " near line %d\n", lineno);
}