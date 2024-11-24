import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importar url_launcher

class WelcomeScreen extends StatelessWidget {
  // Método para abrir un enlace en el navegador
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A), // Púrpura oscuro
              Color(0xFF9C27B0), // Púrpura medio
              Color(0xFFEDE7F6), // Púrpura claro
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bienvenido a",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Gojo Company",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login'); // Redirige a la pantalla de inicio
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 3,
                    ),
                    child: Text(
                      "Iniciar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Desarrollado por:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildContributorCard(
                    context,
                    name: "Alexander Aviles",
                    githubUrl: "https://github.com/alkeys",
                    icon: Icons.person,
                  ),
                  _buildContributorCard(
                    context,
                    name: "Gabriela Martínez",
                    githubUrl: "https://github.com/Gabym03",
                    icon: Icons.favorite,
                  ),
                  _buildContributorCard(
                    context,
                    name: "Gochez",
                    githubUrl: "https://github.com/Gochezzz",
                    icon: Icons.code,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para cada contribuidor con su tarjeta
  Widget _buildContributorCard(BuildContext context, {required String name, required String githubUrl, required IconData icon}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF6A1B9A),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  Text(
                    "GitHub",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _launchURL(githubUrl),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                backgroundColor: Color(0xFF6A1B9A).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Abrir",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
