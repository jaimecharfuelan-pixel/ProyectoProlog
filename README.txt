CineGold - Plataforma de recomendación de películas
==================================================

Stack: SWI-Prolog (backend) + HTML/CSS/JS (frontend)

EJECUTAR BACKEND
----------------
1. Instala SWI-Prolog: https://www.swi-prolog.org/download/stable
2. Abre terminal en la carpeta backend:
   cd backend
3. Inicia el servidor:
   swipl -s server.pl
4. Debe mostrar: API en http://localhost:9000

EJECUTAR FRONTEND (Live Server en VS Code)
------------------------------------------
1. Abre la carpeta frontend con Live Server (puerto 5501 u otro).
2. Entra en: http://127.0.0.1:5501/login.html
3. El JS llama a la API en http://localhost:9000 (CORS habilitado).
4. Regístrate, inicia sesión y usa la plataforma.

CONECTAR PROLOG CON EL NAVEGADOR
--------------------------------
- El JS hace fetch() a http://localhost:9000/api/...
- CORS está habilitado en server.pl
- La sesión se envía con header: X-Session-Id
- Los usuarios se guardan en: backend/data/usuarios.dat

POSTERS
-------
Ver README_POSTERS.md para nombres y rutas de imágenes.

ARCHIVOS BACKEND
----------------
server.pl, peliculas.pl, reglas.pl, busqueda.pl, recomandacion.pl, usuarios.pl, sesiones.pl

PESOS DE INTERACCIÓN
--------------------
Ver: +10 | Like: +20 | Favorita: +50 | Dislike: -30
