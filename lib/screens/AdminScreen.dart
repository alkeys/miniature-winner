import 'package:flutter/material.dart';
import 'package:gojo/screens/Admin/BitacorasScreen.dart';
import 'package:gojo/screens/Admin/GasolineraScreen.dart';
import 'package:gojo/screens/Admin/LogsScreen.dart';
import 'package:gojo/screens/Admin/ProyectoScreen.dart';
import 'package:gojo/screens/Admin/RolsScreen.dart';
import 'package:gojo/screens/Admin/UsuariosScreen.dart';
import 'package:gojo/screens/Admin/VehiculosScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/admin': (context) => AdminScreen(),
        '/usuarios': (context) => UsuariosScreen(),
        '/bitacoras': (context) => BitacorasScreen(),
        '/Logs': (context) => LogsScreen(),
        '/vehiculos': (context) => VehiculosScreen(),
        '/proyectos': (context) => ProyectosScreen(),
        '/gasolinera': (context) => GasolinerasScreen(),
        '/Rols': (context) => RolesScreen(),
      },
    );
  }
}

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == 2) {
          // Si el usuario es administrador, mostrar la pantalla
          return Scaffold(
            appBar: AppBar(
              title: Text('Admin Panel'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await _logout(context);
                  },
                  tooltip: "Cerrar Sesión",
                ),
              ],
            ),
            body: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAdminButton(context, 'Usuarios', Icons.person, '/usuarios'),
                _buildAdminButton(context, 'Bitácoras', Icons.book, '/bitacoras'),
                _buildAdminButton(context, 'Logs', Icons.login, '/Logs'),
                _buildAdminButton(context, 'Vehículos', Icons.directions_car, '/vehiculos'),
                _buildAdminButton(context, 'Proyectos', Icons.work, '/proyectos'),
                _buildAdminButton(context, 'Gasolinera', Icons.gas_meter, '/gasolinera'),
                _buildAdminButton(context, 'Roles', Icons.task_sharp, '/Rols'),
                // Agrega más botones aquí
              ],
            ),
          );
        }

        // Si no es administrador, mostrar un mensaje de acceso denegado
        return Scaffold(
          appBar: AppBar(
            title: Text("Acceso Denegado"),
          ),
          body: Center(
            child: Text(
              "No tienes permiso para acceder a esta página.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  // Método para obtener el rol del usuario desde SharedPreferences
  Future<int?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('rol');
  }

  // Método para construir los botones del panel de administración
  Widget _buildAdminButton(BuildContext context, String title, IconData icon, String route) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos guardados en SharedPreferences
    Navigator.pushReplacementNamed(context, '/'); // Regresar al login
  }
}
