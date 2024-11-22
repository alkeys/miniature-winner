import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GasolinerasScreen extends StatefulWidget {
  @override
  _GasolinerasScreenState createState() => _GasolinerasScreenState();
}

class _GasolinerasScreenState extends State<GasolinerasScreen> {
  List<Map<String, dynamic>> gasolineras = [];
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final String apiUrlGasolineras = 'https://symmetrical-funicular-mb61.onrender.com/gasolineras';

  @override
  void initState() {
    super.initState();
    _fetchGasolineras();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Obtener gasolineras desde la API
  Future<void> _fetchGasolineras() async {
    try {
      final response = await http.get(Uri.parse(apiUrlGasolineras));
      if (response.statusCode == 200) {
        setState(() {
          gasolineras = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener gasolineras');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Agregar una gasolinera
  Future<void> _addGasolinera(Map<String, dynamic> nuevaGasolinera) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlGasolineras),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevaGasolinera),
      );
      if (response.statusCode == 200) {
        _showSuccess('Gasolinera creada exitosamente.');
        _fetchGasolineras();
      } else {
        _showError('Error al agregar gasolinera: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Editar una gasolinera
  Future<void> _editGasolinera(int id, Map<String, dynamic> updatedGasolinera) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlGasolineras/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedGasolinera),
      );
      if (response.statusCode == 200) {
        _showSuccess('Gasolinera editada exitosamente.');
        _fetchGasolineras();
      } else {
        _showError('Error al editar gasolinera: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Eliminar una gasolinera
  Future<void> _deleteGasolinera(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrlGasolineras/$id'));
      if (response.statusCode == 200) {
        _showSuccess('Gasolinera eliminada exitosamente.');
        _fetchGasolineras();
      } else {
        _showError('Error al eliminar gasolinera: ${response.statusCode}');
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
        title: Text('Gestión de Gasolineras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gasolineras.length,
              itemBuilder: (context, index) {
                final gasolinera = gasolineras[index];
                return ListTile(
                  title: Text('${gasolinera['nombre']}'),
                  subtitle: Text('Dirección: ${gasolinera['direccion']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditGasolineraDialog(gasolinera);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteGasolinera(gasolinera['id_gasolinera']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _showAddGasolineraDialog,
            child: Text('Agregar Gasolinera'),
          ),
        ],
      ),
    );
  }

  // Diálogo para agregar gasolinera
  void _showAddGasolineraDialog() {
    _nombreController.clear();
    _direccionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return _buildGasolineraDialog(
          title: 'Agregar Gasolinera',
          onSave: () {
            final nombre = _nombreController.text.trim();
            final direccion = _direccionController.text.trim();

            if (nombre.isNotEmpty && direccion.isNotEmpty) {
              _addGasolinera({
                'nombre': nombre,
                'direccion': direccion,
              });
              Navigator.of(context).pop();
            } else {
              _showError('Por favor, completa todos los campos.');
            }
          },
        );
      },
    );
  }

  // Diálogo para editar gasolinera
  void _showEditGasolineraDialog(Map<String, dynamic> gasolinera) {
    _nombreController.text = gasolinera['nombre'];
    _direccionController.text = gasolinera['direccion'];

    showDialog(
      context: context,
      builder: (context) {
        return _buildGasolineraDialog(
          title: 'Editar Gasolinera',
          onSave: () {
            final nombre = _nombreController.text.trim();
            final direccion = _direccionController.text.trim();

            if (nombre.isNotEmpty && direccion.isNotEmpty) {
              _editGasolinera(gasolinera['id_gasolinera'], {
                'nombre': nombre,
                'direccion': direccion,
              });
              Navigator.of(context).pop();
            } else {
              _showError('Por favor, completa todos los campos.');
            }
          },
        );
      },
    );
  }

  // Diálogo base para agregar/editar gasolinera
  Widget _buildGasolineraDialog({required String title, required VoidCallback onSave}) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
