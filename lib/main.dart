import 'package:flutter/material.dart';
import 'screens/tareas_page.dart';
import 'data/base_datos.dart';

void main() {
  runApp(const GestorTareasApp()); 
}

class GestorTareasApp extends StatelessWidget {
  const GestorTareasApp({super.key, this.baseDatos});
  final AppDatabase? baseDatos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(baseDatos: baseDatos),
    );
  }
}
