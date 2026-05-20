:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_files)).
:- use_module(library(thread)).

:- consult(peliculas).
:- consult(reglas).
:- consult(busqueda).
:- consult(usuarios).
:- consult(sesiones).
:- consult(recomandacion).

:- set_prolog_flag(encoding, utf8).

puerto(9000).

:- http_handler(root('.'),
    http_reply_from_files('../frontend', [index_files(['index.html'])]),
    [prefix]).

:- http_handler(root('api/'),            cors_preflight_handler, [prefix, method(options)]).
:- http_handler(root('api/register'),    api_register,    [method(post)]).
:- http_handler(root('api/login'),       api_login,       [method(post)]).
:- http_handler(root('api/logout'),      api_logout,      [method(post)]).
:- http_handler(root('api/interaccion'), api_interaccion, [method(post)]).
:- http_handler(root('api/peliculas'),       api_peliculas,       [method(get)]).
:- http_handler(root('api/buscar'),          api_buscar,          [method(get)]).
:- http_handler(root('api/recomendaciones'), api_recomendaciones, [method(get)]).
:- http_handler(root('api/seccion'),         api_seccion,         [method(get)]).
:- http_handler(root('api/perfil'),          api_perfil,          [method(get)]).
:- http_handler(root('api/health'),          api_health,          [method(get)]).
%% ============================================================
%% CORS preflight
%% ============================================================
cors_preflight_handler(_Request) :-
    format("Access-Control-Allow-Origin: *\r\n"),
    format("Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"),
    format("Access-Control-Allow-Headers: Content-Type, X-Session-Id\r\n"),
    format("Content-Length: 0\r\n"),
    format("~n").

%% ============================================================
%% Helpers
%% ============================================================
request_method(Request, Method) :-
    memberchk(method(Method), Request).

reply_json_cors(Dict) :-
    reply_json_cors(Dict, []).

reply_json_cors(Dict, Options) :-
    cors_enable,
    reply_json_dict(Dict, Options).

reply_method_not_allowed :-
    cors_enable,
    reply_json_dict(_{ok: false, error: 'Metodo no permitido'}, [status(405)]).

%% ============================================================
%% Arranque
%% ============================================================
start :-
    cargar_usuarios,
    puerto(P),
    http_server(http_dispatch, [port(P)]),
    format('~n========================================~n'),
    format('  CineGold - http://localhost:~w~n', [P]),
    format('  API:    http://localhost:~w/api/health~n', [P]),
    format('========================================~n'),
    server_loop.

server_loop :-
    format('~n[CineGold] Escribe "salir." para apagar.~n?- '),
    catch(read(Term), _, Term = error),
    (   Term == salir
    ->  format('Apagando...~n'), halt
    ;   server_loop
    ).

%% ============================================================
%% API endpoints
%% ============================================================
api_health(_Request) :-
    reply_json_cors(_{ok: true, servicio: 'CineGold Prolog API'}).

api_register(Request) :-
    (   request_method(Request, post)
    ->  http_read_json_dict(Request, Body),
        _{username: U, password: P} :< Body,
        atom_string(Ua, U),
        atom_string(Pa, P),
        registrar_usuario(Ua, Pa, Result),
        (   Result = ok
        ->  reply_json_cors(_{ok: true, mensaje: 'Usuario registrado'})
        ;   mensaje_error(Result, Msg),
            reply_json_cors(_{ok: false, error: Msg})
        )
    ;   reply_method_not_allowed
    ).

api_login(Request) :-
    (   request_method(Request, post)
    ->  http_read_json_dict(Request, Body),
        _{username: U, password: P} :< Body,
        atom_string(Ua, U),
        atom_string(Pa, P),
        (   validar_login(Ua, Pa, ok),
            crear_sesion(Ua, Sid)
        ->  reply_json_cors(_{ok: true, sessionId: Sid, username: U})
        ;   reply_json_cors(_{ok: false, error: 'Credenciales incorrectas'})
        )
    ;   reply_method_not_allowed
    ).

api_logout(Request) :-
    (   request_method(Request, post)
    ->  session_id(Request, Sid),
        cerrar_sesion(Sid),
        reply_json_cors(_{ok: true})
    ;   reply_method_not_allowed
    ).

api_peliculas(Request) :-
    session_user(Request, User),
    todas_peliculas(Ids),
    peliculas_a_json(Ids, User, Lista),
    reply_json_cors(_{ok: true, peliculas: Lista}).

api_buscar(Request) :-
    session_user(Request, User),
    http_parameters(Request, [q(Query, [default('')])]),
    buscar_peliculas(Query, Ids),
    peliculas_a_json(Ids, User, Lista),
    reply_json_cors(_{ok: true, query: Query, peliculas: Lista}).

api_recomendaciones(Request) :-
    session_user(Request, User),
    (   User == none
    ->  recomendaciones_sin_historial(Ids)
    ;   recomendaciones_usuario(User, Ids)
    ),
    peliculas_a_json(Ids, User, Lista),
    reply_json_cors(_{ok: true, peliculas: Lista}).

api_seccion(Request) :-
    session_user(Request, User),
    http_parameters(Request, [tipo(Tipo, [atom])]),
    ids_seccion(Tipo, User, Ids),
    peliculas_a_json(Ids, User, Lista),
    reply_json_cors(_{ok: true, tipo: Tipo, peliculas: Lista}).

ids_seccion(populares,       _,    Ids) :- peliculas_populares(Ids).
ids_seccion(recomendadas,    User, Ids) :-
    (User == none -> recomendaciones_sin_historial(Ids) ; recomendaciones_usuario(User, Ids)).
ids_seccion(continuar,       User, Ids) :-
    (User == none -> Ids = [] ; continuar_viendo(User, Ids)).
ids_seccion(accion,          _,    Ids) :- peliculas_por_genero(accion, Ids).
ids_seccion(terror,          _,    Ids) :- peliculas_por_genero(terror, Ids).
ids_seccion(ciencia_ficcion, _,    Ids) :- peliculas_por_genero(ciencia_ficcion, Ids).
ids_seccion(_,               _,    []).

api_interaccion(Request) :-
    (   request_method(Request, post)
    ->  session_id(Request, Sid),
        (   usuario_desde_sesion(Sid, User, ok)
        ->  http_read_json_dict(Request, Body),
            _{pelicula: P, tipo: T} :< Body,
            atom_string(Peli, P),
            atom_string(TipoAtom, T),
            (   registrar_interaccion(User, TipoAtom, Peli, ok)
            ->  perfil_usuario(User, Perfil),
                reply_json_cors(_{ok: true, perfil: Perfil})
            ;   reply_json_cors(_{ok: false, error: 'No se pudo registrar'})
            )
        ;   reply_json_cors(_{ok: false, error: 'Sesion invalida'}, [status(401)])
        )
    ;   reply_method_not_allowed
    ).

api_perfil(Request) :-
    session_id(Request, Sid),
    (   usuario_desde_sesion(Sid, User, ok)
    ->  perfil_usuario(User, Perfil),
        reply_json_cors(_{ok: true, perfil: Perfil})
    ;   reply_json_cors(_{ok: false, error: 'Sesion invalida'}, [status(401)])
    ).

%% ============================================================
%% Auxiliares sesion
%% ============================================================
session_id(Request, Sid) :-
    (   memberchk(x_session_id(Sid), Request)
    ->  true
    ;   Sid = ''
    ).

session_user(Request, User) :-
    session_id(Request, Sid),
    (   Sid \= '',
        usuario_desde_sesion(Sid, User, ok)
    ->  true
    ;   User = none
    ).

%% ============================================================
%% Mapeo JSON peliculas
%% ============================================================
peliculas_a_json([], _, []).
peliculas_a_json([Id|Rest], User, [J|Js]) :-
    pelicula_a_json(Id, User, J),
    peliculas_a_json(Rest, User, Js).

pelicula_a_json(Id, User, Dict) :-
    pelicula(Id, Nombre, Genero, Duracion, Pop, Keywords, Poster, ScoreBase),
    genero_label(Genero, GeneroLabel),
    duracion_label(Duracion, DurLabel),
    estado_usuario(User, Id, Visto, Like, Fav, Dis),
    Dict = _{
        id: Id, nombre: Nombre,
        genero: Genero, genero_label: GeneroLabel,
        duracion: Duracion, duracion_label: DurLabel,
        popularidad: Pop, keywords: Keywords,
        poster: Poster, score_base: ScoreBase,
        visto: Visto, like: Like, favorita: Fav, dislike: Dis
    }.

estado_usuario(none, _, false, false, false, false).
estado_usuario(User, Id, V, L, F, D) :-
    User \= none,
    (usuario_vio(User, Id)      -> V = true ; V = false),
    (usuario_like(User, Id)     -> L = true ; L = false),
    (usuario_favorita(User, Id) -> F = true ; F = false),
    (usuario_dislike(User, Id)  -> D = true ; D = false).

mensaje_error(error(usuario_existe),  'El usuario ya existe').
mensaje_error(error(datos_invalidos), 'Datos invalidos').
mensaje_error(error(credenciales),    'Credenciales incorrectas').
mensaje_error(E, E).

:- initialization(start, main).