import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogsScreen extends StatefulWidget {
  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> logs = [];
  final String apiUrlLogs = 'https://symmetrical-funicular-mb61.onrender.com/log/';
  final String apiUrlUsuarios = 'https://symmetrical-funicular-mb61.onrender.com/usuarios/';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // Obtener logs desde la API
  Future<void> _fetchLogs() async {
    try {
      final response = await http.get(Uri.parse(apiUrlLogs));
      if (response.statusCode == 200) {
        setState(() {
          logs = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        _showError('Error al obtener logs');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Obtener nombre del usuario a partir de su ID
  Future<String> _fetchUsuarioNombre(int idUsr) async {
    try {
      final response = await http.get(Uri.parse('$apiUrlUsuarios$idUsr'));
      if (response.statusCode == 200) {
        final usuario = json.decode(response.body);
        return usuario['nombre'];
      } else {
        throw Exception('Error al obtener usuario');
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

  // Mostrar detalles del log
  void _showLogDetails(Map<String, dynamic> log, String nombreUsuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del Log'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID Log: ${log['id_log']}'),
                Text('Descripción: ${log['descripcion']}'),
                Text('Hora: ${log['hora']}'),
                Text('Usuario: $nombreUsuario'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return FutureBuilder(
                  future: _fetchUsuarioNombre(log['id_usr']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Cargando...'),
                        subtitle: Text('Obteniendo información del usuario...'),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      final nombreUsuario = snapshot.data as String;
                      return ListTile(
                        title: Text('Log de $nombreUsuario'),
                        subtitle: Text('Hora: ${log['hora']}'),
                        onTap: () => _showLogDetails(log, nombreUsuario),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
