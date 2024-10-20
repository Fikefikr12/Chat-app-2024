import 'package:chatapp1/theme/light_mode.dart';
import 'package:flutter/material.dart';
import 'dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightmode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  void toggleTheme(){
    if (_themeData == lightmode){
      themeData =darkMode;
    }
    else{
      themeData=lightmode;
    }
  }
}
