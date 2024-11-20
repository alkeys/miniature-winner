import 'package:flutter/material.dart';
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http;

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> roles = []; // Lista de roles
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  int? _selectedRol; // Rol seleccionado
  bool _activo = true;

  final String apiUrlUsuarios = 'https://symmetrical-funicular-mb61.onrender.com/usuarios';
  final String apiUrlRoles = 'https://symmetrical-funicular-mb61.onrender.com/rol'; // URL para obtener roles

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
    _fetchRoles(); // Obtiene los roles al iniciar
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Método para obtener usuarios desde la API
  Future<void> _fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrlUsuarios));
      if (response.statusCode == 200) {
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener usuarios');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Método para obtener roles desde la API
  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse(apiUrlRoles));
      if (response.statusCode == 200) {
        setState(() {
          roles = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        _showError('Error al obtener roles');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Método para agregar un usuario
  Future<void> _addUsuario(Map<String, dynamic> nuevoUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlUsuarios),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevoUsuario),
      );
      if (response.statusCode == 201) {
        _fetchUsuarios();
      } else {
        _showError('Error al agregar usuario');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Método para editar un usuario
  Future<void> _editUsuario(int id, Map<String, dynamic> updatedUsuario) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrlUsuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUsuario),
      );
      if (response.statusCode == 200) {
        _fetchUsuarios();
      } else {
        _showError('Error al editar usuario');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Método para eliminar un usuario
  Future<void> _deleteUsuario(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrlUsuarios/$id'));
      if (response.statusCode == 200) {
        _fetchUsuarios();
      } else {
        _showError('Error al eliminar usuario');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  // Mostrar un cuadro de error
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
        title: Text('Gestión de Usuarios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text('${usuario['nombre']} ${usuario['apellido']}'),
                  subtitle: Text('ID: ${usuario['id_usr']} | Username: ${usuario['username']} | Rol: ${usuario['id_rol']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditUsuarioDialog(usuario);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteUsuario(usuario['id_usr']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUsuarioDialog() {
    _nombreController.clear();
    _apellidoController.clear();
    _passwordController.clear();
    _usernameController.clear();
    _selectedRol = roles.isNotEmpty ? roles.first['id_rol'] : null;
    _activo = true;

    showDialog(
      context: context,
      builder: (context) {
        return _buildUsuarioDialog(
          title: 'Agregar Usuario',
          onSave: () {
            final nombre = _nombreController.text;
            final apellido = _apellidoController.text;
            final password = _passwordController.text;
            final username = _usernameController.text;

            if (nombre.isNotEmpty && apellido.isNotEmpty && password.isNotEmpty && username.isNotEmpty && _selectedRol != null) {
              _addUsuario({
                'nombre': nombre,
                'apellido': apellido,
                'password': password,
                'username': username,
                'id_rol': _selectedRol,
                'activo': _activo,
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showEditUsuarioDialog(Map<String, dynamic> usuario) {
    _nombreController.text = usuario['nombre'];
    _apellidoController.text = usuario['apellido'];
    _passwordController.text = ''; // No mostrar contraseñas existentes
    _usernameController.text = usuario['username'];
    _selectedRol = usuario['id_rol'];
    _activo = usuario['activo'];

    showDialog(
      context: context,
      builder: (context) {
        return _buildUsuarioDialog(
          title: 'Editar Usuario',
          onSave: () {
            final nombre = _nombreController.text;
            final apellido = _apellidoController.text;
            final username = _usernameController.text;

            if (nombre.isNotEmpty && apellido.isNotEmpty && username.isNotEmpty && _selectedRol != null) {
              _editUsuario(usuario['id_usr'], {
                'nombre': nombre,
                'apellido': apellido,
                'password': usuario['password'], // Mantener contraseña previa
                'username': username,
                'id_rol': _selectedRol,
                'activo': _activo,
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildUsuarioDialog({required String title, required VoidCallback onSave}) {
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
              controller: _apellidoController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
          roles.isEmpty
              ? CircularProgressIndicator() // Mostrar un indicador de carga
              : DropdownButtonFormField<int>(
            value: _selectedRol,
            items: roles.map((rol) {
              return DropdownMenuItem<int>(
                value: rol['id_rol'], // Verifica que sea int
                child: Text(rol['descripcion']), // Verifica que sea String
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRol = value;
              });
            },
            decoration: InputDecoration(labelText: 'Rol'),
          ),

          SwitchListTile(
              title: Text('Activo'),
              value: _activo,
              onChanged: (value) {
                setState(() {
                  _activo = value;
                });
              },
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
