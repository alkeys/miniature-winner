import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
        '/usuarios': (context) => PlaceholderScreen('Usuarios'),
        '/bitacoras': (context) => PlaceholderScreen('Bitácoras'),
        '/Logs': (context) => PlaceholderScreen('Logs'),
        '/vehiculos': (context) => PlaceholderScreen('Vehículos'),
        '/proyectos': (context) => PlaceholderScreen('Proyectos'),
        '/gasolinera': (context) => PlaceholderScreen('Gasolinera'),
        '/Rols': (context) => PlaceholderScreen('Roles'),
      },
    );
  }
}

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Usuarios',
    'Bitácoras',
    'Logs',
    'Vehículos',
    'Proyectos',
    'Gasolinera',
    'Roles',
  ];

  final List<IconData> _icons = [
    Icons.person,
    Icons.book,
    Icons.login,
    Icons.directions_car,
    Icons.work,
    Icons.gas_meter,
    Icons.task_sharp,
  ];

  final List<String> _routes = [
    '/usuarios',
    '/bitacoras',
    '/Logs',
    '/vehiculos',
    '/proyectos',
    '/gasolinera',
    '/Rols',
  ];

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
            body: Column(
              children: [
                _buildHeader(), // Barra superior con navegación
                Expanded(
                  child: _buildContent(context), // Contenido dinámico
                ),
              ],
            ),
          );
        }

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

  Widget _buildHeader() {
    return Container(
      color: Colors.blue[50],
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_titles.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index; // Actualiza el índice seleccionado
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: _selectedIndex == index
                      ? Colors.blue[300]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icons[index],
                      size: 20,
                      color: _selectedIndex == index
                          ? Colors.white
                          : Colors.blue[900],
                    ),
                    SizedBox(width: 8),
                    Text(
                      _titles[index],
                      style: TextStyle(
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _icons[_selectedIndex],
            size: 100,
            color: Colors.blue[800],
          ),
          SizedBox(height: 16),
          Text(
            _titles[_selectedIndex],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, _routes[_selectedIndex]);
            },
            child: Text('Ir a ${_titles[_selectedIndex]}'),
          ),
        ],
      ),
    );
  }

  Future<int?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('rol');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    const apiUrl2 = 'https://symmetrical-funicular-mb61.onrender.com/usuarios/estado';
    final response2 = await http.put(
      Uri.parse('$apiUrl2/$userId?estado=false'),
      headers: {'Content-Type': 'application/json'},
    );
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Bienvenido a la sección de $title')),
    );
  }
}
