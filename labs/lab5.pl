container(a, 2, 2).
container(b, 4, 1).
container(c, 2, 2).
container(d, 1, 1).

on(a, d).
on(b, c).
on(c, d).


containers_start(Containers, [S1, S2, S3, S4]):-
	Containers = [task(S1, 2, _, 2, a),
				  task(S2, 1, _, 4, b),
				  task(S3, 2, _, 2, c),
				  task(S4, 1, _, 1, d)].

sum_workers([], 0).
sum_workers([task(_, _, _, W, _) | CTail], R):-
	sum_workers(CTail, N),
	R is N+W.

sum_durations([], 0).
sum_durations([task(_, D, _, _, _) | CTail], R):-
	sum_durations(CTail, N),
	R is N+D.

restrain_total_duration([], _).
restrain_total_duration([task(ST, D, _, _, _) | CTail], TD):-
	TD #>= ST + D,
	restrain_total_duration(CTail, TD).

respect_stack_order(_, []).
respect_stack_order(Containers, [on(N1, N2) | OTail]):-
	find_task(Containers, N1, task(ST1, D1, _, _, N1)),
	find_task(Containers, N2, task(ST2, _, _, _, N2)),
	ST2 #>= ST1+D1,
	respect_stack_order(Containers, OTail).


find_task([task(S1, D1, _, _, N1) | _], N1, task(S1, D1, _, _, N1)).
find_task([task(_, _, _, _, _N1) | CTail], N, X):-
	find_task(CTail, N, X).


work(Vars):-
	containers_start(Containers, Vars),
	% Get domain for each duration.
	% Calculate worst case scenario by summing all durations
	sum_durations(Containers, D),
	Vars ins 0..D,

	% Get domain for number of workers 
	sum_workers(Containers, W),
	MaxWorkers in 0..W,

	% Restrain TD
	TD in 0..D,
	restrain_total_duration(Containers, TD),

	% Restrain MaxWorkers
	restrain_max_workers()

	% Get max_duration
	Cost #= TD,
	respect_stack_order(Containers, [on(a, d), on(b, c), on(c, d)]),
   	cumulative(Containers, [limit(10)]), 
   	% Only works on swi-prolog
   	labeling([min(TD)], [TD| Vars]).
   	



