class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String username;
  final bool activo;
  final int idRol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.username,
    required this.activo,
    required this.idRol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_usr'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      username: json['username'],
      activo: json['activo'],
      idRol: json['id_rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'username': username,
      'activo': activo,
      'id_rol': idRol,
    };
  }
}
