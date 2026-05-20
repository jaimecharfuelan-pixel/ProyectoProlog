:- dynamic(sesion_activa/2).
:- use_module(library(uuid)).

ruta_sesiones('data/sesiones.dat').

guardar_sesiones :-
    ruta_sesiones(Ruta),
    file_directory_name(Ruta, Dir),
    (exists_directory(Dir) -> true ; make_directory(Dir)),
    setup_call_cleanup(
        open(Ruta, write, Stream, [encoding(utf8)]),
        forall(sesion_activa(S, U),
               format(Stream, '~q.~n', [sesion_activa(S, U)])),
        close(Stream)
    ).

cargar_sesiones :-
    ruta_sesiones(Ruta),
    (   exists_file(Ruta)
    ->  catch(
            setup_call_cleanup(
                open(Ruta, read, Stream, [encoding(utf8)]),
                leer_terminos(Stream),
                close(Stream)
            ), _, true)
    ;   true
    ).

leer_terminos(Stream) :-
    read_term(Stream, Term, []),
    (   Term == end_of_file
    ->  true
    ;   assertz(Term),
        leer_terminos(Stream)
    ).

crear_sesion(Username, SessionId) :-
    uuid(UUID),
    atom_string(UUID, SessionId),
    atom_string(UUID, SidAtom),
    assertz(sesion_activa(SidAtom, Username)),
    guardar_sesiones.

validar_sesion(SessionId, Username) :-
    nonvar(SessionId),
    SessionId \= '',
    (   sesion_activa(SessionId, Username)
    ->  true
    ;   atom_string(SidAtom, SessionId),
        sesion_activa(SidAtom, Username)
    ->  true
    ;   atom_string(SessionId, SidStr),
        sesion_activa(SidStr, Username)
    ).

cerrar_sesion(SessionId) :-
    retractall(sesion_activa(SessionId, _)),
    guardar_sesiones.

cerrar_sesiones_usuario(Username) :-
    retractall(sesion_activa(_, Username)),
    guardar_sesiones.

usuario_desde_sesion(SessionId, Username, ok) :-
    validar_sesion(SessionId, Username), !.
usuario_desde_sesion(_, _, error(sesion_invalida)).