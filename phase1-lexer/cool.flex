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

/* This is a hack to
 * a) satisfy the cool compiler which expects yylex to be named cool_yylex (see below)
 * b) satisfy libfl > 2.5.39 which expects a yylex symbol
 * c) fix mangling errors of yylex when compiled with a c++ compiler
 * d) be as non-invasive as possible to the existing assignment code
 */
extern int cool_yylex();
extern "C" {
  int (&yylex) (void) = cool_yylex;
}

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

#include <sstream>
std::stringstream temp_str_buff;


%}

/*
 * Define names for regular expressions here.
 */

%x STRINGG
 // (* ... *)
%x MULTI_LINE_COMMENT
 // --
%x SINGLE_LINE_COMMENT  


CONST_INT				[0-9]+


 // my comment:
 // Type identifiers and object identifiers:

TYPEID 					[A-Z]([A-Z]|[a-z]|[0-9]|_)*
OBJECTID 				[a-z]([A-Z]|[a-z]|[0-9]|_)*

 

 // Identifiers: each letter can be capital or small except false and true. these 2 exceptions should start with small letter.
 
CLASS					(?i:class)
ELSE 					(?i:else)
IF					(?i:if)
FI					(?i:fi)
IN					(?i:in)
INHERITS				(?i:inherits)
ISVOID 					(?i:isvoid)
LET					(?:let)
LOOP 					(?i:loop)
POOL 					(?i:pool)
THEN 					(?i:then)
WHILE 					(?i:while)
CASE 					(?i:case)
ESAC 					(?i:esac)
NEW 					(?i:new)
OF 					(?i:of)
NOT 					(?i:not)

FALSE 					f(?i:alse)
TRUE  					t(?i:rue)

  // other things
WHITE_SPACE				[ \n\f\r\t\v]

ASSIGN					"<-"
MUL_COMMENT_START		   	"(*"
MUL_COMMENT_END				"*)"
DOUBLE_DASH				"--"
DOUBLE_QUOTE				"\""
BACKSLASH				"\\"


DARROW          =>

%%
  // now adding rules(completely explained in README)

<INITIAL>{DOUBLE_DASH} {
	BEGIN(SINGLE_LINE_COMMENT);
}
<SINGLE_LINE_COMMENT>. {
}
<SINGLE_LINE_COMMENT>\n {
	curr_lineno++;
	BEGIN(INITIAL);
}
<SINGLE_LINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);
}


<INITIAL>{MUL_COMMENT_END} {
	// If you see “*)” outside a comment, report this error as ‘‘Unmatched *)’’
	yylval.error_msg = "Unmatched *)";
	return ERROR;
}

<INITIAL>{MUL_COMMENT_START} {
	BEGIN(MULTI_LINE_COMMENT);
}

<MULTI_LINE_COMMENT><<EOF>> {
	// If a comment remains open when EOF is encountered, report this error with the message ‘‘EOF in comment’’
	BEGIN(INITIAL);
	yylval.error_msg = "EOF in comment";
	return ERROR;
}
<MULTI_LINE_COMMENT>{MUL_COMMENT_END} {
	BEGIN(INITIAL);
}
<MULTI_LINE_COMMENT>(.|\n) {
	 if(yytext[0] == '\n')
	 	curr_lineno++;
}




<INITIAL>{DOUBLE_QUOTE} {
	BEGIN(STRINGG);	
}

<STRINGG><<EOF>> {
	//if an EOF is encountered before the close-quote, report this error as ‘‘EOF in string constant’’
	yylval.error_msg = "EOF in string constant";
	temp_str_buff.str(std::string());
	return ERROR;
}
<STRINGG>{BACKSLASH}(.|\n) { // exeptions are: \b \t \n \f
	// (.|\n) means every char
	switch(yytext[1])
	{
		case 'b':
			temp_str_buff << '\b';
			break;
		case 't':
			temp_str_buff << '\t';
			break;
		case 'n':
			temp_str_buff << '\n';
			break;
		case 'f':
			temp_str_buff << '\f';
			break;
		case '\n':
			temp_str_buff << '\n';
			curr_lineno++;
			break;
		default:
			temp_str_buff << yytext[1];
			break;
	}
}

<STRINGG>[^\"] { 
	// now whenever we read anything except for " :
	if (yytext[0] == '\n')
	{
		// If a string contains an unescaped newline, report that error as ‘‘Unterminated string constant’’
		BEGIN(INITIAL);
		yylval.error_msg = "Unterminated string constant";
		curr_lineno++;
		temp_str_buff.str(std::string());
		return ERROR;
	}
	if (yytext[0] == 0)
	{
		// If the string contains invalid characters report ‘‘String contains null character’’
		BEGIN(INITIAL);
		yylval.error_msg = "String contains null character";
		temp_str_buff.str(std::string());
		return ERROR;
	}
	temp_str_buff << yytext[0];
}

<STRINGG>{DOUBLE_QUOTE} {
	BEGIN(INITIAL);
	std::string str_const = temp_str_buff.str();
	temp_str_buff.str(std::string());
	if(str_const.size() > MAX_STR_CONST)
	{
		// When a string is too long, report the error as ‘‘String constant too long’’
		BEGIN(INITIAL);
		yylval.error_msg = "String constant too long";
		temp_str_buff.str(std::string());
		return ERROR;
	}
	yylval.symbol = stringtable.add_string((char*)str_const.c_str());
	return STR_CONST;
}




<INITIAL>{CONST_INT} {
	yylval.symbol = inttable.add_string(yytext);
	return INT_CONST;
}
<INITIAL>{FALSE} {
	yylval.boolean = false;
	return BOOL_CONST;
}
<INITIAL>{TRUE} {
	yylval.boolean = true;
	return BOOL_CONST;
}

<INITIAL>{CLASS}     { return CLASS; }
<INITIAL>{ELSE}      { return ELSE; }
<INITIAL>{FI}        { return FI; }
<INITIAL>{IF}        { return IF; }
<INITIAL>{IN}        { return IN; }
<INITIAL>{INHERITS}  { return INHERITS; }    
<INITIAL>{LET}       { return LET; } 
<INITIAL>{LOOP}      { return LOOP; }    
<INITIAL>{POOL}      { return POOL; }
<INITIAL>{THEN}      { return THEN; }
<INITIAL>{WHILE}     { return WHILE; }
<INITIAL>{CASE}      { return CASE; }
<INITIAL>{ESAC}	     { return ESAC; }
<INITIAL>{NEW}       { return NEW; }
<INITIAL>{OF}        { return OF; }
<INITIAL>{NOT}       { return NOT; }
<INITIAL>{ISVOID}    { return ISVOID; }

<INITIAL>{TYPEID} {
	yylval.symbol = idtable.add_string(yytext);
	return TYPEID;
}
 
<INITIAL>{OBJECTID} {
	yylval.symbol = idtable.add_string(yytext);
	return OBJECTID;
}

<INITIAL>{ASSIGN}	{ return ASSIGN; }

<INITIAL>"<="		{ return LE; }
<INITIAL>"<"            { return (int)'<'; }
<INITIAL>"="            { return (int)'='; }

<INITIAL>"{"		{ return (int)'{'; }
<INITIAL>"}"		{ return (int)'}'; }
<INITIAL>"("		{ return (int)'('; }
<INITIAL>")"		{ return (int)')'; }
<INITIAL>";"		{ return (int)';'; }
<INITIAL>","         	{ return (int)','; }

<INITIAL>"+"         { return (int)'+'; }
<INITIAL>"-"         { return (int)'-'; }
<INITIAL>"*"         { return (int)'*'; }
<INITIAL>"/"         { return (int)'/'; }

<INITIAL>"@"         { return (int)'@'; }
<INITIAL>"~"         { return (int)'~'; }
<INITIAL>":"         { return (int)':'; }
<INITIAL>"\."        { return (int)'.'; }


<INITIAL>{WHITE_SPACE} {
	if(yytext[0] == '\n' || yytext[0] == '\f')
		curr_lineno++;
}

<INITIAL>. {
	yylval.error_msg = yytext;
	return ERROR;	
}
{DARROW} { // I don't know what the hell is this  
return (DARROW); }

%%

