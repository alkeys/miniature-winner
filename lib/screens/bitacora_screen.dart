import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Importar Timer
import '../services/bitacora_service.dart';
import '../models/Bitacora.dart';

class BitacoraScreen extends StatefulWidget {
  @override
  _BitacoraScreenState createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  final BitacoraService _service = BitacoraService();
  late Future<List<Bitacora>> _bitacoras;
  late int _userId;
  Timer? _timer; // Timer para actualizar automáticamente

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshList(); // Actualizar la lista de bitácoras
    });
  }

  @override
  void dispose() {
    // Cancelar el Timer al salir de la pantalla
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0; // Cargar el ID del usuario
      print('ID de usuario: $_userId');
      _bitacoras = _fetchFilteredBitacoras(); // Actualizar la lista de bitácoras
    });
  }

  Future<List<Bitacora>> _fetchFilteredBitacoras() async {
    if (_userId == 0) {
      throw Exception('ID de usuario no encontrado');
    }
    return await _service.getBitacorasByUser(_userId); // Obtener bitácoras filtradas por usuario
  }

  void _refreshList() {
    setState(() {
      _bitacoras = _fetchFilteredBitacoras(); // Recargar solo las bitácoras del usuario actual
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitácoras'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Cerrar sesión
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              Navigator.pushReplacementNamed(context, '/'); // Regresar al login
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Bitacora>>(
        future: _bitacoras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final bitacoras = snapshot.data!;
            if (bitacoras.isEmpty) {
              return Center(child: Text('No se encontraron bitácoras'));
            }
            return ListView.builder(
              itemCount: bitacoras.length,
              itemBuilder: (context, index) {
                final bitacora = bitacoras[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(bitacora.comentario),
                    subtitle: Text(
                      'KM Inicial: ${bitacora.kmInicial}, KM Final: ${bitacora.kmFinal}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _service.deleteBitacora(bitacora.id).then((_) => _refreshList());
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron datos'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/bitacora/create'); // Navegar a la pantalla de creación
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
