%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <string.h>
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
int buffer_index;
%}


/*
 * Define names for regular expressions here.
 */
INT_CONST       [0-9]
CLASS           [Cc][Ll][Aa][Ss][Ss]
ELSE            [Ee][Ll][Ss][Ee]
IF              [Ii][Ff]
FI              [Ff][Ii]
IN              [Ii][Nn]
INHERITS        [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
ISVOID          [Ii][Ss][Vv][Oo][Ii][Dd]
LET             [Ll][Ee][Tt]
LOOP            [Ll][Oo][Oo][Pp]
POOL            [Pp][Oo][Oo][Ll]
THEN            [Tt][Hh][Ee][Nn]
WHILE           [Ww][Hh][Ii][Ll][Ee]
CASE            [Cc][Aa][Ss][Ee]
ESAC            [Ee][Ss][Aa][Cc]
NEW             [Nn][Ee][Ww]
OF              [Oo][Ff]
NOT             [Nn][Oo][Tt]
BOOL_CONST      (true|false) 
OBJECTID        [a-z][A-Za-z0-9_]*
TYPEID          [A-Z][A-Za-z0-9_]*

%x COMMENTS_DASH
%x COMMENTS_PAREN
%x STRING 
%x STRING_ERROR

%%
\n               {curr_lineno++;}

 /*
  * Begin comments
  */
"--" {BEGIN(COMMENTS_DASH);}

 /*
  * Begin comments
  */
"(*" {BEGIN(COMMENTS_PAREN);}

 /*
  * Do nothing. Ignore all input characters
  */
<COMMENTS_DASH>. {}
<COMMENTS_PAREN>. {}

 /*
  * Count lines in comments
  */
<COMMENTS_PAREN>\n  {curr_lineno++;}

 /*
  * Return to initial state 
  */
<COMMENTS_DASH>\n {BEGIN(INITIAL);}
<COMMENTS_PAREN>"*)" {BEGIN(INITIAL);}

 /*
  * Error handling for comments
  */
<INITIAL>"*)"    {
    cool_yylval.error_msg = strdup("Unmatched *)");
    return ERROR;
}
<COMMENTS_PAREN><<EOF>>   {
    BEGIN(INITIAL);
    cool_yylval.error_msg = strdup("EOF in comment");
    return ERROR;
}
[ \f\r\t\v]+  ;/* Do nothing for white spaces */

 /*
  * Count lines
  */

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
{CLASS}+           { return CLASS; }
{ELSE}+            { return ELSE; }
{IF}+              { return IF; }
{FI}+              { return FI; }
{IN}+              { return IN; }
{INHERITS}+        { return INHERITS; }
{ISVOID}+          { return ISVOID; }
{LET}+             { return LET; }
{LOOP}+            { return LOOP; }
{POOL}+            { return POOL; }
{THEN}+            { return THEN; }
{WHILE}+           { return WHILE; }
{CASE}+            { return CASE; }
{ESAC}+            { return ESAC; }
{NEW}+             { return NEW; }
{OF}+              { return OF; }
{NOT}+             { return NOT; }
{BOOL_CONST}+      { return BOOL_CONST; }


 /*
  * iNTEGERS, Identifiers, and Special Notation
  * 
  */
{INT_CONST}+       { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }
{OBJECTID}+        { cool_yylval.symbol = inttable.add_string(yytext); return OBJECTID; }
{TYPEID}+          { cool_yylval.symbol = inttable.add_string(yytext); return TYPEID; }

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"                 { BEGIN(STRING); buffer_index = 0; }

<STRING>\"           {
  BEGIN(INITIAL);
  string_buf[buffer_index] = '\0';
  cool_yylval.symbol = inttable.add_string(string_buf);
  return STR_CONST;
}

<STRING>.          {
  if(buffer_index + yyleng >= MAX_STR_CONST)
    {
      BEGIN(STRING_ERROR);
      cool_yylval.error_msg = strdup("String constant too long");
      return ERROR;
    }
    else
    {
      for (int i = 0; i < yyleng; i++)
      {
        if (buffer_index + yyleng < MAX_STR_CONST)
        {
          strncpy(string_buf + buffer_index, yytext, yyleng);
          buffer_index += yyleng;
        }
        else
        {
          BEGIN(STRING_ERROR);
          cool_yylval.error_msg = strdup("String constant too long");
          return ERROR;          
        }
      }

    }
}

<STRING>"\\n"         {
  if (buffer_index >= MAX_STR_CONST)
  {
      BEGIN(STRING_ERROR);
      cool_yylval.error_msg = strdup("String constant too long");
      return ERROR;
  }
  string_buf[buffer_index] = '\n';
  buffer_index++;
}

<STRING>"\\0"         {
  if (buffer_index >= MAX_STR_CONST)
  {
      BEGIN(STRING_ERROR);
      cool_yylval.error_msg = strdup("String constant too long");
      return ERROR;
  }
  
  BEGIN(STRING_ERROR);
  cool_yylval.error_msg = strdup("String contains null character");
  string_buf[buffer_index] = '0';
  buffer_index++;

  return ERROR;
}

<STRING><<EOF>>      {
    BEGIN(STRING_ERROR);
    cool_yylval.error_msg = strdup("EOF in string constant");
    return ERROR;
}

<STRING>\n           {
  curr_lineno++;
  if (string_buf[buffer_index-1] != '\\')
  {
    cool_yylval.error_msg = strdup("Unterminated string constant");
    BEGIN(STRING_ERROR);
    return ERROR;   
  }
}

<STRING_ERROR>. ; /* Do nothing while \n is not found */
<STRING_ERROR>\n     { curr_lineno++; BEGIN(INITIAL); }
<STRING_ERROR>\"     { BEGIN(INITIAL); }

 /*
  *  The multiple-character operators.
  */
">="                 {  return DARROW; }
"<="                 {  return DARROW; }
"<-"                 {  return ASSIGN; }

 /*
  * Special characters
  */
"+"                  { return '+'; }
"/"                  { return '/'; }
"-"                  { return '-'; }
"*"                  { return '*'; }
"="                  { return '='; }
"<"                  { return '<'; }
">"                  { return '>'; }
"."                  { return '.'; }
";"                  { return ';'; }
":"                  { return ':'; }
"("                  { return '('; }
")"                  { return ')'; }
"@"                  { return '@'; }
"{"                  { return '{'; }
"}"                  { return '}'; }
","                  { return ','; }
"~"                  { return '~'; }

. {
    cool_yylval.error_msg = strdup(yytext);
    return ERROR;   
} 

%%