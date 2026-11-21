import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../models/tarea.dart';
part 'base_datos.g.dart';


@DataClassName('TareaDb')
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _abrirConexion());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return driftDatabase(
      name: 'gestor_tareas',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (resultado) {
          debugPrint('Drift web usa: ${resultado.chosenImplementation}');
          if (resultado.missingFeatures.isNotEmpty) {
            debugPrint('Funciones no disponibles: ${resultado.missingFeatures}');
          }
        },
      ),
    );
  }

  // SELECT * FROM tareas ORDER BY id
  Future<List<Tarea>> obtenerTareas() async {
    final consulta = select(tareas)..orderBy([(t) => OrderingTerm(expression: t.id)]);
    final filas = await consulta.get();

    return filas
      .map((fila) => Tarea(
            id: fila.id,
            titulo: fila.titulo,
            completada: fila.completada,
          )).toList();
  }

  // INSERT INTO tareas (titulo) VALUES (?)
  Future<int> agregarTarea(String titulo) {
    final tituloLimpio = titulo.trim();
    if (!Tarea.tituloValido(tituloLimpio)) {
      throw ArgumentError('El titulo no puede estar vacio');
    }
    return into(tareas).insert(TareasCompanion.insert(titulo: tituloLimpio));
  }

  // UPDATE tareas SET titulo = ? WHERE id = ?
  Future<int> actualizarTitulo(int id, String titulo) {
    final tituloLimpio = titulo.trim();
    if (!Tarea.tituloValido(tituloLimpio)) {
      throw ArgumentError('El titulo no puede estar vacio');
    }
    return (update(tareas)..where((t) => t.id.equals(id))).write(TareasCompanion(titulo: Value(tituloLimpio)));
  }

  // UPDATE tareas SET completada = ? WHERE id = ?
  Future<int> actualizarCompletada(int id, bool completada) {
    return (update(tareas)..where((t) => t.id.equals(id))).write(TareasCompanion(completada: Value(completada)));
  }

  // DELETE FROM tareas WHERE id = ?
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}