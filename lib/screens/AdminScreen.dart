import 'package:flutter/material.dart';
import 'package:gojo/screens/Admin/UsuariosScreen.dart';
import 'package:gojo/screens/Admin/VehiculosScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => AdminScreen(),
        '/usuarios': (context) => UsuariosScreen(),
        '/bitacoras': (context) => BitacorasScreen(),
        '/vehiculos': (context) => VehiculosScreen(),
        '/proyectos': (context) => ProyectosScreen(),
      },
    );
  }
}


class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminButton(context, 'Usuarios', Icons.person, '/usuarios'),
          _buildAdminButton(context, 'Bitácoras', Icons.book, '/bitacoras'),
          _buildAdminButton(context, 'Vehículos', Icons.directions_car, '/vehiculos'),
          _buildAdminButton(context, 'Proyectos', Icons.work, '/proyectos'),
          // Agrega más botones aquí
        ],
      ),
    );
  }

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
}


class BitacorasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bitácoras')),
      body: Center(child: Text('Gestión de Bitácoras')),
    );
  }
}



class ProyectosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proyectos')),
      body: Center(child: Text('Gestión de Proyectos')),
    );
  }
}