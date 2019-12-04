import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'check_in.dart';
import 'feed.dart';
import 'schedule.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 2;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: _tabIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CodeDay Companion'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
        children: <Widget>[
          FeedPage(),
          SchedulePage(),
          CheckInPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text("Dashboard"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            title: Text("Schedule"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            title: Text("Check-in"),
          ),
        ],
      ),
    );
  }
}
