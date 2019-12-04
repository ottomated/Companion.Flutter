import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/userModel.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        if (!user.loggedIn) {
          return Container();
        }
        List<Widget> items = [];
        for (String day in user.event.schedule.keys) {
          items.add(
            Padding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Row(
                children: <Widget>[
                  Text(day),
                  Expanded(child: Divider()),
                ],
              ),
            ),
          );
          for (var card in user.event.schedule[day]) {
            items.add(
              ScheduleCard(card),
            );
          }
        }
        return ListView(
          children: items,
        );
      },
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final ScheduleEntry card;

  ScheduleCard(this.card);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicHeight(
        child: InkWell(
          onTap: card.url == null
              ? null
              : () {
                  launch(card.url);
                },
          onLongPress: () async {
            var scheduledNotificationDateTime =
                new DateTime.now().add(new Duration(seconds: 5));
            var androidPlatformChannelSpecifics =
                new AndroidNotificationDetails(
                    'your other channel id',
                    'your other channel name',
                    'your other channel description');
            var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
            NotificationDetails platformChannelSpecifics =
                new NotificationDetails(androidPlatformChannelSpecifics,
                    iOSPlatformChannelSpecifics);
            await notifications.schedule(
                0,
                'scheduled title',
                'scheduled body',
                scheduledNotificationDateTime,
                platformChannelSpecifics);
          },
          child: Row(
            children: <Widget>[
              Container(
                width: 10,
                decoration: BoxDecoration(
                  color: card.type == 'event'
                      ? Theme.of(context).primaryColor
                      : Color(0xFF80C2DA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(card.hour),
                ),
                width: 60,
              ),
              Container(
                width: 1,
                color: Colors.grey[900],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(card.title),
                      if (card.description != null)
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            card.description,
                            style: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (card.url != null)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.attachment),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
