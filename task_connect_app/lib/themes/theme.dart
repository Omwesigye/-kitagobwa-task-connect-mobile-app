import 'package:flutter/material.dart';


class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(

useMaterial3: true,
fontFamily: 'Poppins',
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
   

  );
  
  static ThemeData darkTheme = ThemeData(
useMaterial3: true,
fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    
    
    

  );
  

  
}
