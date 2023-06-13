import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo/modelos/nuevaCita.dart';
import 'package:intl/intl.dart';

class Calendario extends StatefulWidget {
  @override
  CalendarioState createState() => CalendarioState();
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

class CalendarioState extends State<Calendario> {
  List<Appointment> appointment= <Appointment>[];
  final DatabaseReference baseDatos = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    cargaCitas();
  }

  void cargaCitas() {
    final citas = baseDatos.child('citas');

    citas.onChildAdded.listen((event) {
      Map<dynamic, dynamic> value = event.snapshot.value as Map<dynamic, dynamic>;

      if (value != null) {
        String titulo = value['Titulo'];
        String userId = value['UserId'];
        String fechaInicio = value['FechaInicio'];
        String fechaFin = value['FechaFin'];
        DateTime startTime = DateTime.parse(fechaInicio);
        DateTime endTime = DateTime.parse(fechaFin);
        appointment.add(Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: titulo,
          color: Colors.blue,
        ));
        setState(() {});
      }
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
            DateTime tappedDate = details.date!;
            List<Appointment> tappedAppointments = citasFecha(tappedDate);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(formatoFecha(tappedDate)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: mostrarCitas(tappedAppointments),
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
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NuevaCita()),
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
    return DataSource(appointment);
  }

  List<Appointment> citasFecha(DateTime date) {
    return appointment.where((appointment) {
      DateTime appointmentStartDate = appointment.startTime;
      DateTime appointmentEndDate = appointment.endTime;
      
      // Check if the date falls within the appointment period
      return date.isAfter(appointmentStartDate.subtract(Duration(days: 1))) &&
          date.isBefore(appointmentEndDate.add(Duration(days: 1)));
    }).toList();
  }

  List<Widget> mostrarCitas(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return [Text('No hay citas')];
    } else {
      return appointments.map((appointment) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titulo: ${appointment.subject}'),
            Text('Inicio: ${formatoFechaTiempo(appointment.startTime)}'),
            Text('Fin: ${formatoFechaTiempo(appointment.endTime)}'),
            SizedBox(height: 16),
          ],
        );
      }).toList();
    }
  }

}






