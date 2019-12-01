import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/userModel.dart';
import 'login.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        if (!user.loggedIn) {
          return Container();
        }
        var now = DateTime.now();
        var start = user.event.startsAt;
        int daysUntilCodeDay = DateTime(now.year, now.month, now.day)
            .difference(DateTime(start.year, start.month, start.day))
            .inDays;
        return ListView(
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Hey there, ${user.ticket.firstName}!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (user.dayOfTime == RelativeTime.before)
              FeedCard(
                  icon: Icons.hourglass_full,
                  title:
                      "There ${daysUntilCodeDay == 1 ? 'is' : 'are'} $daysUntilCodeDay day${daysUntilCodeDay == 1 ? '' : 's'} until CodeDay!"),
            if (user.dayOfTime == RelativeTime.after)
              FeedCard(
                icon: Icons.exit_to_app,
                title: "Need to sign out?",
                description:
                    "If you\'ve already registered for next season, you should sign out of the app and sign in with your new ticket.",
                buttons: <Widget>[
                  FlatButton(
                    child: Text('SIGN OUT'),
                    onPressed: () {
                      user.logOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  )
                ],
              ),
            if (user.exactTime == RelativeTime.after)
              FeedCard(
                icon: Icons.notifications_active,
                title: "CodeDay's over already‽",
                description:
                    "We know, we can\'t believe it either… 24 hours goes by surprisingly fast. You can be the first to know when we open registrations for next season\'s CodeDay by tapping the button below!",
                buttons: <Widget>[
                  FlatButton(
                    child: Text('GET NOTIFIED'),
                    onPressed: () {},
                  )
                ],
              ),
            if (user.exactTime == RelativeTime.before &&
                (!user.ticket.hasAge || !user.ticket.hasParent))
              FeedCard(
                icon: Icons.warning,
                title: "Reminder: More Info Needed",
                description:
                    "Please fill out your age and parent info now so you don\'t need to at the door. Thanks!",
                buttons: <Widget>[
                  FlatButton(
                    child: Text('FILL OUT INFO'),
                    onPressed: () {
                      launch("https://codeday.vip/${user.ticket.id}");
                    },
                  )
                ],
              ),
            if (user.exactTime == RelativeTime.before && !user.ticket.hasWaiver)
              FeedCard(
                icon: Icons.warning,
                title: "Reminder: One more step…",
                description:
                    "You (or your parent) will need to fill out the waiver before you can attend. Please do that now so you don\'t need to at the event, thanks!",
                buttons: <Widget>[
                  FlatButton(
                    child: Text('FILL OUT WAIVER'),
                    onPressed: () {
                      launch("https://codeday.vip/${user.ticket.id}/waiver");
                    },
                  )
                ],
              ),
          ],
        );
      },
    );
  }
}

class FeedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Widget> buttons;

  FeedCard({this.icon, this.title, this.description, this.buttons});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              leading: icon != null ? Icon(icon) : null,
              title: Text(title ?? "", style: TextStyle(fontSize: 24)),
              subtitle: Text(description ?? ""),
            ),
          ),
          if (buttons != null)
            ButtonTheme.bar(
              child: ButtonBar(
                children: buttons,
              ),
            ),
        ],
      ),
    );
  }
}
