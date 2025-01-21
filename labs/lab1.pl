beautiful(ulrika).
beautiful(nisse).
beautiful(peter).

rich(nisse).
rich(bettan).

strong(bettan).
strong(peter).
strong(bosse).

kind(bosse).

man(peter).
man(nisse).
man(bosse).

woman(ulrika).
woman(bettan).

like(X, Y):- 
	man(X), 
	woman(Y), 
	beautiful(Y).
like(nisse, X):- 
	woman(X),
	like(X, nisse).
like(ulrika, Y):- 
	man(Y),
	rich(Y),
	kind(Y).
like(ulrika, Y):- 
        man(Y),
        beautiful(Y),
        strong(Y).

happy(X):- 
	rich(X).
happy(X):- 
	man(X),
	woman(Y), 
	like(X, Y), 
	like(Y, X).

happy(X):- 
        woman(X), 
	man(Y),
        like(X, Y), 
        like(Y, X).

% happy(X).
% like(X, Y).
% findall(X, like(X, ulrika), CountList), length(CountList, Size).

edge(a, b).
edge(a, c).
edge(b, c).
edge(c, d).
edge(d, h).
edge(d, f).
edge(f, g).
edge(c, e).
edge(e, g).
edge(e, f).


path(X, Y):-
	edge(X,Y).
path(X, Z):- 
	edge(X,Y),
	path(Y, Z).

path(X, Y, [[X, Y]]):- edge(X, Y).
path(X, Z, [[X, Y]| REL]):-
	edge(X, Y),
	path(Y, Z, REL).

npath(X, Y, Size):-
	path(X, Y, List),
	length(List, Size).
