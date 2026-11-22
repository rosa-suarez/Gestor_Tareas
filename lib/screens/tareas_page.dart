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
  final TextEditingController _edicionController = TextEditingController();

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
      _pendiente('Escribe un titulo para la tarea');
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

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await _db.actualizarCompletada(tarea.id, completada);
      await _cargarTareas();
    } catch (e) {
      _pendiente('No se pudo actualizar la tarea: $e');
    }
  }

  Future<void> _editarTarea(Tarea tarea) async {

    _edicionController.text = tarea.titulo;

    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: _edicionController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Titulo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _edicionController.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nuevoTitulo == null) return;

    final titulo = nuevoTitulo.trim();
    if (!Tarea.tituloValido(titulo)) {
      _pendiente('El titulo no puede quedar vacio');
      return;
    }

    if (titulo == tarea.titulo) return;

    try {
      await _db.actualizarTitulo(tarea.id, titulo);
      await _cargarTareas();
    } catch (e) {
      _pendiente('No se pudo editar la tarea: $e');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await _db.eliminarTarea(tarea.id);
      await _cargarTareas();
      _pendiente('Tarea eliminada');
    } catch (e) {
      _pendiente('No se pudo eliminar la tarea: $e');
    }
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _edicionController.dispose();
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
              child: _cargando
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
                            title: Text(
                              tarea.titulo,
                              style: TextStyle(
                                decoration: tarea.completada
                                  ? TextDecoration.lineThrough
                                  : null,
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${tarea.id} · '
                              '${tarea.completada ? 'Completada' : 'Pendiente'}',
                            ),
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
