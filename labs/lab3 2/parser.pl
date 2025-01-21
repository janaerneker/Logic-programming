pgm(ParseTree) --> cmd(ParseTree).
pgm(seq(InnerParseTree, OuterParseTree)) --> cmd(InnerParseTree), pgm(OuterParseTree).

% phrase(pgm(ParseTree), [skip, ;]).
cmd(skip) --> [skip], [;].
cmd(skip) --> [skip].

% phrase(pgm(ParseTree), [id(a), :=, num(3)]).
cmd(set(id(X), Y)) --> id(X), [:=], expr(Y), [;].
cmd(set(id(X), Y)) --> id(X), [:=], expr(Y).

% phrase(pgm(ParseTree), [if, id(a), <, num(1), then, id(a), :=, num(2), ;, else, id(a), :=, num(3), ;, fi, ;]).
cmd(if(B, X, Y)) --> [if], bool(B), [then], pgm(X), [else], pgm(Y), [fi], [;].

% phrase(pgm(ParseTree), [while, id(x), >, num(1), do, id(y), :=, id(y), *, id(x), ;, id(x), :=,id(x), -, num(1), od]).
cmd(while(B, X)) --> [while], bool(B), [do], pgm(X), [od], [;].
cmd(while(B, X)) --> [while], bool(B), [do], pgm(X), [od].

% phrase(pgm(ParseTree), [skip]).    

bool(X > Y) --> expr(X), [>], expr(Y).
bool(X >= Y) --> expr(X), [>=], expr(Y).
bool(X < Y) --> expr(X), [<], expr(Y).
bool(X =< Y) --> expr(X), [<=], expr(Y).
bool(X = Y) --> expr(X), [=], expr(Y).

expr(X) --> factor(X).
expr(X * Y) --> factor(X), [*], expr(Y).

factor((X + Y)) --> term(X), [+], factor(Y).
factor((X - Y)) --> term(X), [-], factor(Y).
factor(X) --> term(X).

term(id(X)) --> id(X).
term(num(N)) --> num(N).

id(X) --> [id(X)].
% Do this only if scanner doesnt guarantee that N is a number yet.
num(N) --> [num(N)], {number(N)}.

parse(Tokens, ParseTree):- phrase(pgm(ParseTree), Tokens).

run(In, String, Out):-
	scan(String, Tokens),
	parse(Tokens, Abs),
	execute(In, Abs, Out).


% execute([[x,3]], seq(set(id(y),num(1)),seq(set(id(z),num(0)),while(id(x)>id(z),seq(set(id(z),id(z)+num(1)),set(id(y),id(y)*id(z)))))), Out).
% run([[x,3]], "y:=1; z:=0; while x>z do z:=z+1; y:=y*z od", Res).
