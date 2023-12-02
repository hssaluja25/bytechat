import 'package:flutter/foundation.dart';

class ChatProvider with ChangeNotifier {
  int _number = 0;
  int get number => _number;
  set number(int newVal) {
    _number = newVal;
    notifyListeners();
  }
}
