import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum RelativeTime { before, after, during }

class UserModel extends ChangeNotifier {
  Ticket _ticket;

  Ticket get ticket => _ticket;
  Event get event => _ticket?.event;
  bool get loggedIn => _ticket != null;

  RelativeTime _getRelativeTime(now, start, end) {
    if (now.isBefore(start)) {
      return RelativeTime.before;
    } else if (now.isAfter(end)) {
      return RelativeTime.after;
    } else {
      return RelativeTime.during;
    }
  }

  RelativeTime get exactTime {
    return _getRelativeTime(DateTime.now(), event.startsAt, event.endsAt);
  }

  RelativeTime get approxTime {
    return _getRelativeTime(
      DateTime.now(),
      event.startsAt.subtract(Duration(hours: 2)),
      event.endsAt.add(Duration(hours: 2)),
    );
  }

  RelativeTime get dayOfTime {
    var start = event.startsAt;
    var end = event.endsAt;
    return _getRelativeTime(
      DateTime.now(),
      DateTime(start.year, start.month, start.day),
      DateTime(end.year, end.month, end.day).add(Duration(days: 1)),
    );
  }

  Future<Ticket> getTicket() async {
    if (_ticket != null)
      return _ticket;
    else {
      var prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('email')) {
        return await logIn(prefs.getString('email'));
      } else {
        return null;
      }
    }
  }

  Future<Ticket> logIn(String email) async {
    try {
      final res = await http.get(
        "https://app.codeday.vip/api/login?email=${Uri.encodeQueryComponent(email)}",
      );
      var prefs = await SharedPreferences.getInstance();
      var body = json.decode(res.body);
      if (!body['ok']) return null;
      _ticket = Ticket.fromJson(body['registration']);
      if (_ticket == null) return null;
      await prefs.setString('email', _ticket.email);
      notifyListeners();
      return _ticket;
    } catch (e, trace) {
      print(e);
      print(trace);
      return null;
    }
  }

  Future<Ticket> logInWithTicket(String code) async {
    try {
      final res = await http.get(
        "https://app.codeday.vip/api/ticket/${Uri.encodeQueryComponent(code)}",
      );
      var prefs = await SharedPreferences.getInstance();
      _ticket = Ticket.fromJson(json.decode(res.body));
      if (_ticket == null) return null;
      await prefs.setString('email', _ticket.email);
      notifyListeners();
      return _ticket;
    } catch (e, trace) {
      print(e);
      print(trace);
      return null;
    }
  }

  logOut() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    _ticket = null;
    notifyListeners();
  }

  set ticket(Ticket t) {
    _ticket = t;
    notifyListeners();
  }
}

class Event {
  String id;
  String region;
  String regionId;
  String name;
  DateTime startsAt;
  DateTime endsAt;
  Map<String, List<ScheduleEntry>> schedule;
  Venue venue;

  Event({
    this.id,
    this.region,
    this.regionId,
    this.name,
    this.startsAt,
    this.endsAt,
    this.schedule,
    this.venue,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      region: json['region'],
      regionId: json['region_id'],
      name: json['name'],
      startsAt: DateTime.fromMillisecondsSinceEpoch(json['starts_at']),
      endsAt: DateTime.fromMillisecondsSinceEpoch(json['ends_at']),
      schedule: Map<String, List<ScheduleEntry>>.from(
        json['schedule'].map(
          (key, list) => MapEntry(
            key,
            list
                .map((json) => ScheduleEntry.fromJson(json))
                .toList()
                .cast<ScheduleEntry>(),
          ),
        ),
      ),
      venue: Venue.fromJson(json['venue']),
    );
  }
}

class ScheduleEntry {
  double relativeTime;
  DateTime timestamp;
  String title;
  String type;
  String description;
  String hour;
  String day;
  String url;

  ScheduleEntry({
    this.relativeTime,
    this.timestamp,
    this.title,
    this.type,
    this.description,
    this.day,
    this.hour,
    this.url,
  });
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      relativeTime: (json['time'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']['date']),
      title: json['title'],
      type: json['type'],
      description: json['description'],
      day: json['day'],
      hour: json['hour'],
      url: json['url'],
    );
  }
}

class Venue {
  String name;
  String address;

  Venue({
    this.name,
    this.address,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      name: json['name'],
      address: json['full_address'],
    );
  }
}

class Ticket {
  Map<String, dynamic> json;
  String id;
  String name;
  String firstName;
  String lastName;
  String email;
  String profileImage;
  String type;
  DateTime checkedInAt;
  bool hasAge;
  bool hasParent;
  bool hasWaiver;
  Event event;

  Ticket({
    this.json,
    this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImage,
    this.type,
    this.checkedInAt,
    this.hasAge,
    this.hasParent,
    this.hasWaiver,
    this.event,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    print(json);
    if (json['ok']) {
      return Ticket(
        json: json,
        id: json['id'],
        name: json['name'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        profileImage: json['profile_image'],
        type: json['type'],
        checkedInAt: DateTime.parse(json['checked_in_at']['date']),
        hasAge: json['has_age'],
        hasParent: json['has_parent'],
        hasWaiver: json['has_waiver'],
        event: Event.fromJson(json['event']),
      );
    } else {
      return null;
    }
  }
}
