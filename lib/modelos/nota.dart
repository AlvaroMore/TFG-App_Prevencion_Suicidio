import 'package:flutter/material.dart';

class Nota {
  String titulo;
  String contenido;
  DateTime fechaCreacion;
  String userId; // Nuevo atributo userId

  Nota({
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
    required this.userId, // Incluye el userId en el constructor
  });
}

