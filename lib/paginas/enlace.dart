import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class enlace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Links a Internet'),
      ),
      body: Container(
        padding: const EdgeInsets.only(
          top: 75,
          bottom: 10,
          left: 10,
          right: 10
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: ElevatedButton(
                        child: Text('FSME'),
                        //Text('Enlace URL')
                        onPressed: () async {
                        final url = 'https://www.fsme.es';
                        // ignore: deprecated_member_use
                        await launch(url);
                        },
                      ),
                    )
                  ],
                ),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: ElevatedButton(
                        child: Text('HUBU'),
                        //Text('Enlace URL')
                        onPressed: () async {
                        final url = 'https://www.saludcastillayleon.es/CABurgos/es/complejo-hospitalario-burgos/hospital-divino-valles/acceso-servicios/psiquiatria';
                        // ignore: deprecated_member_use
                        await launch(url);
                        },
                      ),
                    )
                  ],
                ),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: 75)
                  ],
                ),
              ],
            ),
            
          ],
        ),
        ),
      );
  }
}







