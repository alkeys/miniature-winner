import 'package:flutter/material.dart';
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http;

class VehiculosScreen extends StatefulWidget {
  @override
  _VehiculosScreenState createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  List<Map<String, dynamic>> vehiculos = [];
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _rendimientoController = TextEditingController();
  final TextEditingController _galonajeController = TextEditingController();
  final TextEditingController _tipoCombustibleController = TextEditingController();
  final String apiUrlVehiculos = 'https://symmetrical-funicular-mb61.onrender.com/vehiculos/';

  @override
  void initState() {
    super.initState();
    _fetchVehiculos();
  }

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _rendimientoController.dispose();
    _galonajeController.dispose();
    _tipoCombustibleController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehiculos() async {
    try {
      final response = await http.get(Uri.parse(apiUrlVehiculos));
      if (response.statusCode == 200) {
        setState(() {
          vehiculos = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener vehículos');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _addVehiculo(Map<String, dynamic> nuevoVehiculo) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlVehiculos),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevoVehiculo),
      );
      if (response.statusCode == 200) {
        _showSuccess('Vehículo creado exitosamente.');
        _fetchVehiculos();
      } else {
        _showError('Error al agregar vehículo: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _editVehiculo(int id, Map<String, dynamic> updatedVehiculo) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlVehiculos$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedVehiculo),
      );
      if (response.statusCode == 200) {
        _showSuccess('Vehículo editado exitosamente.');
        _fetchVehiculos();
      } else {
        _showError('Error al editar vehículo: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<void> _deleteVehiculo(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrlVehiculos$id'));
      if (response.statusCode == 200) {
        _showSuccess('Vehículo eliminado exitosamente.');
        _fetchVehiculos();
      } else {
        _showError('Error al eliminar vehículo: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

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
        title: Text('Gestión de Vehículos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddVehiculoDialog,
            tooltip: 'Agregar Vehículo',
          ),
        ],
      ),
      body: vehiculos.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: vehiculos.length,
          itemBuilder: (context, index) {
            final vehiculo = vehiculos[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(
                  '${vehiculo['modelo']} - ${vehiculo['marca']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Placa: ${vehiculo['placa']} | Tipo: ${vehiculo['tipo_combustible']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditVehiculoDialog(vehiculo),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteVehiculo(vehiculo['id_vehiculo']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddVehiculoDialog() {
    _modeloController.clear();
    _marcaController.clear();
    _placaController.clear();
    _rendimientoController.clear();
    _galonajeController.clear();
    _tipoCombustibleController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return _buildVehiculoDialog(
          title: 'Agregar Vehículo',
          onSave: () {
            final modelo = _modeloController.text.trim();
            final marca = _marcaController.text.trim();
            final placa = _placaController.text.trim();
            final rendimiento = double.tryParse(_rendimientoController.text.trim()) ?? 0.0;
            final galonaje = double.tryParse(_galonajeController.text.trim()) ?? 0.0;
            final tipoCombustible = _tipoCombustibleController.text.trim();

            if (modelo.isNotEmpty &&
                marca.isNotEmpty &&
                placa.isNotEmpty &&
                tipoCombustible.isNotEmpty) {
              _addVehiculo({
                'modelo': modelo,
                'marca': marca,
                'placa': placa,
                'rendimiento': rendimiento,
                'galonaje': galonaje,
                'tipo_combustible': tipoCombustible,
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

  void _showEditVehiculoDialog(Map<String, dynamic> vehiculo) {
    _modeloController.text = vehiculo['modelo'];
    _marcaController.text = vehiculo['marca'];
    _placaController.text = vehiculo['placa'];
    _rendimientoController.text = vehiculo['rendimiento'].toString();
    _galonajeController.text = vehiculo['galonaje'].toString();
    _tipoCombustibleController.text = vehiculo['tipo_combustible'];

    showDialog(
      context: context,
      builder: (context) {
        return _buildVehiculoDialog(
          title: 'Editar Vehículo',
          onSave: () {
            final modelo = _modeloController.text.trim();
            final marca = _marcaController.text.trim();
            final placa = _placaController.text.trim();
            final rendimiento = double.tryParse(_rendimientoController.text.trim()) ?? 0.0;
            final galonaje = double.tryParse(_galonajeController.text.trim()) ?? 0.0;
            final tipoCombustible = _tipoCombustibleController.text.trim();

            if (modelo.isNotEmpty &&
                marca.isNotEmpty &&
                placa.isNotEmpty &&
                tipoCombustible.isNotEmpty) {
              _editVehiculo(vehiculo['id_vehiculo'], {
                'modelo': modelo,
                'marca': marca,
                'placa': placa,
                'rendimiento': rendimiento,
                'galonaje': galonaje,
                'tipo_combustible': tipoCombustible,
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

  Widget _buildVehiculoDialog({required String title, required VoidCallback onSave}) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: Colors.teal)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _marcaController,
              decoration: InputDecoration(labelText: 'Marca'),
            ),
            TextField(
              controller: _placaController,
              decoration: InputDecoration(labelText: 'Placa'),
            ),
            TextField(
              controller: _rendimientoController,
              decoration: InputDecoration(labelText: 'Rendimiento (km/gal)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _galonajeController,
              decoration: InputDecoration(labelText: 'Galonaje'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _tipoCombustibleController,
              decoration: InputDecoration(labelText: 'Tipo de Combustible'),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
