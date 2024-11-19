import 'package:flutter/material.dart';
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
      title: 'Autenticación',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/bitacora': (context) => BitacoraScreen(),
        '/bitacora/create': (context) => CreateBitacoraScreen(),
      },

    );
  }
}
