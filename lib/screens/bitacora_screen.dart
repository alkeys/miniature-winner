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
  late int _role;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _refreshList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId') ?? 0;
    _role = prefs.getInt('rol') ?? 0;

    if (_userId == 0 || _role == 0) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    setState(() {
      _bitacoras = _fetchFilteredBitacoras();
    });
  }

  Future<List<Bitacora>> _fetchFilteredBitacoras() async {
    if (_userId == 0) {
      throw Exception('ID de usuario no encontrado');
    }
    return await _service.getBitacorasByUser(_userId);
  }

  void _refreshList() {
    setState(() {
      _bitacoras = _fetchFilteredBitacoras();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bitácoras',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.blue),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              await prefs.remove('rol');
              Navigator.pushReplacementNamed(context, '/');
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
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (snapshot.hasData) {
            final bitacoras = snapshot.data!;
            if (bitacoras.isEmpty) {
              return Center(
                child: Text(
                  'No se encontraron bitácoras',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              );
            }
            return ListView.builder(
              itemCount: bitacoras.length,
              itemBuilder: (context, index) {
                final bitacora = bitacoras[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16), // Más espacio interno
                    title: Text(
                      bitacora.comentario,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      'KM Inicial: ${bitacora.kmInicial}, KM Final: ${bitacora.kmFinal}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[700]),
                      onPressed: () {
                        _service
                            .deleteBitacora(bitacora.id)
                            .then((_) => _refreshList());
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No se encontraron datos',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/bitacora/create');
        },
        label: Text('Agregar'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
