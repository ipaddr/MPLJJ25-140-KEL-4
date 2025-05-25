import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _nik = '';

  String get name => _name;
  String get nik => _nik;

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setNik(String newNik) {
    _nik = newNik;
    notifyListeners();
  }

  // Untuk set sekaligus
  void setUser({required String name, required String nik}) {
    _name = name;
    _nik = nik;
    notifyListeners();
  }
}