import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo/modelos/cita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NuevaCita extends StatefulWidget {
  @override
  NuevaCitaState createState() => NuevaCitaState();
}

class NuevaCitaState extends State<NuevaCita> {
  final _database = FirebaseDatabase.instance;
  final TextEditingController tituloController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  DateTime fechaInicio = DateTime.now();
  DateTime fechaFin = DateTime.now();
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');

  void guardarCita() {
    String titulo = tituloController.text.trim();
    Cita cita = Cita(
      titulo: titulo,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      userId: user?.uid ?? '',
    );
    
    var rng = Random();
    var key_ = rng.nextInt(10000);
    final datosRef = _database.reference().child('citas/$key_');

    datosRef.set({
      "Titulo": cita.titulo,
      "FechaInicio": cita.fechaInicio.toString(),
      "FechaFin": cita.fechaFin.toString(),
      "UserId": cita.userId,
    }).asStream();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Cita'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                hintText: 'Titulo',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          fechaInicio = pickedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Fecha Inicio',
                    ),
                    controller: TextEditingController(
                      text: fechaInicio != null ? dateFormat.format(fechaInicio) : '',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          fechaInicio = DateTime(
                            fechaInicio.year,
                            fechaInicio.month,
                            fechaInicio.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Hora de Inicio',
                    ),
                    controller: TextEditingController(
                      text: fechaInicio != null ? timeFormat.format(fechaInicio) : '',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          fechaFin = pickedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Fecha Fin',
                    ),
                    controller: TextEditingController(
                      text: fechaFin != null ? dateFormat.format(fechaFin) : '',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          fechaFin = DateTime(
                            fechaFin.year,
                            fechaFin.month,
                            fechaFin.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Hora de Fin',
                    ),
                    controller: TextEditingController(
                      text: fechaFin != null ? timeFormat.format(fechaFin) : '',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: guardarCita,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}


