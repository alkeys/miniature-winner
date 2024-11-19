import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Bitacora.dart';

class BitacoraService {
  final String baseUrl = 'http://127.0.0.1:8000/bitacora';

  /// Obtiene todas las bitácoras
  Future<List<Bitacora>> getBitacoras() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Bitacora.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener las bitácoras');
    }
  }

  /// Crea una nueva bitácora
  Future<Bitacora> createBitacora(Bitacora bitacora) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bitacora.toJson()),
    );
    if (response.statusCode == 201) {
      return Bitacora.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear la bitácora');
    }
  }

  /// Actualiza una bitácora existente
  Future<void> updateBitacora(int id, Bitacora bitacora) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bitacora.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la bitácora');
    }
  }

  /// Elimina una bitácora
  Future<void> deleteBitacora(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la bitácora');
    }
  }

  /// Obtiene bitácoras filtradas por usuario
  Future<List<Bitacora>> getBitacorasByUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/usuario/$userId'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Bitacora.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener las bitácoras del usuario');
    }
  }
}
