% EXERCISE 2.1
%INSERTION_SORT
insert(INT,[],[INT]).
insert(INT,[HEAD|TAIL],[INT,HEAD|TAIL]):- 
	INT < HEAD.
insert(INT,[HEAD|TAIL], [HEAD|R]):-
	>=(INT,HEAD),
	insert(INT,TAIL,R).


isort([X],[X]).
isort([HEAD|TAIL],L):-
	isort(TAIL,L1),
	insert(HEAD,L1,L).

%QUICK_SORT
qsort([],[]).
qsort([H|T],RESULT):-
	pivoting(H,T,SPIV,BEPIV),
	qsort(SPIV,SR),
	qsort(BEPIV,LR),
	append(SR,[H|LR], RESULT).

pivoting(_,[],[],[]).
pivoting(H,[X|T],[X|L],G):-
	X<H,
	pivoting(H,T,L,G).
pivoting(H,[X|T],L,[X|G]):-
	X>=H,
	pivoting(H,T,L,G).

%EXERCISE 2.2
%middle(X,Xs)
%X is the middle element in the list Xs
middle(X,[X]).
middle(X,[_First|Xs]):-
	append(Middle,[_Last],Xs),
	middle(X,Middle).

middle1(X,[_First|Xs]):-
        append(Middle,[_Last],Xs),
        middle1(X,Middle).
middle1(X,[X]).

middle2(X,[X]).
middle2(X,[_First|Xs]):-
        middle2(X,Middle),
		append(Middle,[_Last],Xs).

middle3(X,[_First|Xs]):-
        middle3(X,Middle),
		append(Middle,[_Last],Xs).
middle3(X,[X]).


%EXERCISE2.3

num(1).
num(X):- 
	num(Y),
	X is Y + 1.
	% succ(X, Y).

id(_).

expr(num(_)).
expr(id(_)).
expr(+(X, Y)):- expr(X), expr(Y).
expr(-(X, Y)):- expr(X), expr(Y).
expr(*(X, Y)):- expr(X), expr(Y).

bool(true).
bool(false).
bool(>(X, Y)):- expr(X), expr(Y).
bool(>=(X, Y)):- expr(X), expr(Y).
bool(<(X, Y)):- expr(X), expr(Y).
bool(<=(X, Y)):- expr(X), expr(Y).



command(skip).
command(set(X, Y)):- id(X), expr(Y).
command(if(X, Y, Z)):- bool(X), command(Y), command(Z).
command(while(X, Y)):- bool(X), command(Y).
command(seq(X, Y)):- command(X), command(Y).


find(X, [[X, V]|_], V).
find(X, [[Y, _]|T], V1):- find(X, T, V1).

expression_evaluator(_, num(X), X).
expression_evaluator(SO, id(X), Y):-
	find(X, SO, Y).
expression_evaluator(SO, +(X, Y), R):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	R is X1+Y1.
expression_evaluator(SO, -(X, Y), R):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	R is X1-Y1.
expression_evaluator(SO, *(X, Y), R):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	R is X1*Y1.


evaluate_trueness(_, true, true).
evaluate_trueness(_, false, false).

evaluate_trueness(SO, >(X, Y), Res):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	(X1 > Y1 -> Res = true ; Res = false).
evaluate_trueness(SO, >=(X, Y), Res):- 
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	(X1 >= Y1 -> Res = true ; Res = false).
evaluate_trueness(SO, <(X, Y), Res):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	(X1 < Y1 -> Res = true ; Res = false).
evaluate_trueness(SO, <=(X, Y), Res):-
	expression_evaluator(SO, X, X1),
	expression_evaluator(SO, Y, Y1),
	(X1 =< Y1 -> Res = true ; Res = false).


memunion([H|T],[],[H|T]).     
memunion([],[H|T],[H|T]).    
memunion([[X, _]|T], SET2, RESULT) :- member([X, _],SET2), union(T,SET2,RESULT).    
memunion([[X, V]|T], SET2, [[X, V]|RESULT]) :- not(member([X, _],SET2)), union(T,SET2,RESULT).

replace_or_append([], X, [X]).
replace_or_append([[ID, _]|T], [ID, V], [[ID, V]|T]).
replace_or_append([[ID, V1]|T], [DID, V], [[ID, V1]|W]):-
	replace_or_append(T, [DID, V], W).

process(SO, skip, SO).

process(SO, set(id(X), num(Y)), Sn):-
	replace_or_append(SO, [X, Y], Sn).
process(SO, set(id(X), id(Y)), Sn):-
	expression_evaluator(SO, id(Y), Z),
	replace_or_append(SO, [X, Z], Sn).	
process(SO, set(id(X), Z), Sn):-
	expression_evaluator(SO, Z, R),
	replace_or_append(SO, [X, R], Sn).

process(SO, if(X, Y, _), Sn):-
	evaluate_trueness(SO, X, true),
	process(SO, Y, Sn).
process(SO, if(X, _, Z), Sn):-
	evaluate_trueness(SO, X, false),
	process(SO, Z, Sn).

process(SO, while(X, _), SO):- 
	evaluate_trueness(SO, X, false).
process(SO, while(X, Y), SnF):-
	evaluate_trueness(SO, X, true),
	process(SO, Y, Sn),
	process(Sn, while(X, Y), SnF).

process(SO, seq(X, Y), Sn):-
	process(SO, X, Sn1),
	process(SO, Y, Sn2),
	memunion(Sn1, Sn2, Sn).

execute(SO, P, Sn):-
	command(P),
	process(SO, P, Sn).
	
% Test skip
% execute([[x, 3]], skip, Sn)
% Sn = [[x, 3]]

% Test set 
% execute([[x, 3]], set(id(x), num(4)), Sn).
% Sn = [[x, 4]]

% Test if 
% execute([], if(true, set(id(a), num(1)), set(id(b), num(1))), Sn).
% Sn = [[a, 1]]

% Test else
% execute([], if(false, set(id(a), num(1)), set(id(b), num(1))), Sn).
% Sn = [[b, 1]]

% Test while 
% execute([[x, 3]], while(<(id(x), num(4)), set(id(x), num(5))), Sn).
% Sn = [[x, 5]]

% Test while 
% execute([[x, 4]], while(<(id(x), num(4)), set(id(x), num(5))), Sn).
% Sn = [[x, 4]]

% Test seq
% execute([[x, 4]], seq(set(id(x), num(5)), set(id(x), num(6))), Sn).
% Sn = [[x, 6]].



% EXERCISE 2.4

union([H|T],[],[H|T]).     
union([],[H|T],[H|T]).    
union([H|T], SET2, RESULT) :- member(H,SET2), union(T,SET2,RESULT).    
union([H|T], SET2, [H|RESULT]) :- not(member(H,SET2)), union(T,SET2,RESULT).


intersection(_, [], []).     
intersection([], _, []).    
intersection([H|T], SET2, [H|RESULT]) :- member(H,SET2), intersection(T,SET2,RESULT).    
intersection([H|T], SET2, RESULT) :- not(member(H,SET2)), intersection(T,SET2,RESULT).

subset_aux([], _).
subset_aux([H|T], Set):- 
	select(H, Set, ResSet),
	subset_aux(T, ResSet).

subset(SortedSubSet, Set):- 
	subset_aux(SubSet, Set),
	sort(SubSet, SortedSubSet).

powerset(X, R):-
	setof(Y, subset(Y, X), R).

