import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:appbu_s/modelos/cita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
  String? adminToken;

  @override
  void initState() {
    super.initState();
    fetchAdminToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String? title = message.notification!.title;
    String? body = message.notification!.body;
    });
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

  Future<void> fetchAdminToken() async {
    final usersRef = baseDatos.reference().child('users');
    final DatabaseEvent dataSnapshot = await usersRef.once();
    
    final usuarios = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

    String? adminUserId;
    
    // Buscar el usuario con el rol de administrador
    usuarios.forEach((userId, userData) {
      final rol = userData['rol'] as String?;
      if (rol == 'administrador') {
        adminUserId = userId;
        return;
      }
    });

    if (adminUserId != null) {
      final adminTokenRef = baseDatos.reference().child('users/$adminUserId/token');
      final DatabaseEvent tokenSnapshot = await adminTokenRef.once();
      adminToken = tokenSnapshot.snapshot.value as String?;
    }

    setState(() {});
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
    sendPushNotification();
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                hintText: 'Titulo',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
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
                    fechaFin = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      fechaFin.hour,
                      fechaFin.minute,
                    );
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
            SizedBox(height: 16.0),
            Row(
              children: [
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
            showUserDropdown
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: (){
                guardarCita();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendPushNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAwExjmR0:APA91bGDItwHFI6kNHxmcHM9cCrUwcEhKnjWOCYhllfHXiUZY-RklTRMr-ieHciAKvWiRoephqgNGtCaOwSQ896IZJOj2wce-_IM9oDSApNg6Xx_3f1hV8sIrj7aiTtprwX4VVVSIn6R',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Se ha creado una nueva cita",
              'title': 'Nueva cita',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': await getUserToken(selectedUser),
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }

  Future<String> getUserToken(String? selectedUser) async {
    if (userRole == 'administrador') {
      // Fetch the selected user's token from the database based on the selectedUser
      DatabaseReference userRef = _database.reference().child('users');
      DatabaseEvent snapshot = await userRef.orderByChild('usuario').equalTo(selectedUser).once();
      Map<dynamic, dynamic> userData = snapshot.snapshot.value as Map<dynamic, dynamic>;
      if (userData != null && userData.isNotEmpty) {
        String userId = userData.keys.first.toString();
        String userToken = userData[userId]['token'];
        return userToken;
      }
    } else {
      // Return the admin's token
      return adminToken ?? '';
    }
    return '';
  }
}




