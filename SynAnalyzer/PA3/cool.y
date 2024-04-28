/*
 *  cool.y
 *
 *            Parser definition for the COOL language.
*  			  TP3 Compiladores: Manual de referência  https://theory.stanford.edu/~aiken/software/cool/cool-manual.pdf
*/
%{
#include <iostream>
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"
#include "list.h"

extern char *curr_filename;


/* Locations */
/* O YYLLOC_DEFAULT macro é definido no bison.h
 Mas como exemplificado no manual na página 73 não está diretamente definido para Cool então estamos utilizando esse fix abaixo:
*/
#define YYLTYPE int              /* Tipo da Location */
#define cool_yylloc curr_lineno  /* curr_lineno para localização do token atual*/

extern int node_lineno;  /* Localiação do nó atual*/        

/* Redefinição do YYLLOC_DEFAULT para funcionar em COOL */   
#define YYLLOC_DEFAULT(Current, Rhs, N)         \
Current = Rhs[1];                             \
node_lineno = Current;

/* Localização do nó */  
#define SET_NODELOC(Current)  \
node_lineno = Current;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */

/* Para evitar errors de conversões de tipos */
char obj_str[] = "Object";
char self_str[] = "self";

/************************************************************************/
/*                DONT CHANGE ANYTHING IN THIS SECTION                  */

Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of errors in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
}

/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.

   The integer following token declaration is the numeric constant used
   to represent that token internally.  Typically, Bison generates these
   on its own, but we give explicit numbers to prevent version parity
   problems (bison 1.25 and earlier start at 258, later versions -- at
   257)
*/
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276 
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279 
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/
 
   /* Complete the nonterminal list below, giving a type for the semantic
      value of each non terminal. (See section 3.6 in the bison 
      documentation for details). */

/* Declare types for the grammar's non-terminals. */
%type <program> program
%type <classes> class_list
%type <class_> class

/* You will want to change the following line. */
%type <features> features_list
%type <features> features
%type <feature> feature

%type <formals> formals
%type <formal> formal

%type <cases> case_branch_list 
%type <case_> case_branch

%type <expressions> expr_list
%type <expressions> param_expr
%type <expression> expr
%type <expression> let_expr
%type <expression> in_let


/* Precedence declarations go here. */
/* Ref: Cool Manual 11.1 Precedence  e Manual Bison3.3 "5.3.4 Precedence Examples"*/
%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '+' '-'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'
%precedence IN

%%
/* 
 * Save the root of the abstract syntax tree in a global variable.
 * Estamos nos baseando na ´Figure 1: Cool syntax.` do Manual
*/ 
program: class_list { @$ = @1; ast_root = program($1); }
			;

class_list
	: class			/* single class */
		{ $$ = single_Classes($1);
                  parse_results = $$; }
	| class_list class	/* several classes */
		{ $$ = append_Classes($1,single_Classes($2)); 
                  parse_results = $$; }
	;

/* 
 * Manual de Cool Figura 1: class ::= class TYPE [inherits TYPE] { [[feature; ]]∗
 */
class : CLASS TYPEID '{' features_list '}' ';'
			{ $$ = class_($2,idtable.add_string(obj_str),$4, stringtable.add_string(curr_filename)); }	// Por não ter herança, A classe vai herdar de Object
	| CLASS TYPEID INHERITS TYPEID '{' features_list '}' ';'
			{ $$ = class_($2,$4,$6,stringtable.add_string(curr_filename)); }
			/* Limpando o lookahead em casos de erro Bison3.3  Manual Pagina 114 yyclearin ; [Macro] */
			| CLASS TYPEID '{' error '}' ';' { yyclearin; $$ = NULL; }
			| CLASS error '{' features_list '}' ';' { yyclearin; $$ = NULL; }
			| CLASS error '{' error '}' ';' { yyclearin; $$ = NULL; }
			;

/* Feature list may be empty, but no empty features in list. */
features_list: features { $$ = $1; } | { $$ = nil_Features(); } ; // Mesmo que esteja vazio, a lista de features conter um elemento


features    : feature ';' { $$ = single_Features($1); }
			| features feature ';' { $$ = append_Features($1, single_Features($2)); }
			| error ';' { yyclearin; $$ = NULL; }
			;
feature     : OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' { $$ = method($1, $3, $6, $8); }
			/* attribute w/ and w/o assignment */
			| OBJECTID ':' TYPEID { $$ = attr($1, $3, no_expr()); }
			| OBJECTID ':' TYPEID ASSIGN expr { $$ = attr($1, $3, $5); }
			;

/* Definição formal para paramentros dos metódos */
formals   : formal { $$ = single_Formals($1); } /* caso tenha um único argumento no metodo */
			| formals ',' formal { $$ = append_Formals($1, single_Formals($3)); } /* caso tenha um para N argumentos no metodo */
			| { $$ = nil_Formals(); } /* Caso não exista terminais */
			;

formal : OBJECTID ':' TYPEID { $$ = formal($1, $3); }; /* A dedfinição formal de um argumento paramn -> varName ':' TypeOf(var) */

/* As expressões abaixo também, nos casos opcionais e obrigatórios baseados na Figura 1 do manual de cool */
expr        : OBJECTID ASSIGN expr { $$ = assign($1, $3); }
			/* fazer dispatch's: normal, static, omitted self para propriedades e métodos com parametross */
			| expr '.' OBJECTID '(' param_expr ')' { $$ = dispatch($1, $3, $5); }
			| expr '@' TYPEID '.' OBJECTID '(' param_expr ')' { $$ = static_dispatch($1, $3, $5, $7); }
			| OBJECTID '(' param_expr ')' { $$ = dispatch(object(idtable.add_string(self_str)), $1, $3); }

			/* Estruturas de controle */
			| IF expr THEN expr ELSE expr FI { $$ = cond($2, $4, $6); }
			| WHILE expr LOOP expr POOL { $$ = loop($2, $4); }

			/* Bloco de Expressões */
			| '{' expr_list '}' { $$ = block($2); }

			/* nested lets */
			| LET let_expr { $$ = $2; }

			/* Devemos criar uma `case_branch_list` para resolver os casos de 1 para N de expressões */
			| CASE expr OF case_branch_list ESAC { $$ = typcase($2, $4); }

			/* prefix keywords */
			| NEW TYPEID { $$ = new_($2); }
			| ISVOID expr { $$ = isvoid($2); }

			/* operadores  */
			| expr '+' expr { $$ = plus($1, $3); }
			| expr '-' expr { $$ = sub($1, $3); }
			| expr '*' expr { $$ = mul($1, $3); }
			| expr '/' expr { $$ = divide($1, $3); }
			| '~' expr { $$ = neg($2); }
			| expr '<' expr { $$ = lt($1, $3); }
			| expr LE expr { $$ = leq($1, $3); }
			| expr '=' expr { $$ = eq($1, $3); }
			| NOT expr { $$ = comp($2); }
			
			/* parentheses */
			| '(' expr ')' { $$ = $2; }

			/* names */
			| OBJECTID { $$ = object($1); }

			/* literals - strings, numbers, booleans */
			| INT_CONST { $$ = int_const($1); }
			| STR_CONST { $$ = string_const($1); }
			| BOOL_CONST { $$ = bool_const($1); }
			;


/* expressões LET do Manual let ID : TYPE [ <- expr ] [[,ID : TYPE [ <- expr ]]]∗ in expr  [ Figure 1: Cool syntax]*/
let_expr    : OBJECTID ':' TYPEID in_let { $$ = let($1, $3, no_expr(), $4); }
			| OBJECTID ':' TYPEID ASSIGN expr in_let{ $$ = let($1, $3, $5, $6); }
			| OBJECTID ':' TYPEID ',' let_expr { $$ = let($1, $3, no_expr(), $5); }
			| OBJECTID ':' TYPEID ASSIGN expr ',' let_expr { $$ = let($1, $3, $5, $7); }
			/* adiconando errors para evitar terminar a análise síntatica após um erro */
			| error in_let { yyclearin; $$ = NULL; }
			| error ',' let_expr { yyclearin; $$ = NULL; }
			;
in_let :  IN expr { $$ = $2; } ;


// solve : expr { $$ = $1; } | error { yyclearin; $$ = NULL; } ;


/* os blocos podem conter 1 ou mais expressões sepradas por ponto e vírgula [Cool Manual] 7.7 Blocks */
expr_list    : expr ';' { $$ = single_Expressions($1); }
					| expr_list expr ';' { $$ = append_Expressions($1, single_Expressions($2)); }
					/* para evitar terminar a análise síntatica após um erro */
					| error ';' { yyclearin; $$ = NULL; }
					;

param_expr          : expr { $$ = single_Expressions($1); }
					| param_expr ',' expr { $$ = append_Expressions($1, single_Expressions($3)); }
					/* Caso não exista parametros para metodo*/
					| { $$ = nil_Expressions(); }
					;

/* O Conteúdo do [Case] deve conter ao menos um [Case Branch] */
case_branch_list    : case_branch { $$ = single_Cases($1); }
					| case_branch_list case_branch { $$ = append_Cases($1, single_Cases($2)); }
					;

case_branch         : OBJECTID ':' TYPEID DARROW expr ';' { $$ = branch($1, $3, $5); }
					;

/* end of grammar */
%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;

  if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
}

