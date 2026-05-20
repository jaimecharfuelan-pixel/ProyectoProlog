# Guía de posters - CineGold

Coloca las imágenes en la carpeta:

`frontend/assets/posters/`

## Tamaño y formato recomendados

| Propiedad | Recomendación |
|-----------|----------------|
| Formato | JPG o PNG |
| Resolución | 500 x 750 px (proporción 2:3 póster) |
| Peso | Menos de 300 KB por imagen |
| Fondo | Preferible sin bordes blancos |

## Lista completa de archivos (25 películas)

| # | Película | Nombre EXACTO del archivo |
|---|----------|---------------------------|
| 1 | Interstellar | `interstellar.jpg` |
| 2 | Inception | `inception.jpg` |
| 3 | The Dark Knight | `dark_knight.jpg` |
| 4 | John Wick | `john_wick.jpg` |
| 5 | Mad Max: Fury Road | `mad_max.jpg` |
| 6 | Gladiator | `gladiator.jpg` |
| 7 | Alien | `alien.jpg` |
| 8 | El Conjuro | `conjuro.jpg` |
| 9 | It | `it.jpg` |
| 10 | Destino Final | `destino_final.jpg` |
| 11 | Destino a conocernos | `destino_conocernos.jpg` |
| 12 | The Matrix | `matrix.jpg` |
| 13 | Blade Runner 2049 | `blade_runner.jpg` |
| 14 | Gravity | `gravity.jpg` |
| 15 | The Martian | `martian.jpg` |
| 16 | Jurassic Park | `jurassic_park.jpg` |
| 17 | Toy Story | `toy_story.jpg` |
| 18 | Shrek | `shrek.jpg` |
| 19 | Superbad | `superbad.jpg` |
| 20 | The Godfather | `godfather.jpg` |
| 21 | Pulp Fiction | `pulp_fiction.jpg` |
| 22 | Forrest Gump | `forrest_gump.jpg` |
| 23 | Braveheart | `braveheart.jpg` |
| 24 | Titanic | `titanic.jpg` |
| 25 | Parasite | `parasite.jpg` |

## Ruta en el proyecto

Ejemplo correcto:

```
ProyectoProlog/
  frontend/
    assets/
      posters/
        interstellar.jpg   ← aquí
        john_wick.jpg
```

La app referencia rutas relativas desde `frontend/`:

`assets/posters/interstellar.jpg`

## Evitar errores de rutas

1. Usa **minúsculas** y **guiones bajos** como en la tabla.
2. No uses espacios ni tildes en el nombre del archivo.
3. No cambies la extensión en el código (`.jpg` en todos los casos).
4. Abre el frontend desde la carpeta `frontend` (Live Server o similar).
5. Si no hay imagen, se muestra la inicial del título como placeholder.

## Cómo buscar posters en Google

Ejemplos de búsqueda:

- `Interstellar movie poster official`
- `John Wick 2014 poster high resolution`
- `Destino Final 2000 poster`
- `The Matrix 1999 one sheet poster`

## Qué tipo de imágenes usar

- Pósters oficiales verticales (one sheet).
- Buena iluminación y texto legible.
- Evita miniaturas borrosas o capturas de pantalla de la película.

## Banner opcional (hero)

Opcional en `frontend/assets/banners/`:

- `hero.jpg` — 1920 x 400 px aprox., tema cine dorado/oscuro.

## Iconos opcionales

Carpeta `frontend/assets/icons/` para favicon o iconos UI si los añades después.
