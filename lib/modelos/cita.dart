class Cita {
  late String titulo;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  late String userId;

  Cita({
    required this.titulo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Titulo': titulo,
      'FechaInicio': fechaInicio.toIso8601String(),
      'FechaFin': fechaFin.toIso8601String(),
      'UserId': userId,
    };
  }

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      titulo: json['Titulo'],
      fechaInicio: DateTime.parse(json['FechaInicio']),
      fechaFin: DateTime.parse(json['FechaFin']),
      userId: json['UserId'],
    );
  }
}







