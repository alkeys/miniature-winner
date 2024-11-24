import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerLastNameController = TextEditingController();
  final String apiUrl1 = 'https://symmetrical-funicular-mb61.onrender.com';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String apiUrl = '$apiUrl1/usuarios/login/user/pass';

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userId = data['id_usr'];
        final rol = data['id_rol'];

        // Guardar el ID del usuario en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);


        // Navegar a la pantalla de Bitácora
        if (rol == 2) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (rol == 1) {
          Navigator.pushReplacementNamed(context, '/bitacora');
        }

      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales incorrectas')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión al servidor')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }





  Future<void> _register() async {
    final String apiUrl = '$apiUrl1/usuarios/';

    if (_registerNameController.text.isEmpty ||
        _registerLastNameController.text.isEmpty ||
        _registerUsernameController.text.isEmpty ||
        _registerPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': _registerNameController.text,
          'apellido': _registerLastNameController.text,
          'username': _registerUsernameController.text,
          'password': _registerPasswordController.text,
          'activo': false,
          'id_rol': 1,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado con éxito')),
        );
        _tabController.animateTo(0); // Cambiar al tab de inicio de sesión
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar usuario: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión al servidor')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color.fromARGB(255, 70, 37, 126),
          const Color.fromARGB(255, 87, 48, 155),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ),
  title: Padding(
  padding: const EdgeInsets.only(top: 10.0, left: 16.0), // Márgenes superior e izquierdo
  child: Text(
    'Autenticación',
    style: TextStyle(
      color: Colors.purpleAccent, // Texto morado
      fontWeight: FontWeight.bold, // Negrita
      fontSize: 24.0, // Tamaño del texto
    ),
  ),
),

  bottom: PreferredSize(
  preferredSize: Size.fromHeight(50.0), // Altura fija estándar para la TabBar
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Ajuste del tamaño de texto según el ancho de la pantalla
      double fontSize = constraints.maxWidth < 600 ? 14.0 : 18.0; // Pantallas pequeñas vs grandes
      double tabHeight = constraints.maxWidth < 600 ? 40.0 : 50.0; // Altura adaptable

      return Container(
        height: tabHeight,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.purpleAccent, // Color de las pestañas activas
          unselectedLabelColor: Colors.white, // Color de las pestañas inactivas
          indicatorColor: Colors.purpleAccent, // Indicador de pestañas activas
          indicatorWeight: 3.0, // Grosor del indicador
          labelStyle: TextStyle(
            fontSize: fontSize, // Tamaño del texto adaptable
            fontWeight: FontWeight.bold, // Negrita para las pestañas activas
          ),
          tabs: [
            Tab(text: 'Iniciar Sesión'),
            Tab(text: 'Registro'),
          ],
        ),
      );
    },
  ),
),

),


    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurple,
            Colors.purpleAccent,
          ],
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildRegisterForm(),
        ],
      ),
    ),
  );
}


  Widget _buildLoginForm() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Ancho adaptable para el TextField
            double textFieldWidth = constraints.maxWidth < 600 
                ? constraints.maxWidth * 0.9 // Pantallas pequeñas (90% del ancho)
                : 800; // Pantallas grandes (fijo en 400 px)

            return SizedBox(
              width: textFieldWidth,
              child: TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white), // Letras en blanco
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Borde en blanco
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20.0),
        LayoutBuilder(
          builder: (context, constraints) {
            // Ancho adaptable para el TextField
            double textFieldWidth = constraints.maxWidth < 600 
                ? constraints.maxWidth * 0.9 // Pantallas pequeñas (90% del ancho)
                : 800; // Pantallas grandes (fijo en 400 px)

            return SizedBox(
              width: textFieldWidth,
              child: TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white), // Letras en blanco
                obscureText: true, // Oculta la contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Borde en blanco
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 40.0),
        _isLoading
            ? CircularProgressIndicator()
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Ancho adaptable para el botón
                  double buttonWidth = constraints.maxWidth < 600 
                      ? constraints.maxWidth * 0.8 // Para pantallas pequeñas
                      : 400; // Para pantallas grandes

                  return SizedBox(
                    width: buttonWidth, // Ancho del botón
                    height: 50, // Altura fija
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                        ),
                        backgroundColor: Colors.purple, // Color del botón
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 18.0, // Tamaño del texto
                          color: Colors.white, // Color del texto
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    ),
  );
}

Widget _buildRegisterForm() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double textFieldWidth = constraints.maxWidth < 600
                ? constraints.maxWidth * 0.9 // Pantallas pequeñas
                : 800; // Pantallas grandes

            return Column(
              children: [
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _registerNameController,
                    style: TextStyle(color: Colors.white), // Letras en blanco
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _registerLastNameController,
                    style: TextStyle(color: Colors.white), // Letras en blanco
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _registerUsernameController,
                    style: TextStyle(color: Colors.white), // Letras en blanco
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: textFieldWidth,
                  child: TextField(
                    controller: _registerPasswordController,
                    style: TextStyle(color: Colors.white), // Letras en blanco
                    obscureText: true, // Ocultar contraseña
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.white), // Etiqueta en blanco
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Borde blanco
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0), // Borde blanco al enfocar
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 40.0),
        _isLoading
            ? CircularProgressIndicator()
            : LayoutBuilder(
                builder: (context, constraints) {
                  double buttonWidth = constraints.maxWidth < 600
                      ? constraints.maxWidth * 0.8 // Botón adaptable en pantallas pequeñas
                      : 400; // Botón fijo en pantallas grandes

                  return SizedBox(
                    width: buttonWidth,
                    height: 50, // Altura fija
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                        ),
                        backgroundColor: Colors.purple, // Color del botón
                      ),
                      child: Text(
                        'Registrar',
                        style: TextStyle(
                          fontSize: 18.0, // Tamaño del texto
                          color: Colors.white, // Color del texto
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    ),
  );
}

}
