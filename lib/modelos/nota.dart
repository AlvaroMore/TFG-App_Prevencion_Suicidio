import 'package:flutter/material.dart';

class Nota {
  String titulo;
  String contenido;
  DateTime fechaCreacion;

  Nota({
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
  });
}