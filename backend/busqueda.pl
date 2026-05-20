%% busqueda.pl - Búsqueda con ranking

:- use_module(library(lists)).

pairs_keys([], []).
pairs_keys([K-_|T], [K|R]) :- pairs_keys(T, R).

normalizar(Texto, Norm) :-
    downcase_atom(Texto, Norm).

coincidencia_nombre(Id, Query, Score) :-
    pelicula(Id, Nombre, _, _, _, _, _, _),
    downcase_atom(Nombre, NombreLow),
    (   NombreLow = Query
    ->  Score = 100
    ;   sub_atom(NombreLow, _, _, _, Query)
    ->  Score = 80
    ;   Score = 0
    ).

coincidencia_keywords(Id, Query, Score) :-
    pelicula(Id, _, _, _, _, Keywords, _, _),
    keyword_score(Keywords, Query, Score).

keyword_score([], _, 0).
keyword_score([Kw|_], Query, 40) :-
    downcase_atom(Kw, KwLow),
    sub_atom(KwLow, _, _, _, Query),
    !.
keyword_score([_|Rest], Query, Score) :-
    keyword_score(Rest, Query, Score).

coincidencia_id(Id, Query, Score) :-
    atom_string(Id, IdStr),
    downcase_atom(IdStr, IdLow),
    (   sub_atom(IdLow, _, _, _, Query)
    ->  Score = 30
    ;   Score = 0
    ).

score_busqueda(Id, Query, ScoreTotal) :-
    coincidencia_nombre(Id, Query, SN),
    coincidencia_keywords(Id, Query, SK),
    coincidencia_id(Id, Query, SI),
    Total is SN + SK + SI,
    Total > 0,
    pelicula(Id, _, _, _, Pop, _, _, ScoreBase),
    PopFactor  is Pop * 0.3,
    BaseFactor is ScoreBase * 0.1,
    ScoreTotal is Total + PopFactor + BaseFactor.

%% Búsqueda vacía → todas por popularidad
buscar_peliculas('', Resultados) :-
    !,
    findall(Pop-Id, pelicula(Id, _, _, _, Pop, _, _, _), Pares),
    sort(1, @>=, Pares, Ordenados),
    pairs_keys(Ordenados, Resultados).

%% Búsqueda con texto
buscar_peliculas(Query, Resultados) :-
    normalizar(Query, Norm),
    Norm \= '',
    !,
    findall(Score-Id, (
        pelicula(Id, _, _, _, _, _, _, _),
        score_busqueda(Id, Norm, Score)
    ), Scored),
    (   Scored = []
    ->  Resultados = []
    ;   sort(1, @>=, Scored, Sorted),
        pairs_values(Sorted, Resultados)
    ).

buscar_peliculas(_, []).

pairs_values([], []).
pairs_values([_-V|T], [V|R]) :- pairs_values(T, R).