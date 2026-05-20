%% peliculas.pl - Catálogo de películas (hechos base)
%% pelicula(Id, Nombre, Genero, Duracion, Popularidad, Keywords, Poster, ScoreBase)

pelicula(interstellar, 'Interstellar', ciencia_ficcion, larga, 97,
       ['espacio','nasa','universo','tiempo','astronauta'],
       'assets/posters/interstellar.jpg', 95).

pelicula(inception, 'Inception', ciencia_ficcion, larga, 94,
       ['suenos','mente','arquitecto','leonardo'],
       'assets/posters/inception.jpg', 92).

pelicula(dark_knight, 'The Dark Knight', accion, larga, 98,
       ['batman','joker','gotham','superheroe'],
       'assets/posters/dark_knight.jpg', 96).

pelicula(john_wick, 'John Wick', accion, media, 91,
       ['asesino','venganza','perro','keanu'],
       'assets/posters/john_wick.jpg', 88).

pelicula(mad_max, 'Mad Max: Fury Road', accion, media, 90,
       ['postapocaliptico','desierto','coche','furiosa'],
       'assets/posters/mad_max.jpg', 87).

pelicula(gladiator, 'Gladiator', accion, larga, 89,
       ['roma','coliseo','maximo','epico'],
       'assets/posters/gladiator.jpg', 86).

pelicula(alien, 'Alien', terror, media, 88,
       ['espacio','xenomorph','nostromo','horror'],
       'assets/posters/alien.jpg', 85).

pelicula(conjuro, 'El Conjuro', terror, media, 87,
       ['fantasma','casa','exorcismo','warren'],
       'assets/posters/conjuro.jpg', 84).

pelicula(it, 'It', terror, larga, 86,
       ['payaso','pennywise','derry','miedo'],
       'assets/posters/it.jpg', 83).

pelicula(destino_final, 'Destino Final', terror, media, 82,
       ['muerte','accidente','destino','thriller'],
       'assets/posters/destino_final.jpg', 80).

pelicula(destino_conocernos, 'Destino a conocernos', romance, media, 45,
       ['amor','viaje','pareja','dramaromantico'],
       'assets/posters/destino_conocernos.jpg', 42).

pelicula(matrix, 'The Matrix', ciencia_ficcion, media, 96,
       ['realidad','neo','simulacion','bullet'],
       'assets/posters/matrix.jpg', 94).

pelicula(blade_runner, 'Blade Runner 2049', ciencia_ficcion, larga, 85,
       ['replicante','futuro','lluvia','detective'],
       'assets/posters/blade_runner.jpg', 84).

pelicula(gravity, 'Gravity', ciencia_ficcion, media, 84,
       ['espacio','orbita','supervivencia','sandra'],
       'assets/posters/gravity.jpg', 82).

pelicula(martian, 'The Martian', ciencia_ficcion, larga, 88,
       ['marte','nasa','botanico','supervivencia'],
       'assets/posters/martian.jpg', 86).

pelicula(jurassic_park, 'Jurassic Park', aventura, media, 93,
       ['dinosaurio','isla','trex','parque'],
       'assets/posters/jurassic_park.jpg', 90).

pelicula(toy_story, 'Toy Story', animacion, media, 92,
       ['juguetes','woody','buzz','pixar'],
       'assets/posters/toy_story.jpg', 89).

pelicula(shrek, 'Shrek', animacion, media, 90,
       ['ogro','hada','comedia','dreamworks'],
       'assets/posters/shrek.jpg', 87).

pelicula(superbad, 'Superbad', comedia, media, 81,
       ['adolescente','fiesta','amigos','humor'],
       'assets/posters/superbad.jpg', 78).

pelicula(godfather, 'The Godfather', drama, larga, 99,
       ['mafia','corleone','familia','clasico'],
       'assets/posters/godfather.jpg', 97).

pelicula(pulp_fiction, 'Pulp Fiction', drama, larga, 95,
       ['tarantino','vincent','mia','noir'],
       'assets/posters/pulp_fiction.jpg', 93).

pelicula(forrest_gump, 'Forrest Gump', drama, larga, 92,
       ['vida','historia','correr','tomhanks'],
       'assets/posters/forrest_gump.jpg', 90).

pelicula(braveheart, 'Braveheart', drama, larga, 87,
       ['escocia','libertad','william','guerra'],
       'assets/posters/braveheart.jpg', 85).

pelicula(titanic, 'Titanic', romance, larga, 96,
       ['barco','amor','iceberg','leonardo'],
       'assets/posters/titanic.jpg', 94).

pelicula(parasite, 'Parasite', drama, media, 93,
       ['corea','clase','suspenso','oscar'],
       'assets/posters/parasite.jpg', 91).

%% Etiquetas legibles de género
genero_label(accion, 'Acción').
genero_label(terror, 'Terror').
genero_label(ciencia_ficcion, 'Ciencia ficción').
genero_label(comedia, 'Comedia').
genero_label(drama, 'Drama').
genero_label(romance, 'Romance').
genero_label(animacion, 'Animación').
genero_label(aventura, 'Aventura').

%% Duración legible
duracion_label(larga, 'Larga (~2h+)').
duracion_label(media, 'Media (~1h30-2h)').

%% Todas las películas
todas_peliculas(Ids) :-
    findall(Id, pelicula(Id, _, _, _, _, _, _, _), Ids).
