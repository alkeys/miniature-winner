class Bitacora {
  final int id;
  final String comentario;
  final int kmInicial;
  final int kmFinal;
  final double numGalones;
  final double costo;
  final String tipoGasolina;
  final int idUsr;
  final int idVehiculo;
  final int idGasolinera;
  final int idProyecto;

  Bitacora({
    required this.id,
    required this.comentario,
    required this.kmInicial,
    required this.kmFinal,
    required this.numGalones,
    required this.costo,
    required this.tipoGasolina,
    required this.idUsr,
    required this.idVehiculo,
    required this.idGasolinera,
    required this.idProyecto,
  });

  factory Bitacora.fromJson(Map<String, dynamic> json) {
    return Bitacora(
      id: json['id_bitacora'],
      comentario: json['comentario'],
      kmInicial: json['km_inicial'],
      kmFinal: json['km_final'],
      numGalones: json['num_galones'],
      costo: json['costo'],
      tipoGasolina: json['tipo_gasolina'],
      idUsr: json['id_usr'],
      idVehiculo: json['id_vehiculo'],
      idGasolinera: json['id_gasolinera'],
      idProyecto: json['id_proyecto'],
    );
  }

  get userId => 3;

  Map<String, dynamic> toJson() {
    return {
      'comentario': comentario,
      'km_inicial': kmInicial,
      'km_final': kmFinal,
      'num_galones': numGalones,
      'costo': costo,
      'tipo_gasolina': tipoGasolina,
      'id_usr': idUsr,
      'id_vehiculo': idVehiculo,
      'id_gasolinera': idGasolinera,
      'id_proyecto': idProyecto,
    };
  }
}
