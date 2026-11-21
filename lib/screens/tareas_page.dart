import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../data/base_datos.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key, this.baseDatos});

  final AppDatabase? baseDatos;

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  late final AppDatabase _db;
  List<Tarea> _tareas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _db = widget.baseDatos ?? AppDatabase();
    _cargarTareas();
  }

 Future<void> _cargarTareas() async {
  try {
    final tareas = await _db.obtenerTareas();
    if (!mounted) return;
    setState(() {
      _tareas = tareas;
      _cargando = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _cargando = false);
    _pendiente('No se pudieron cargar las tareas: $e');
  }
}

 Future<void> _agregarTarea() async {
  final titulo = _tituloController.text.trim();

  if (!Tarea.tituloValido(titulo)) {
    _pendiente('Escribe un título para la tarea');
    return;
  }

  try {
    await _db.agregarTarea(titulo);
    _tituloController.clear();
    await _cargarTareas();
  } catch (e) {
    _pendiente('No se pudo guardar la tarea: $e');
  }
}

  void _alternarCompletada(Tarea tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _pendiente('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _pendiente('Implementar eliminación de tarea');
  }


  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: _tareas.isEmpty
                  ? const Center(child: Text('Todavía no hay tareas guardadas'))
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: (valor) {
                                if (valor != null) {
                                  _alternarCompletada(tarea, valor);
                                }
                              },
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
