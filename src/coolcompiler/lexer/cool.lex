/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
    return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
    filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
    return filename;
    }
    int commentDepth = 0;
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
            case YYINITIAL:
            /* nothing special to do in the initial state */
break;
        /* If necessary, add code for other states here, e.g: */
        case YYCOMMENT:
            yybegin( YYEOF_ERROR );
            return new Symbol( TokenConstants.ERROR , “Can’t have an EOF inside of a comment” );
        case YYSTRING:
            yybegin( YYEOF_ERROR );
            return new Symbol( TokenConstants.ERROR , “Can’t have an EOF inside of a string” );
        case YYEOF_ERROR:
            break;
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%class CoolLexer
%cup
%state YYCOMMENT,YYSTRING,YYSTRING_NEWLINE_ERR,YYSTRING_NULL_ERR,YYEOF_ERROR

    DIGIT     =    [0-9]

    IF        =    [i][f]
    FI        =    [f][i]
    THEN        =    [t][h][e][n]
    ELSE        =    [e][l][s][e]
    TRUE        =    [t][r][u][e]
    FALSE    =    [f][a][l][s][e]
    NOT        =     [n][o][t]


IN        =    [i][n]
    LET         =     [l][e][t]

    WHILE    =    [w][h][i][l][e]
    LOOP        =    [l][o][o][p]
    POOL        =    [p][o][o][l]
    CASE        =    [c][a][s][e]

    NEW         =     [n][e][w]
    CLASS    =    [c][l][a][s][s]
    INHERITS    =    [i][n][h][e][r][i][t][s]
    ISVOID     =    [i][s][v][o][i][d]

    LINECOMMENT =    --[^\n]*
    COMMENTBEGIN=    \(\*
    COMMENTEND=    \*\)

    STRINGBEGIN=    \"
    STRINGEND    =    \"
    STRINGCHARS=    [^\”\0\n\\]+

    TYPEID    =    [A-Z][A-Z0-9]*
    OBJECTID    =    [A-Z][A-Z0-9]*

    ESAC        =    [e][s][a][c]
    AT        =    @

    ANYCHAR    =    .|\r
    WHITESPACE=    [\t\r\f\ ]
    NEWLINE    =    \n
%%

<YYINITIAL>{IF}                    { return new Symbol(TokenConstants.IF ); }
<YYINITIAL>{FI}                    { return new Symbol(TokenConstants.FI ); }
<YYINITIAL>{THEN}                    { return new Symbol(TokenConstants.THEN ); }
<YYINITIAL>{TRUE}                    { return new Symbol(TokenConstants.BOOL_CONST, “true” ); }
<YYINITIAL>{FALSE}                    { return new Symbol(TokenConstants.BOOL_CONST, “false” ); }
<YYINITIAL>{NOT}                    { return new Symbol(TokenConstants.NOT ); }
<YYINITIAL>{ELSE}                    { return new Symbol(TokenConstants.ELSE ); }

<YYINITIAL>{LET}                    { return new Symbol(TokenConstants.LET ); }
<YYINITIAL>{IN}                        { return new Symbol(TokenConstants.IN ); }

<YYINITIAL>{WHILE}                    { return new Symbol(TokenConstants.WHILE ); }
<YYINITIAL>{LOOP}                    { return new Symbol(TokenConstants.LOOP ); }
<YYINITIAL>{POOL}                    { return new Symbol(TokenConstants.POOL ); }
<YYINITIAL>{CASE}                    { return new Symbol(TokenConstants.CASE ); }
<YYINITIAL>{ESAC}                    { return new Symbol(TokenConstants.ESAC ); }

<YYINITIAL>{NEW}                    { return new Symbol(TokenConstants.NEW ); }
<YYINITIAL>{CLASS}                    { return new Symbol(TokenConstants.CLASS ); }
<YYINITIAL>{INHERITS}                { return new Symbol(TokenConstants.INHERITS ); }
<YYINITIAL>{ISVOID}                    { return new Symbol(TokenConstants.ISVOID ); }

<YYINITIAL>{LINECOMMENT}                { ; }
<YYINITIAL>{WHITESPACE}                { ; }
<YYCOMMENT>{ANYCHAR}                { ; }
<YYCOMMENT,YYINITIAL>{COMMENTBEGIN}    { yybegin(YYCOMMENT); commentDepth++; }
<YYCOMMENT>{COMMENTEND}                { commentDepth--; if(commentDepth == 0) { yybegin(YYINITIAL); } }
<YYINITIAL>{COMMENTEND}                { return new Symbol(TokenConstants.ERROR, “Unmatched Comment”); }

<YYINITIAL>{STRINGBEGIN}                { yybegin(YYSTRING); string_buf.setLength(0); }
<YYINITIAL>{STRINGCHARS}                { string_buf.append(yytext()); }
<YYSTRING>\x00                        { yybegin(YYSTRING_NULL_ERR); return new Symbol(TokenConstants.ERROR, “Null character encountered”); }
<YYSTRING>\\b                        { string_buf.append(“\b”); }
<YYSTRING>\\f                        { string_buf.append(“\f”); }
<YYSTRING>\\t                        { string_buf.append(“\t”); }
<YYSTRING>\\\”                        { string_buf.append(“\””); }
<YYSTRING>\\                        { string_buf.append(“”); }
<YYSTRING>\\\\                        { string_buf.append(“\\”); }
<YYSTRING>\n                        { yybegin(YYINITIAL); string_buf.setLength(0);
return new Symbol(TokenConstants.ERROR,”Unended string”); }
<YYSTRING>\\n                        { string_buf.append(“\n”); }
<YYSTRING>\\\n                        { string_buf.append(“\n”); }
<YYSTRING>\\\\n                        { string_buf.append(“\\n”); }
<YYSTRING>{STRINGEND}                { yybegin(YYINITIAL); String str = string_buf.toString();
  if(str.length() >= MAX_STR_CONST) {
return new Symbol(TokenConstants.ERROR, “String too long”);
  } else {
return new Symbol(TokenConstants.STR_CONST, new StringSymbol(str, str.length(), str.hashcode()));
}
 }

<YYINITIAL>\*                        { return new Symbol(TokenConstants.MULT); }
<YYINITIAL>\/                        { return new Symbol(TokenConstants.DIV); }
<YYINITIAL>\+                        { return new Symbol(TokenConstants.PLUS); }
<YYINITIAL>-                        { return new Symbol(TokenConstants.MINUS); }
<YYINITIAL>=                        { return new Symbol(TokenConstants.EQ); }
<YYINITIAL>\<                        { return new Symbol(TokenConstants.LT); }
<YYINITIAL><=                        { return new Symbol(TokenConstants.LE); }
<YYINITIAL>\.                        { return new Symbol(TokenConstants.DOT); }
<YYINITIAL>\(                        { return new Symbol(TokenConstants.LPAREN); }
<YYINITIAL>\)                        { return new Symbol(TokenConstants.RPAREN); }
<YYINITIAL>\:                        { return new Symbol(TokenConstants.COLON); }
<YYINITIAL>~                        { return new Symbol(TokenConstants.NEG); }
<YYINITIAL><-                        { return new Symbol(TokenConstants.ASSIGN); }
<YYINITIAL>@                        { return new Symbol(TokenConstants.AT); }
<YYINITIAL>\{                        { return new Symbol(TokenConstants.LBRACE); }
<YYINITIAL>\}                        { return new Symbol(TokenConstants.RBRACE); }
<YYINITIAL>,                        { return new Symbol(TokenConstants.COMMA); }
<YYINITIAL>;                        { return new Symbol(TokenConstants.SEMI); }

<YYINITIAL>{TYPEID}                    { return new Symbol(TokenConstants.TYPEID, new IdSymbol(yytext(), yytext().length(), yytext().hashCode())); }

<YYINITIAL>{OBJECTID}                { return new Symbol(TokenConstants.OBJECTID, new IdSymbol(yytext(), yytext().length(), yytext().hashCode())); }


<YYSTRING_NULL_ERR>\n                { yybegin( YYINITIAL ); }
<YYSTRING_NULL_ERR>\”                { yybegin( YYINITIAL ); }
<YYSTRING_NULL_ERR>.                { ; }
\n                                { curr_lineno++; }
<YYINITIAL>{DIGIT}+                    { return new Symbol( TokenConstants.INT_CONST ,
                                        new IntSymbol( yytext() ,
yytext().length() , yytext().hashCode() ) );}

<YYINITIAL>error                     {return new Symbol(TokenConstants.error);}

.n|\n                            {return new Symbol(TokenConstants.ERROR, yytext());}


<YYINITIAL>”=>”            { /* Sample lexical rule for "=>" arrow.
                                     Further lexical rules should be defined
                                     here, after the last %% separator */
                                  return new Symbol(TokenConstants.DARROW); }

.                               { /* This rule should be the very last
                                     in your lexical specification and
                                     will match match everything not
                                     matched by other lexical rules. */
                                  System.err.println("LEXER BUG - UNMATCHED: " + yytext()); }
