import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BitacorasScreen extends StatefulWidget {
  @override
  _BitacorasScreenState createState() => _BitacorasScreenState();
}

class _BitacorasScreenState extends State<BitacorasScreen> {
  List<Map<String, dynamic>> bitacoras = [];
  final String apiUrlBitacoras = 'https://symmetrical-funicular-mb61.onrender.com/bitacora/';
  final String apiUrlUsuarios = 'https://symmetrical-funicular-mb61.onrender.com/usuarios/';
  final String apiUrlVehiculos = 'https://symmetrical-funicular-mb61.onrender.com/vehiculos/';
  final String apiUrlGasolineras = 'https://symmetrical-funicular-mb61.onrender.com/gasolineras/';
  final String apiUrlProyectos = 'https://symmetrical-funicular-mb61.onrender.com/proyecto/';

  @override
  void initState() {
    super.initState();
    _fetchBitacoras();
  }
  bool _isLoading = true; // Variable para controlar el estado de carga
  // Obtener bitácoras desde la API
  Future<void> _fetchBitacoras() async {
    try {
      final response = await http.get(Uri.parse(apiUrlBitacoras));
      if (response.statusCode == 200) {
        setState(() {
          bitacoras = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false; // Actualiza _isLoading a false después de obtener las bitácoras
        });
      } else {
        _showError('Error al obtener bitácoras');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Obtener los detalles de usuario, vehículo, gasolinera, proyecto
  Future<Map<String, dynamic>> _fetchDetalles(int idUsr, int idVehiculo, int idGasolinera, int idProyecto) async {
    try {
      final usuarioResponse = await http.get(Uri.parse('$apiUrlUsuarios$idUsr'));
      final vehiculoResponse = await http.get(Uri.parse('$apiUrlVehiculos$idVehiculo'));
      final gasolineraResponse = await http.get(Uri.parse('$apiUrlGasolineras$idGasolinera'));
      final proyectoResponse = await http.get(Uri.parse('$apiUrlProyectos$idProyecto'));

      if (usuarioResponse.statusCode == 200 && vehiculoResponse.statusCode == 200 && gasolineraResponse.statusCode == 200 && proyectoResponse.statusCode == 200) {
        return {
          'usuario': json.decode(usuarioResponse.body),
          'vehiculo': json.decode(vehiculoResponse.body),
          'gasolinera': json.decode(gasolineraResponse.body),
          'proyecto': json.decode(proyectoResponse.body),
        };
      } else {
        throw Exception('Error al obtener detalles');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
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

  // Mostrar detalles de la bitácora
  void _showBitacoraDetails(Map<String, dynamic> bitacora) async {
    try {
      final detalles = await _fetchDetalles(
        bitacora['id_usr'],
        bitacora['id_vehiculo'],
        bitacora['id_gasolinera'],
        bitacora['id_proyecto'],
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Detalles de Bitácora'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comentario: ${bitacora['comentario']}'),
                  Text('Kilómetros Iniciales: ${bitacora['km_inicial']}'),
                  Text('Kilómetros Finales: ${bitacora['km_final']}'),
                  Text('Número de Galones: ${bitacora['num_galones']}'),
                  Text('Costo: ${bitacora['costo']}'),
                  Text('Tipo de Gasolina: ${bitacora['tipo_gasolina']}'),
                  Text('Usuario: ${detalles['usuario']['nombre']}'),
                  Text('Vehículo: ${detalles['vehiculo']['modelo']} (${detalles['vehiculo']['placa']})'),
                  Text('Gasolinera: ${detalles['gasolinera']['nombre']}'),
                  Text('Proyecto: ${detalles['proyecto']['nombre']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showError('No se pudieron obtener los detalles: $e');
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Bitácoras'),
    ),
    body: _isLoading
        ? Center(
            child:CircularProgressIndicator(), // Texto que reemplaza el indicador de carga
          )
        : ListView.builder(
            itemCount: bitacoras.length,
            itemBuilder: (context, index) {
              final bitacora = bitacoras[index];
              return FutureBuilder(
                future: _fetchDetalles(
                  bitacora['id_usr'],
                  bitacora['id_vehiculo'],
                  bitacora['id_gasolinera'],
                  bitacora['id_proyecto'],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Cargando...'),
                      subtitle: Text('Cargando detalles de la bitácora...'),
                    );
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    var detalles = snapshot.data as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Bitácora de ${detalles['usuario']['nombre']}'),
                      subtitle: Text('Km Inicial: ${bitacora['km_inicial']} | Km Final: ${bitacora['km_final']}'),
                      onTap: () => _showBitacoraDetails(bitacora),
                    );
                  }
                },
              );
            },
          ),
  );
}
}