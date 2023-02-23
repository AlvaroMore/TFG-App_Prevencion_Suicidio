import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class ajustes extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              AppSettings.openDeviceSettings();
            }, child: Text('Ajustes'))
          ],
        ),
      ),
    );
  }
}