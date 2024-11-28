import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class BitacorasScreen extends StatefulWidget {
  @override
  _BitacorasScreenState createState() => _BitacorasScreenState();
}

class _BitacorasScreenState extends State<BitacorasScreen> {
  List<Map<String, dynamic>> bitacoras = [];
  bool _isLoading = true;

  final String apiUrlBitacoras = 'https://symmetrical-funicular-mb61.onrender.com/bitacora/';
  final String apiUrlUsuarios = 'https://symmetrical-funicular-mb61.onrender.com/usuarios/';
  final String apiUrlVehiculos = 'https://symmetrical-funicular-mb61.onrender.com/vehiculos/';
  final String apiUrlGasolineras = 'https://symmetrical-funicular-mb61.onrender.com/gasolineras/';
  final String apiUrlProyectos = 'https://symmetrical-funicular-mb61.onrender.com/proyecto/';

  @override
  void initState() {
    super.initState();
    _fetchBitacoras();
  }

  Future<void> _fetchBitacoras() async {
    try {
      final response = await http.get(Uri.parse(apiUrlBitacoras));
      if (response.statusCode == 200) {
        setState(() {
          bitacoras = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        _showError('Error al obtener bitácoras');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchDetalles(int idUsr, int idVehiculo, int idGasolinera, int idProyecto) async {
    try {
      final usuarioResponse = await http.get(Uri.parse('$apiUrlUsuarios$idUsr'));
      final vehiculoResponse = await http.get(Uri.parse('$apiUrlVehiculos$idVehiculo'));
      final gasolineraResponse = await http.get(Uri.parse('$apiUrlGasolineras$idGasolinera'));
      final proyectoResponse = await http.get(Uri.parse('$apiUrlProyectos$idProyecto'));

      if (usuarioResponse.statusCode == 200 && vehiculoResponse.statusCode == 200 && gasolineraResponse.statusCode == 200 && proyectoResponse.statusCode == 200) {
        return {
          'usuario': json.decode(usuarioResponse.body),
          'vehiculo': json.decode(vehiculoResponse.body),
          'gasolinera': json.decode(gasolineraResponse.body),
          'proyecto': json.decode(proyectoResponse.body),
        };
      } else {
        throw Exception('Error al obtener detalles');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

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

  void _showBitacoraDetails(Map<String, dynamic> bitacora) async {
    try {
      final detalles = await _fetchDetalles(
        bitacora['id_usr'],
        bitacora['id_vehiculo'],
        bitacora['id_gasolinera'],
        bitacora['id_proyecto'],
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Detalles de Bitácora', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comentario: ${bitacora['comentario']}'),
                  Text('Kilómetros Iniciales: ${bitacora['km_inicial']}'),
                  Text('Kilómetros Finales: ${bitacora['km_final']}'),
                  Text('Número de Galones: ${bitacora['num_galones']}'),
                  Text('Costo: ${bitacora['costo']}'),
                  Text('Tipo de Gasolina: ${bitacora['tipo_gasolina']}'),
                  Text('Usuario: ${detalles['usuario']['nombre']}'),
                  Text('Vehículo: ${detalles['vehiculo']['modelo']} (${detalles['vehiculo']['placa']})'),
                  Text('Gasolinera: ${detalles['gasolinera']['nombre']}'),
                  Text('Proyecto: ${detalles['proyecto']['nombre']}'),
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
    } catch (e) {
      _showError('No se pudieron obtener los detalles: $e');
    }
  }

  Future<void> _generateReport() async {
    try {
      final pdf = pw.Document();
      final excel = Excel.createExcel();
      final sheet = excel['Bitacoras'];

      final headers = [
        'Usuario',
        'Kilómetros\nIniciales',
        'Kilómetros\nFinales',
        'Número de\nGalones',
        'Costo',
        'Tipo de\nGasolina',
        'Vehículo',
        'Gasolinera',
        'Proyecto',
      ];

      sheet.appendRow(headers);

      final pdfRows = <List<String>>[headers];

      for (var bitacora in bitacoras) {
        final detalles = await _fetchDetalles(
          bitacora['id_usr'],
          bitacora['id_vehiculo'],
          bitacora['id_gasolinera'],
          bitacora['id_proyecto'],
        );

        final row = [
          detalles['usuario']['nombre'],
          bitacora['km_inicial'].toString(),
          bitacora['km_final'].toString(),
          bitacora['num_galones'].toString(),
          bitacora['costo'].toString(),
          bitacora['tipo_gasolina'],
          detalles['vehiculo']['modelo'],
          detalles['gasolinera']['nombre'],
          detalles['proyecto']['nombre'],
        ];

        sheet.appendRow(row);
        pdfRows.add(row.map((e) => e.toString()).toList());
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Table.fromTextArray(
              headers: headers,
              data: pdfRows.sublist(1),
              cellStyle: pw.TextStyle(fontSize: 10),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              border: pw.TableBorder.all(),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final pdfBlob = html.Blob([pdfBytes], 'application/pdf');
      final pdfUrl = html.Url.createObjectUrlFromBlob(pdfBlob);
      final pdfAnchor = html.AnchorElement(href: pdfUrl)
        ..target = '_blank'
        ..download = 'bitacoras.pdf'
        ..click();
      html.Url.revokeObjectUrl(pdfUrl);

      final excelBytes = excel.encode()!;
      final excelBlob = html.Blob([excelBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final excelUrl = html.Url.createObjectUrlFromBlob(excelBlob);
      final excelAnchor = html.AnchorElement(href: excelUrl)
        ..target = '_blank'
        ..download = 'bitacoras.xlsx'
        ..click();
      html.Url.revokeObjectUrl(excelUrl);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reportes generados y descargados.'),
      ));
    } catch (e) {
      _showError('Error al generar reportes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitácoras'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: bitacoras.length,
        itemBuilder: (context, index) {
          final bitacora = bitacoras[index];
          return FutureBuilder(
            future: _fetchDetalles(
              bitacora['id_usr'],
              bitacora['id_vehiculo'],
              bitacora['id_gasolinera'],
              bitacora['id_proyecto'],
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text('Cargando...'),
                  subtitle: Text('Cargando detalles de la bitácora...'),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text('Error: ${snapshot.error}'),
                );
              } else {
                var detalles = snapshot.data as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Bitácora de ${detalles['usuario']['nombre']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Km Inicial: ${bitacora['km_inicial']} | Km Final: ${bitacora['km_final']}'),
                    onTap: () => _showBitacoraDetails(bitacora),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
