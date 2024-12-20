import 'package:flutter/material.dart';
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http;

class ProyectosScreen extends StatefulWidget {
  @override
  _ProyectosScreenState createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreen> {
  List<Map<String, dynamic>> proyectos = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  bool _activo = true; // Estado inicial para el campo activo
  final String apiUrlProyectos = 'https://symmetrical-funicular-mb61.onrender.com/proyecto';

  @override
  void initState() {
    super.initState();
    _fetchProyectos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Obtener proyectos desde la API
  Future<void> _fetchProyectos() async {
    try {
      final response = await http.get(Uri.parse(apiUrlProyectos));
      if (response.statusCode == 200) {
        setState(() {
          proyectos = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener proyectos');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Agregar un proyecto
  Future<void> _addProyecto(Map<String, dynamic> nuevoProyecto) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlProyectos),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevoProyecto),
      );
      if (response.statusCode == 200) {
        _showSuccess('Proyecto creado exitosamente.');
        _fetchProyectos();
      } else {
        _showError('Error al agregar proyecto: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Editar un proyecto
  Future<void> _editProyecto(int id, Map<String, dynamic> updatedProyecto) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlProyectos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProyecto),
      );
      if (response.statusCode == 200) {
        _showSuccess('Proyecto editado exitosamente.');
        _fetchProyectos();
      } else {
        _showError('Error al editar proyecto: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Eliminar un proyecto
  Future<void> _deleteProyecto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrlProyectos/$id'));
      if (response.statusCode == 200) {
        _showSuccess('Proyecto eliminado exitosamente.');
        _fetchProyectos();
      } else {
        _showError('Error al eliminar proyecto: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Mostrar mensaje de éxito
  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Éxito', style: TextStyle(color: Colors.green)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Mostrar mensaje de error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proyectos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista de proyectos
            Expanded(
              child: ListView.builder(
                itemCount: proyectos.length,
                itemBuilder: (context, index) {
                  final proyecto = proyectos[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text('${proyecto['nombre']}', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dirección: ${proyecto['direccion']}'),
                          Text('Estado: ${proyecto['activo'] ? 'Activo' : 'Inactivo'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditProyectoDialog(proyecto);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteProyecto(proyecto['id_proyecto']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botón para agregar proyecto
            ElevatedButton(
              onPressed: _showAddProyectoDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Agregar Proyecto', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para agregar proyecto
  void _showAddProyectoDialog() {
    _nombreController.clear();
    _direccionController.clear();
    _activo = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Proyecto', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Activo'),
                    value: _activo,
                    onChanged: (bool value) {
                      setStateDialog(() {
                        _activo = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = _nombreController.text.trim();
                final direccion = _direccionController.text.trim();
                if (nombre.isNotEmpty && direccion.isNotEmpty) {
                  _addProyecto({
                    'nombre': nombre,
                    'direccion': direccion,
                    'activo': _activo,
                  });
                  Navigator.of(context).pop();
                } else {
                  _showError('Completa todos los campos.');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar proyecto
  void _showEditProyectoDialog(Map<String, dynamic> proyecto) {
    _nombreController.text = proyecto['nombre'];
    _direccionController.text = proyecto['direccion'];
    _activo = proyecto['activo'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Proyecto', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _direccionController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Activo:'),
                      Switch(
                        value: _activo,
                        onChanged: (value) {
                          setStateDialog(() {
                            _activo = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = _nombreController.text.trim();
                final direccion = _direccionController.text.trim();
                if (nombre.isNotEmpty && direccion.isNotEmpty) {
                  _editProyecto(proyecto['id_proyecto'], {
                    'nombre': nombre,
                    'direccion': direccion,
                    'activo': _activo,
                  });
                  Navigator.of(context).pop();
                } else {
                  _showError('Completa todos los campos.');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
