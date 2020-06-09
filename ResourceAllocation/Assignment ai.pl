 %------------------
processes([p1,p2,p3,p4]).
%-----------------------
resources([r1,r2]).

%:- dynamic allocated/2.
%:- dynamic requested/2.

allocated(p1, [r2]).
allocated(p2, [r1]). %commented
allocated(p3, [r1]).
allocated(p4, [r2]).
%p2,p4,p1,p3
%
:- dynamic available_resources/1.
available_resources([[r1, 0], [r2, 0]]).

requested(p1, [r1]).
requested(p3, [r2]).


safe_state(X):-
     processes(P),
     length(P, Len),
     safe_state(P,[],X,0,Len),!.
safe_state([], X, X, 0, _):- !.
safe_state([H|T], Xs, X, T, T):- !, false.
safe_state([H|T], Tx, X, Counter, Len):-
        Counter < Len,
        not(requested(H,_)),
        allocated(H,R),
	accept_P(H,R) ,
        append(Tx, [H], X2),
        Len2 is Len - 1,!,
        safe_state(T, X2, X,0,Len2);

        Counter < Len,
        requested(H,Rs), available(Rs), allocated(H,RE),
        accept_P(H,RE), append(Tx, [H], X2),
        Len2 is Len - 1,!,
        safe_state(T, X2, X,0, Len2);

        Counter < Len,
        append(T,[H],L3),
        Counter2 is Counter + 1,!,
        safe_state(L3, Tx, X, Counter2, Len);

	!, false.

accept_P(P, []):-!.
accept_P(P, [R|T]):-
     release_R(R),
     accept_P(P, T).

is_available([], _, _):- !.

is_available([H|T], [[R, Q]|Resources], L):-
	match(H, [[R, Q]|Resources], [], NewList),
	is_available(T, NewList, []).

match(R, [[R, Q]|Resources], L, NewL):-
	Q > 0,
	NewQ is Q - 1,
	append(L, [[R, NewQ]], L2),
	append(L2, Resources, NewL), !.

match(R, [[Res, Q]|Resources], L, NewL):-
	append(L, [[Res, Q]], L2),
	match(R, Resources, L2, NewL).

available(R):-
        available_resources(L),!,
	available(R,L).

available([],_):- !.
available([H|T],[[H1,T1]|T2]):-
        (H == H1) , (T1 > 0), T3 is T1-1, available(T,[[H1,T3]|T2]),!;
        (H == H1) , (T1 = 0), !, false;
         available([H|T],T2).


release_R(R1):-
	available_resources(R2),
	release_R(R1, R2, []).

release_R(R1,[],L2):- !.

release_R(R1,[[H,T1]|T2],L2):-
	(H = R1) -> T3 is T1 + 1,
        retractall(available_resources(_)),
        append([[R1,T3]], T2, L3),
        append(L3, L2, NewList),
        assert(available_resources(NewList)),!;
        append(L2,[[H,T1]], NList),
        release_R(R1, T2, NList).







