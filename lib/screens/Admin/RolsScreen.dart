import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RolesScreen extends StatefulWidget {
  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  List<Map<String, dynamic>> roles = [];
  final TextEditingController _descripcionController = TextEditingController();
  final String apiUrlRoles = 'https://symmetrical-funicular-mb61.onrender.com/rol';

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // Obtener roles desde la API
  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse(apiUrlRoles));
      if (response.statusCode == 200) {
        setState(() {
          roles = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener roles: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Agregar un rol
  Future<void> _addRol(Map<String, dynamic> nuevoRol) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlRoles),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevoRol),
      );
      if (response.statusCode == 200) {
        _showSuccess('Rol creado exitosamente.');
        _fetchRoles();
      } else {
        _showError('Error al agregar rol: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Editar un rol
  Future<void> _editRol(int id, Map<String, dynamic> updatedRol) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlRoles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedRol),
      );
      if (response.statusCode == 200) {
        _showSuccess('Rol editado exitosamente.');
        _fetchRoles();
      } else {
        _showError('Error al editar rol: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Eliminar un rol
  Future<void> _deleteRol(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrlRoles/$id'));
      if (response.statusCode == 200) {
        _showSuccess('Rol eliminado exitosamente.');
        _fetchRoles();
      } else {
        _showError('Error al eliminar rol: ${response.statusCode}');
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
          title: Text('Éxito'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar'),
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar'),
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
        title: Text('Gestión de Roles'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: roles.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final rol = roles[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text('${rol['descripcion']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditRolDialog(rol),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteRol(rol['id_rol']); // Asegúrate de que la clave sea la correcta
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _showAddRolDialog,
            child: Text('Agregar Rol'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para agregar rol
  void _showAddRolDialog() {
    _descripcionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Rol'),
          content: TextField(
            controller: _descripcionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final descripcion = _descripcionController.text.trim();
                if (descripcion.isNotEmpty) {
                  _addRol({'descripcion': descripcion});
                  Navigator.of(context).pop();
                } else {
                  _showError('Completa el campo de descripción.');
                }
              },
              child: Text('Guardar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar rol
  void _showEditRolDialog(Map<String, dynamic> rol) {
    _descripcionController.text = rol['descripcion'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Rol'),
          content: TextField(
            controller: _descripcionController,
            decoration: InputDecoration(labelText: 'Descripción'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final descripcion = _descripcionController.text.trim();
                if (descripcion.isNotEmpty) {
                  _editRol(rol['id_rol'], {'descripcion': descripcion});
                  Navigator.of(context).pop();
                } else {
                  _showError('Completa el campo de descripción.');
                }
              },
              child: Text('Guardar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        );
      },
    );
  }
}
