README file for Programming Assignment 2 (C++ edition)
=====================================================

	To compile your lextest program type:

	% make lexer

	Run your lexer by putting your test input in a file 'foo.cl' and
	run the lextest program:

	% ./lexer foo.cl

	To run your lexer on the file test.cl type:

	% make dotest

	If you think your lexical analyzer is correct and behaves like
	the one we wrote, you can actually try 'mycoolc' and see whether
	it runs and produces correct code for any examples.
	If your lexical analyzer behaves in an
	unexpected manner, you may get errors anywhere, i.e. during
	parsing, during semantic analysis, during code generation or
	only when you run the produced code on spim. So beware.

	If you change architectures you must issue

	% make clean

	when you switch from one type of machine to the other.
	If at some point you get weird errors from the linker,	
	you probably forgot this step.

========================================================================
========================================================================
First of all, to run this project it must be on the right path as some files are linked(such as includes)
note that the comments that start with -- are my comments and the comments that are like */...*/ are not written by me

TYPES:

Integers: 
non-empty strings of digits 0-9

Type identifiers: 
are strings that begin with a capital letter;

object identifiers: 
are strings begin with a lower case letter.

string: 
in double quotes. Within a string, a sequence ‘\c’ denotes the character ‘c’,
with the exception of the following:
\b
\t
\n
\f
A string may not contain EOF(end of file)

Comments:
single line comment:between two dashes “--”
multi line comment: (*...*)

keywords:
class, else, false, fi, if, in, inherits, isvoid, let, loop, pool, then, while,case, esac, new, of, not, true.
Except for the constants true and false, keywords are case insensitive. To conform to the rules for other objects, the first letter of true and false must be lowercase; the trailing letters may be upper or lower case.

White Space:
blank (ascii 32), \n (newline, ascii 10), \f (form feed, ascii 12), \r (carriage return, ascii 13), \t (tab, ascii 9), \v (vertical tab, ascii 11).


========================================================================
========================================================================
#define yylval cool_yylval :
yylval.error_msg: contains error msg

There are some files(classes) such as IdTable, IntTable, StringTable and we call add_string and add yytext to the table.

========================================================================
========================================================================

flex input:
%{
Declarations
%}
Definitions
%%
Rules
%%
User subroutines

What I did in Declarations part?
include <sstream>
std::stringstream temp_str_buff;
it will help to build the string constants. It's easier than C style (char*) string


What I did in Definitions part?
IN_STRING, MULTI_LINE_COMMENT, SINGLE_LINE_COMMENT are defined to make code clean.
Then I defined integer, alphabet and identifiers and some other important things such as "--" and "<-"

What I did in Rules part?
Here, I implemented the rules according to the cool rules.
rules for comments are explained in the first part of this file and explained in the cool.flex.

case {BACKSLASH}(.|\n):
if a BACKSLASH is not followed by b, t, n, f we should omit BACKSLASH.
I have added this case in line 86(maybe the line number change by accicent) of test.cl


what I did in  User subroutines part? 
nothing

