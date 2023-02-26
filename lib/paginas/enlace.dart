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
        alignment: Alignment.center,
        padding: EdgeInsets.all(32),
        child: ElevatedButton(
          child: Text('Enlace URL'),
          onPressed: () async {
            final url = 'https://www.fsme.es';
            // ignore: deprecated_member_use
            await launch(url);
              
            
          },
        ),
      ),
    );
  }
}