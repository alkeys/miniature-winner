import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogsScreen extends StatefulWidget {
  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> logs = [];
  List<Map<String, dynamic>> usuarios = [];
  Map<int, String> usuariosPorId = {}; // Mapa para guardar nombres de usuarios por ID
  Map<String, dynamic>? selectedUsuario;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  final String apiUrlLogs = 'https://symmetrical-funicular-mb61.onrender.com/log/usuario/';
  final String apiUrlUsuarios = 'https://symmetrical-funicular-mb61.onrender.com/usuarios/';

  bool _isLoading = true;
  bool _logsVisible = false; // Estado para controlar la visibilidad de los logs

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
  }

  // Obtener usuarios desde la API
  Future<void> _fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrlUsuarios));
      if (response.statusCode == 200) {
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        _showError('Error al obtener usuarios');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Obtener logs de un usuario específico
  Future<void> _fetchLogs(int userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$apiUrlLogs$userId'));
      if (response.statusCode == 200) {
        final logData = json.decode(response.body);
        print("Logs recibidos: $logData");

        // Crear un mapa con los IDs de los usuarios y sus nombres
        Map<int, String> usuariosPorIdTemp = {};
        for (var log in logData) {
          if (!usuariosPorIdTemp.containsKey(log['id_usr'])) {
            final usuarioNombre = await _fetchUsuarioNombre(log['id_usr']);
            usuariosPorIdTemp[log['id_usr']] = usuarioNombre;
          }
        }

        // Convertir las fechas a DateTime y ordenar los logs por fecha
        logData.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateA.compareTo(dateB); // Orden ascendente, usa reverse() para descendente
        });

        // Filtrar los logs por rango de fechas si se ha seleccionado
        if (selectedStartDate != null || selectedEndDate != null) {
          logData.retainWhere((log) {
            DateTime logDate = DateTime.parse(log['created_at']);
            bool withinStartDate = selectedStartDate == null || logDate.isAfter(selectedStartDate!);
            bool withinEndDate = selectedEndDate == null || logDate.isBefore(selectedEndDate!);
            return withinStartDate && withinEndDate;
          });
        }

        setState(() {
          logs = List<Map<String, dynamic>>.from(logData);
          usuariosPorId = usuariosPorIdTemp; // Guardar en el mapa final
          _isLoading = false;
          _logsVisible = true; // Mostrar los logs después de cargarlos
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

  // Mostrar detalles del log
  void _showLogDetails(Map<String, dynamic> log, String nombreUsuario) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles del Log', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID Log: ${log['id_log']}'),
                Text('Descripción: ${log['descripcion']}'),
                Text('Hora: ${log['created_at']}'),
                Text('Usuario: $nombreUsuario'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2020);
    final DateTime lastDate = DateTime(2101);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = pickedDate;
        } else {
          selectedEndDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para seleccionar un usuario
            Text('Selecciona un usuario:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            DropdownButton<Map<String, dynamic>>(
              isExpanded: true,
              value: selectedUsuario,
              hint: Text('Selecciona un usuario'),
              items: usuarios.map((usuario) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: usuario,
                  child: Text(usuario['nombre']),
                );
              }).toList(),
              onChanged: (Map<String, dynamic>? value) {
                setState(() {
                  selectedUsuario = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Filtro de fechas
            Text('Filtrar por fecha:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fecha de inicio
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    selectedStartDate == null
                        ? 'Seleccionar Fecha Inicio'
                        : 'Inicio: ${selectedStartDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                // Fecha de fin
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    selectedEndDate == null
                        ? 'Seleccionar Fecha Fin'
                        : 'Fin: ${selectedEndDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Botón para ver logs
            ElevatedButton(
              onPressed: selectedUsuario == null
                  ? null
                  : () {
                if (selectedUsuario != null) {
                  _fetchLogs(selectedUsuario!['id_usr']);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Ver Logs'),
            ),
            SizedBox(height: 16),
            // Mostrar logs del usuario seleccionado
            _logsVisible
                ? Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final nombreUsuario =
                      usuariosPorId[log['id_usr']] ?? 'Cargando...';
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text('${log['descripcion']}  de $nombreUsuario', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Hora: ${log['created_at']}'),
                      onTap: () => _showLogDetails(log, nombreUsuario),
                    ),
                  );
                },
              ),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
