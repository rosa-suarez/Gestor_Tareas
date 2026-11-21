# Gestor de tareas con SQLite:

Aplicación Flutter que guarda tareas en una base de datos SQLite local (sin servidor, sin MySQL y sin internet). Permite agregar, listar, editar el título, marcar y eliminar tareas. Los datos se conservan al cerrar y volver a abrir la app.

## Tecnología de persistencia elegida

Se eligió **Drift** junto con **drift_flutter** para trabajar con SQLite desde Flutter.

- **drift:** Permite crear las tablas y realizar consultas a la base de datos (INSERT, SELECT, UPDATE y DELETE) utilizando Dart de forma asíncrona y con tipos de datos.
- **drift_flutter:** Facilita la conexión con la base de datos dependiendo de la plataforma. Permite utilizar SQLite en escritorio y móvil, y SQLite mediante WebAssembly en web, sin tener que cambiar el código.
- **drift_dev y build_runner:** Se utilizan durante el desarrollo para generar automáticamente el archivo `database.g.dart`, que contiene las clases necesarias para trabajar con las tablas.

Se eligió Drift porque permite utilizar la misma tecnología de persistencia en las diferentes plataformas. Se descartó `sqflite` porque tiene limitaciones para trabajar en web y escritorio, y `shared_preferences` porque está pensado para guardar preferencias y datos sencillos, no para manejar una base de datos.


## Diseño de la tabla

```sql
CREATE TABLE tareas (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo     TEXT    NOT NULL,
  completada INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0, 1))
);
```

- Cada registro se identifica con `id`, que SQLite asigna solo (autoincremento).
- SQLite no tiene tipo booleano, por eso `completada` se guarda como 0 o 1.