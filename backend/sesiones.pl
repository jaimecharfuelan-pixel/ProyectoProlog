%% sesiones.pl

:- dynamic(sesion_activa/2).
:- use_module(library(uuid)).

crear_sesion(Username, SessionId) :-
    uuid(UUID),
    atom_string(UUID, SessionId),
    assertz(sesion_activa(SessionId, Username)).

validar_sesion(SessionId, Username) :-
    nonvar(SessionId),
    SessionId \= '',
    sesion_activa(SessionId, Username).

cerrar_sesion(SessionId) :-
    retractall(sesion_activa(SessionId, _)).

cerrar_sesiones_usuario(Username) :-
    retractall(sesion_activa(_, Username)).

usuario_desde_sesion(SessionId, Username, ok) :-
    validar_sesion(SessionId, Username),
    !.
usuario_desde_sesion(_, _, error(sesion_invalida)).