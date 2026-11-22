import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/main.dart';
import 'package:gestor_tareas_local/data/base_datos.dart';
import 'package:drift/native.dart'; 

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    final baseDatos = AppDatabase(NativeDatabase.memory()); //bse en memoria para pruebas

    await tester.pumpWidget(GestorTareasApp(baseDatos: baseDatos));
    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('No se agrega una tarea con titulo vacio', (tester) async {
    final baseDatos = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(GestorTareasApp(baseDatos: baseDatos));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '    ');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(find.text('Escribe un titulo para la tarea'), findsOneWidget);
    expect(find.byType(Card), findsNothing);
  });
}
