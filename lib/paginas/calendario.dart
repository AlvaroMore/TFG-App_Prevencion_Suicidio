import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo/modelos/nuevaCita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:demo/modelos/cita.dart';
import 'dart:async';

class Calendario extends StatefulWidget {
  @override
  CalendarioState createState() => CalendarioState();
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  String citaId(int index) {
    return appointments![index].id;
  }

  void actualizarCita(List<Appointment> updatedAppointments) {
    appointments = updatedAppointments;
    notifyListeners(CalendarDataSourceAction.reset, []);
  }
}

class CalendarioState extends State<Calendario> {
  List<Appointment> appointments = <Appointment>[];
  final baseDatos = FirebaseDatabase.instance;
  bool datosCargados = false;
  String? citaSeleccionadaId;
  // ignore: prefer_typing_uninitialized_variables
  var userRole;

  @override
  void initState() {
    super.initState();
    if (!datosCargados) {
      fetchUserRoleAndCargaCitas();
      datosCargados = true;
    }
  }

  void fetchUserRoleAndCargaCitas() async {
    await fetchUserRole();
    cargaCitas();
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
      });
    }
  }

  Future<String?> fetchUserIdFromNombreUsuario(String nombreUsuario) async {
    final usuariosRef = baseDatos.reference().child('users');
    DatabaseEvent dataSnapshot = await usuariosRef.orderByChild('usuario').equalTo(nombreUsuario).limitToFirst(1).once();
    Map<dynamic, dynamic> usersData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

    if (usersData != null) {
      String userId = usersData.keys.first as String;
      return userId;
    }

    return null;
  }

  void cargaCitas() {
    final citas = baseDatos.reference().child('citas');
    citas.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;
      Map<dynamic, dynamic>? citasData = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (citasData != null) {
        citasData.forEach((key, value) {
          String? id = key;
          String titulo = value['Titulo'];
          String userId = value['UserId'];
          String fechaInicio = value['FechaInicio'];
          String fechaFin = value['FechaFin'];
          String nombreUsuario = value['NombreUsuario'];
          DateTime startTime = DateTime.parse(fechaInicio);
          DateTime endTime = DateTime.parse(fechaFin);

          // Fetch the user ID based on the NombreUsuario
          fetchUserIdFromNombreUsuario(nombreUsuario).then((selectedUserId) {
            if (selectedUserId != null && (userRole == "administrador" || userId == FirebaseAuth.instance.currentUser?.uid || selectedUserId == FirebaseAuth.instance.currentUser?.uid)) {
              bool isDuplicate = appointments.any((appointment) {
                return appointment.subject == titulo &&
                    appointment.startTime == startTime &&
                    appointment.endTime == endTime;
              });

              if (!isDuplicate) {
                // Display the appointment if it's either for the selected user, the administrator, or the creator of the appointment
                appointments.add(Appointment(
                  id: id,
                  startTime: startTime,
                  endTime: endTime,
                  subject: titulo,
                  color: Colors.blue,
                ));
                DataSource dataSource = DataSource(appointments);
                dataSource.actualizarCita(appointments);
                setState(() {});
              }
            }
          });
        });
      }
    });
    citas.onChildRemoved.listen((event) {
      String? id = event.snapshot.key;
      appointments.removeWhere((appointment) => appointment.id == id);
      DataSource dataSource = DataSource(appointments);
      dataSource.actualizarCita(appointments);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        initialDisplayDate: DateTime(2023, 6, 1),
        dataSource: listaCitas(),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            DateTime diaPulsado = details.date!;
            List<Appointment> citaPulsada = citasFecha(diaPulsado);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(formatoFecha(diaPulsado)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: mostrarCitas(context, citaPulsada),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          } else if (details.targetElement == CalendarElement.appointment) {
            Appointment appointment = details.appointments![0];
            citaSeleccionadaId = appointment.id as String?;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NuevaCita(
                  appointments: appointments,
                  citaIndex: appointments.indexOf(appointment),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NuevaCita(appointments: appointments),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String formatoFecha(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  String formatoFechaTiempo(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  DataSource listaCitas() {
    return DataSource(appointments);
  }

  List<Appointment> citasFecha(DateTime date) {
    return appointments.where((appointment) {
      DateTime appointmentStartDate = appointment.startTime;
      DateTime appointmentEndDate = appointment.endTime;
      DateTime startDate = DateTime(appointmentStartDate.year, appointmentStartDate.month, appointmentStartDate.day);
      DateTime endDate = DateTime(appointmentEndDate.year, appointmentEndDate.month, appointmentEndDate.day);

      if (startDate == endDate) {
        return date.year == startDate.year && date.month == startDate.month && date.day == startDate.day;
      } else {
        return date.isAfter(startDate.subtract(Duration(days: 1))) && date.isBefore(endDate.add(Duration(days: 1)));
      }
    }).toList();
  }

  List<Widget> mostrarCitas(BuildContext context, List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return [Text('No hay citas')];
    } else {
      return appointments.map((appointment) {
        return GestureDetector(
          onTap: () {
            citaSeleccionadaId = appointment.id as String?;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NuevaCita(
                  appointments: appointments,
                  citaIndex: appointments.indexOf(appointment),
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16.0),
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[300],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Titulo: ${appointment.subject}'),
                      Text('Inicio: ${formatoFechaTiempo(appointment.startTime)}'),
                      Text('Fin: ${formatoFechaTiempo(appointment.endTime)}'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    eliminarCita(appointment.id! as String);
                    appointments.remove(appointment);
                    setState(() {});
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      }).toList();
    }
  }

  void eliminarCita(dynamic appointmentId) {
    baseDatos.reference().child('citas').child(appointmentId).remove();
  }
}









