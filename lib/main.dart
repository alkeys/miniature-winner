import 'package:flutter/material.dart';
import 'package:gojo/screens/Admin/BitacorasScreen.dart';
import 'package:gojo/screens/Admin/GasolineraScreen.dart';
import 'package:gojo/screens/Admin/LogsScreen.dart';
import 'package:gojo/screens/Admin/ProyectoScreen.dart';
import 'package:gojo/screens/Admin/RolsScreen.dart';
import 'package:gojo/screens/Admin/UsuariosScreen.dart';
import 'package:gojo/screens/Admin/VehiculosScreen.dart';
import 'package:gojo/screens/AdminScreen.dart';
import 'package:gojo/screens/Home.dart';
import 'package:gojo/screens/bitacora_screen.dart';
import 'package:gojo/screens/create_bitacora_screen.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bienbenido a Software de Proyecto',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/bitacora': (context) => BitacoraScreen(),
        '/bitacora/create': (context) => CreateBitacoraScreen(),
        '/usuarios': (context) => UsuariosScreen(),
        '/bitacoras': (context) => BitacorasScreen(),
        '/Logs': (context) => LogsScreen(),
        '/vehiculos': (context) => VehiculosScreen(),
        '/proyectos': (context) => ProyectosScreen(),
        '/gasolinera': (context) => GasolinerasScreen(),
        '/Rols': (context) => RolesScreen(),
        '/login' : (context) => AuthScreen(),

      },

    );
  }
}
