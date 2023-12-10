// Contains all data related to user such as name, avatar and status.
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _status = '';
  String _avatar = '';
  bool _play = true;

  String get name => _name;
  String get status => _status;
  String get avatar => _avatar;
  bool get play => _play;

  set name(String newVal) {
    _name = newVal;
    notifyListeners();
  }

  set status(String newVal) {
    _status = newVal;
    notifyListeners();
  }

  set avatar(String newVal) {
    _avatar = newVal;
    notifyListeners();
  }

  set play(bool newVal) {
    _play = newVal;
    notifyListeners();
  }
}
