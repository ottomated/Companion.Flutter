import 'package:companion/models/userModel.dart';
import 'package:companion/routes/self_check_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

String titleCase(String a) {
  return a[0].toUpperCase() + a.substring(1).toLowerCase();
}

class _CheckInPageState extends State<CheckInPage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * .75;
    return Consumer<UserModel>(
      builder: (context, user, child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "${user.ticket.firstName}'s Ticket",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          Container(
            width: width,
            height: width,
            child: Theme(
              data: ThemeData(
                brightness: Brightness.light,
                textTheme: TextTheme(
                  body1: TextStyle(fontSize: 18),
                ),
              ),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('ADMIT ONE'),
                    ),
                    QrImage(
                      data: user.ticket.id,
                      version: QrVersions.auto,
                      size: width * 2 / 3,
                    ),
                    Text(titleCase(user.ticket.type)),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(user.event.name),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: RaisedButton(
              child: Text('SELF CHECK-IN'),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SelfCheckInPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
