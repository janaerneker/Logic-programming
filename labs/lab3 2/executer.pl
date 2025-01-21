
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
	process(Sn1, Y, Sn).

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


