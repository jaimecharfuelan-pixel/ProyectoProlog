%% recomandacion.pl - Motor de recomendación

:- use_module(library(lists)).

take(_, [], []) :- !.
take(0, _, []) :- !.
take(N, [H|T], [H|R]) :-
    N > 0,
    N1 is N - 1,
    take(N1, T, R).

pairs_values([], []).
pairs_values([_-V|T], [V|R]) :- pairs_values(T, R).

dedupe_preservar([], []).
dedupe_preservar([H|T], [H|R]) :-
    exclude(==(H), T, Rest),
    dedupe_preservar(Rest, R).

%% Recomendaciones personalizadas
recomendaciones_usuario(Username, IdsFinales) :-
    historial_usuario(Username, Inter),
    generos_ponderados(Inter, GenerosPond),
    findall(Score-Id, (
        pelicula(Id, _, _, _, _, _, _, _),
        \+ interaccion(Username, dislike, Id),
        score_recomendacion(Id, Inter, GenerosPond, Score),
        Score > 0
    ), Scored),
    (   Scored = []
    ->  populares_por_defecto(IdsFinales)
    ;   sort(1, @>=, Scored, Sorted),
        pairs_values(Sorted, Ids),
        take(12, Ids, IdsFinales)
    ).

%% Sin historial: populares
recomendaciones_sin_historial(Ids) :-
    populares_por_defecto(Ids).

populares_por_defecto(IdsFinales) :-
    findall(Pop-Id, pelicula(Id, _, _, _, Pop, _, _, _), Pares),
    sort(1, @>=, Pares, Sorted),
    pairs_values(Sorted, Ids),
    take(12, Ids, IdsFinales).   %% ← variable distinta, ya no falla

%% Populares globales (para sección)
peliculas_populares(IdsFinales) :-
    findall(Pop-Id, pelicula(Id, _, _, _, Pop, _, _, _), Pares),
    sort(1, @>=, Pares, Sorted),
    pairs_values(Sorted, Ids),
    take(10, Ids, IdsFinales).   %% ← variable distinta

%% Por género
peliculas_por_genero(Genero, Ids) :-
    findall(Pop-Id, pelicula(Id, _, Genero, _, Pop, _, _, _), Pares),
    sort(1, @>=, Pares, Sorted),
    pairs_values(Sorted, Ids).

%% Continuar viendo
continuar_viendo(Username, IdsFinales) :-
    findall(Id, interaccion(Username, visto, Id), Todas),
    reverse(Todas, Rev),
    dedupe_preservar(Rev, Unicas),
    take(8, Unicas, IdsFinales).