%% reglas.pl - Pesos de interacción y puntuación

:- use_module(library(lists)).

peso_interaccion(visto,    10).
peso_interaccion(like,     20).
peso_interaccion(favorita, 50).
peso_interaccion(dislike, -30).

genero_pelicula(Id, Genero) :-
    pelicula(Id, _, Genero, _, _, _, _, _).

suma_pesos_genero(_, [], 0).
suma_pesos_genero(Genero, [inter(Id, Tipo)|Rest], Total) :-
    genero_pelicula(Id, Genero),
    !,
    peso_interaccion(Tipo, P),
    suma_pesos_genero(Genero, Rest, Sub),
    Total is P + Sub.
suma_pesos_genero(Genero, [_|Rest], Total) :-
    suma_pesos_genero(Genero, Rest, Total).

puntuacion_genero(Interacciones, Genero, Score) :-
    suma_pesos_genero(Genero, Interacciones, Score).

%% findall en vez de setof — nunca falla aunque no haya géneros
generos_ponderados(Interacciones, Pares) :-
    findall(G, genero_en_catalogo(G), TodosG),
    sort(TodosG, Generos),
    maplist_score(Interacciones, Generos, Todos),
    include(positive_score, Todos, Positivos),
    (   Positivos = []
    ->  Pares = []
    ;   sort(2, @>=, Positivos, Pares)
    ).

genero_en_catalogo(G) :-
    pelicula(_, _, G, _, _, _, _, _).

maplist_score(_, [], []).
maplist_score(Inter, [G|Gs], [G-Score|Rest]) :-
    puntuacion_genero(Inter, G, Score),
    maplist_score(Inter, Gs, Rest).

positive_score(_-S) :- S > 0.

score_recomendacion(Id, Interacciones, GenerosPonderados, ScoreFinal) :-
    pelicula(Id, _, Genero, _, Pop, _, _, ScoreBase),
    peso_genero(GenerosPonderados, Genero, PesoGen),
    PopNorm   is Pop / 10,
    BaseNorm  is ScoreBase / 10,
    penalizacion_usuario(Id, Interacciones, Pen),
    ScoreFinal is PesoGen + PopNorm + BaseNorm + Pen.

peso_genero(Pares, Genero, Peso) :-
    (   member(Genero-Val, Pares)
    ->  Peso = Val
    ;   Peso = 0
    ).

penalizacion_usuario(Id, Interacciones, Pen) :-
    findall(P, (
        member(inter(Id, Tipo), Interacciones),
        peso_interaccion(Tipo, P)
    ), Pesos),
    (   Pesos = []
    ->  Pen = 0
    ;   sum_list(Pesos, Pen)
    ).

factor_popularidad(Id, Factor) :-
    pelicula(Id, _, _, _, Pop, _, _, _),
    Factor is Pop / 100.0.