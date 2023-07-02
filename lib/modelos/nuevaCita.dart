import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo/modelos/cita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class NuevaCita extends StatefulWidget {
  final int? citaIndex;
  final List<Appointment> appointments;

  NuevaCita({this.citaIndex, required this.appointments});

  @override
  NuevaCitaState createState() => NuevaCitaState();
}

class NuevaCitaState extends State<NuevaCita> {
  final _database = FirebaseDatabase.instance;
  final TextEditingController tituloController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final baseDatos = FirebaseDatabase.instance;
  // ignore: prefer_typing_uninitialized_variables
  var userRole;
  bool showUserDropdown = false;
  late DateTime fechaInicio;
  late DateTime fechaFin;
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  DateFormat timeFormat = DateFormat('HH:mm');
  List<String> usersList = [];
  String selectedUser = '';

  @override
  void initState() {
    super.initState();
    if (widget.citaIndex != null) {
      Appointment appointment = widget.appointments[widget.citaIndex!];
      fechaInicio = appointment.startTime;
      fechaFin = appointment.endTime;
      tituloController.text = appointment.subject;
    } else {
      fechaInicio = DateTime.now();
      fechaFin = DateTime.now();
    }
    DatabaseReference usersRef = _database.reference().child('users');
      usersRef.once().then((DatabaseEvent snapshot) {
        Map<dynamic, dynamic> usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        print(usersMap);
        if (usersMap != null) {
          usersList = usersMap.entries.map((e) => e.value['usuario']).toSet().toList().cast<String>();
          setState(() {
            selectedUser = usersList.isNotEmpty ? usersList[0] : '';
          });
        }
      });
      fetchUserRole();
  }

  Future<String> getUserRole(String userId) async {
    final userRoleRef = baseDatos.reference().child('users/$userId/rol');
    DatabaseEvent snapshot = await userRoleRef.once();
    var snapshotValue = snapshot.snapshot.value;
    return (snapshotValue as String?) ?? '';
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String role = await getUserRole(user.uid);
      setState(() {
        userRole = role;
        showUserDropdown = (userRole == 'administrador');
      });
    }
  }

  void guardarCita() {
    String titulo = tituloController.text.trim();
    Appointment appointment = Appointment(
      startTime: fechaInicio,
      endTime: fechaFin,
      subject: titulo,
      color: Colors.blue,
    );

    var rng = Random();
    var key_ = rng.nextInt(10000).toString();

    if (widget.citaIndex != null) {
      Appointment citaPulsada = widget.appointments[widget.citaIndex!];
      DatabaseReference citaOriginal = _database.reference().child('citas/${citaPulsada.id}');
      citaOriginal.remove();

      DatabaseReference citaEditada = _database.reference().child('citas/$key_');
      citaEditada.set({
        "Titulo": appointment.subject,
        "FechaInicio": appointment.startTime.toString(),
        "FechaFin": appointment.endTime.toString(),
        "UserId": user?.uid ?? '',
        "NombreUsuario": selectedUser,
      }).asStream();
      citaPulsada.subject = appointment.subject;
      citaPulsada.startTime = appointment.startTime;
      citaPulsada.endTime = appointment.endTime;
    } else {
      DatabaseReference datosRef = _database.reference().child('citas/$key_');
      datosRef.set({
        "Titulo": appointment.subject,
        "FechaInicio": appointment.startTime.toString(),
        "FechaFin": appointment.endTime.toString(),
        "UserId": user?.uid ?? '',
        "NombreUsuario": selectedUser,
      }).asStream();
      widget.appointments.add(appointment);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.citaIndex != null ? 'Editar Cita' : 'Nueva Cita'),
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
                        initialTime: TimeOfDay.fromDateTime(fechaInicio),
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
                        initialTime: TimeOfDay.fromDateTime(fechaFin),
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
            Center(
              child: showUserDropdown
                  ? DropdownButton<String>(
                      value: selectedUser,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUser = newValue!;
                        });
                      },
                      items: usersList.map((String user) {
                        return DropdownMenuItem<String>(
                          value: user,
                          child: Text(user),
                        );
                      }).toList(),
                      hint: Text('Seleccione un usuario'),
                    )
                  : SizedBox(),
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



