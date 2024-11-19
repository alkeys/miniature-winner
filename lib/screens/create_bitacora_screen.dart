import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CreateBitacoraScreen extends StatefulWidget {
  @override
  _CreateBitacoraScreenState createState() => _CreateBitacoraScreenState();
}

class _CreateBitacoraScreenState extends State<CreateBitacoraScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _kmInicialController = TextEditingController();
  final TextEditingController _kmFinalController = TextEditingController();
  final TextEditingController _numGalonesController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _tipoGasolinaController = TextEditingController();
  final String _url = 'https://symmetrical-funicular-mb61.onrender.com';

  // Variables para dropdowns
  List<Map<String, dynamic>> _vehiculos = [];
  List<Map<String, dynamic>> _gasolineras = [];
  List<Map<String, dynamic>> _proyectos = [];

  int? _selectedVehiculo;
  int? _selectedGasolinera;
  int? _selectedProyecto;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final vehiculosResponse =
      await http.get(Uri.parse('$_url/vehiculos'));
      final gasolinerasResponse =
      await http.get(Uri.parse('$_url/gasolineras'));
      final proyectosResponse =
      await http.get(Uri.parse('$_url/proyecto'));

      if (vehiculosResponse.statusCode == 200 &&
          gasolinerasResponse.statusCode == 200 &&
          proyectosResponse.statusCode == 200) {
        setState(() {
          _vehiculos = List<Map<String, dynamic>>.from(
            json.decode(vehiculosResponse.body).map((item) => {
              'id': item['id_vehiculo'],
              'nombre': '${item['marca']} ${item['modelo']}',
            }),
          );
          _gasolineras = List<Map<String, dynamic>>.from(
            json.decode(gasolinerasResponse.body).map((item) => {
              'id': item['id_gasolinera'],
              'nombre': item['nombre'],
            }),
          );
          _proyectos = List<Map<String, dynamic>>.from(
            json.decode(proyectosResponse.body).map((item) => {
              'id': item['id_proyecto'],
              'nombre': item['nombre'],
            }),
          );
        });
      } else {
        throw Exception('Error al obtener datos');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos para selección')),
      );
    }
  }

  Future<void> _createBitacora() async {
    final String apiUrl = '$_url/bitacora/';

    if (_formKey.currentState!.validate()) {
      if (_selectedVehiculo == null ||
          _selectedGasolinera == null ||
          _selectedProyecto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe seleccionar todos los campos')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      int userId = await _getUserId();
      print('ID del usuario autenticado: $userId');

      final requestBody = {
        'comentario': _comentarioController.text,
        'km_inicial': int.parse(_kmInicialController.text),
        'km_final': int.parse(_kmFinalController.text),
        'num_galones': double.parse(_numGalonesController.text),
        'costo': double.parse(_costoController.text),
        'tipo_gasolina': _tipoGasolinaController.text,
        'id_usr': userId,
        'id_vehiculo': _selectedVehiculo,
        'id_gasolinera': _selectedGasolinera,
        'id_proyecto': _selectedProyecto,
      };

      print('Enviando datos al servidor: $requestBody');

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        print('Respuesta del servidor: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bitácora creada con éxito')),
          );
          Navigator.pop(context); // Vuelve a la pantalla anterior
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al crear la bitácora: ${response.body}')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión al servidor')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }


  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> items,
    required int? selectedValue,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem<int>(
        value: item['id'],
        child: Text(item['nombre']),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Seleccione una opción';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Bitácora'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _comentarioController,
                  decoration: InputDecoration(
                    labelText: 'Comentario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El comentario es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _kmInicialController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'KM Inicial',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El KM Inicial es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _kmFinalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'KM Final',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El KM Final es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _numGalonesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Número de Galones',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de galones es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _costoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Costo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El costo es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _tipoGasolinaController,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Gasolina',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El tipo de gasolina es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildDropdown(
                  label: 'Vehículo',
                  items: _vehiculos,
                  selectedValue: _selectedVehiculo,
                  onChanged: (value) {
                    setState(() {
                      _selectedVehiculo = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _buildDropdown(
                  label: 'Gasolinera',
                  items: _gasolineras,
                  selectedValue: _selectedGasolinera,
                  onChanged: (value) {
                    setState(() {
                      _selectedGasolinera = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                _buildDropdown(
                  label: 'Proyecto',
                  items: _proyectos,
                  selectedValue: _selectedProyecto,
                  onChanged: (value) {
                    setState(() {
                      _selectedProyecto = value;
                    });
                  },
                ),
                SizedBox(height: 24.0),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _createBitacora,
                  child: Text('Crear Bitácora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
