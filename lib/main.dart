import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'models/userModel.dart';
import 'routes/login.dart';
import 'routes/home.dart';


FlutterLocalNotificationsPlugin notifications;

void main() {
  notifications = new FlutterLocalNotificationsPlugin();
  runApp(
    ChangeNotifierProvider(
      builder: (context) => UserModel(),
      child: CodedayApp(),
    ),
  );
}

class CodedayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFFCB7972),
          primaryColorDark: Color(0xFFAF6861),
          accentColor: Color(0xFFCB7972),
          brightness: Brightness.dark),
      home: FutureBuilder<Ticket>(
        future: Provider.of<UserModel>(context).getTicket(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.hasData ? HomePage() : LoginPage();
          } else {
            return Container(color: Theme.of(context).backgroundColor);
          }
        },
      ),
    );
  }
}
