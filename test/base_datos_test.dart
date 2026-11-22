import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:gestor_tareas_local/models/tarea.dart';

void main() {
  group('Validacion del titulo', () {
    test('rechaza titulos vacios o solo con espacios', () {
      expect(Tarea.tituloValido(''), isFalse);
      expect(Tarea.tituloValido('    '), isFalse);
      expect(Tarea.tituloValido('Estudiar SQLite'), isTrue);
    });
  });

  group('Operaciones CRUD en SQLite', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('agregar y consultar tareas', () async {
      await db.agregarTarea('Tarea 1');
      await db.agregarTarea('  Tarea 2  ');

      final tareas = await db.obtenerTareas();
      expect(tareas.length, 2);
      expect(tareas[1].titulo, 'Tarea 2'); // se guardó sin espacios
      expect(tareas[0].completada, isFalse);
    });

    test('no permite guardar un titulo vacio', () async {
      expect(() => db.agregarTarea('   '), throwsArgumentError);
      expect(await db.obtenerTareas(), isEmpty);
    });

    test('editar titulo, cambiar estado y eliminar', () async {
      final id = await db.agregarTarea('Original');

      await db.actualizarTitulo(id, 'Nuevo titulo');
      await db.actualizarCompletada(id, true);
      var tareas = await db.obtenerTareas();
      expect(tareas.first.titulo, 'Nuevo titulo');
      expect(tareas.first.completada, isTrue);

      await db.eliminarTarea(id);
      tareas = await db.obtenerTareas();
      expect(tareas, isEmpty);
    });
  });

  test('los datos persisten al cerrar y volver a abrir la base',
      () async {
    
    final carpeta = await Directory.systemTemp.createTemp('tareas_test');
    final archivo = File('${carpeta.path}/prueba.sqlite');

    final db1 = AppDatabase(NativeDatabase(archivo));
    await db1.agregarTarea('Persistente');
    await db1.close();

    final db2 = AppDatabase(NativeDatabase(archivo));
    final tareas = await db2.obtenerTareas();
    expect(tareas.length, 1);
    expect(tareas.first.titulo, 'Persistente');
    await db2.close();

    await carpeta.delete(recursive: true);
  });
}