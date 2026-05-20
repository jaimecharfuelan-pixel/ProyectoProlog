%% usuarios.pl - Usuarios e interacciones (persistencia en archivo local)

:- dynamic(usuario/2).
:- dynamic(interaccion/3).

:- use_module(library(lists)).
:- use_module(library(filesex)).

ruta_datos('data/usuarios.dat').

%% Cargar datos al iniciar
cargar_usuarios :-
    ruta_datos(Ruta),
    (   exists_file(Ruta)
    ->  catch(load_datos(Ruta), E, (
            format(user_error, 'Error cargando usuarios: ~w~n', [E]),
            true
        ))
    ;   true
    ).

load_datos(Ruta) :-
    setup_call_cleanup(
        open(Ruta, read, Stream, [encoding(utf8)]),
        read_terms(Stream),
        close(Stream)
    ).

read_terms(Stream) :-
    read_term(Stream, Term, []),
    (   Term == end_of_file
    ->  true
    ;   assertz(Term),
        read_terms(Stream)
    ).

%% Guardar todos los hechos
guardar_usuarios :-
    ruta_datos(Ruta),
    file_directory_name(Ruta, Dir),
    (   exists_directory(Dir)
    ->  true
    ;   make_directory(Dir)
    ),
    setup_call_cleanup(
        open(Ruta, write, Stream, [encoding(utf8)]),
        (   forall(usuario(U, P), format(Stream, '~q.~n', [usuario(U, P)])),
            forall(interaccion(U, Tipo, Peli),
                   format(Stream, '~q.~n', [interaccion(U, Tipo, Peli)]))
        ),
        close(Stream)
    ).

%% Registro
registrar_usuario(Username, Password, ok) :-
    atom(Username),
    atom(Password),
    \+ usuario(Username, _),
    assertz(usuario(Username, Password)),
    guardar_usuarios.

registrar_usuario(Username, _, error(usuario_existe)) :-
    usuario(Username, _).

registrar_usuario(_, _, error(datos_invalidos)).

%% Login
validar_login(Username, Password, ok) :-
    usuario(Username, Password).

validar_login(Username, _, error(credenciales)) :-
    \+ usuario(Username, _).

validar_login(_, _, error(credenciales)).

%% Interacciones
registrar_interaccion(Username, _Tipo, PeliId, error(pelicula_invalida)) :-
    usuario(Username, _),
    \+ pelicula(PeliId, _, _, _, _, _, _, _).

registrar_interaccion(Username, _Tipo, _PeliId, error(usuario_invalido)) :-
    \+ usuario(Username, _).

registrar_interaccion(Username, Tipo, PeliId, ok) :-
    usuario(Username, _),
    pelicula(PeliId, _, _, _, _, _, _, _),
    member(Tipo, [visto, like, favorita, dislike]),
    (   interaccion(Username, Tipo, PeliId)
    ->  true
    ;   assertz(interaccion(Username, Tipo, PeliId))
    ),
    (   Tipo = favorita ->
        asegurar_interaccion(Username, like, PeliId),
        asegurar_interaccion(Username, visto, PeliId)
    ;   Tipo = like ->
        asegurar_interaccion(Username, visto, PeliId)
    ;   true
    ),
    guardar_usuarios.

asegurar_interaccion(U, T, P) :-
    (   interaccion(U, T, P)
    ->  true
    ;   assertz(interaccion(U, T, P))
    ).

%% Historial del usuario como lista inter/2
historial_usuario(Username, Interacciones) :-
    findall(inter(Peli, Tipo),
            interaccion(Username, Tipo, Peli),
            Interacciones).

usuario_vio(Username, PeliId) :-
    interaccion(Username, visto, PeliId).

usuario_like(Username, PeliId) :-
    interaccion(Username, like, PeliId).

usuario_favorita(Username, PeliId) :-
    interaccion(Username, favorita, PeliId).

usuario_dislike(Username, PeliId) :-
    interaccion(Username, dislike, PeliId).

estado_pelicula_usuario(Username, PeliId, Estado) :-
    findall(T, interaccion(Username, T, PeliId), Tipos),
    Estado = _{visto: member(visto, Tipos),
               like: member(like, Tipos),
               favorita: member(favorita, Tipos),
               dislike: member(dislike, Tipos)}.

%% Perfil con pesos por género
perfil_usuario(Username, Perfil) :-
    historial_usuario(Username, Inter),
    generos_ponderados(Inter, Generos),
    findall(_{genero:G, label:L, score:S}, (
        member(G-S, Generos),
        genero_label(G, L)
    ), GenerosJson),
    findall(P, usuario_vio(Username, P), Vistas),
    findall(P, usuario_like(Username, P), Likes),
    findall(P, usuario_favorita(Username, P), Favoritas),
    Perfil = _{
        usuario: Username,
        generos: GenerosJson,
        vistas: Vistas,
        likes: Likes,
        favoritas: Favoritas
    }.
