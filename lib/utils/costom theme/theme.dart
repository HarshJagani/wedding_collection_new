
import 'package:flutter/material.dart';
import 'package:wedding_collection_new/utils/costom%20theme/appbar_theme.dart';
import 'package:wedding_collection_new/utils/costom%20theme/bottom_sheet_theme.dart';
import 'package:wedding_collection_new/utils/costom%20theme/eleveted_button_theme.dart';
import 'package:wedding_collection_new/utils/costom%20theme/outlined_button_them.dart';
import 'package:wedding_collection_new/utils/costom%20theme/text_field_theme.dart';
import 'package:wedding_collection_new/utils/costom%20theme/text_theme.dart';

class ECTheme {
  ECTheme._();

  static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: ECTextTheme.lightTextTheme,
      appBarTheme: ECAppBarTheme.lightAppbarTheme,
      bottomSheetTheme: ECBottomSheetTheme.lightBottomSheetTheme,
      elevatedButtonTheme: ECElevatedButtonTheme.lightElevatedButtonTheme,
      inputDecorationTheme: ECTextFieldTheme.lightInputDecorationTheme,
      outlinedButtonTheme: ECOutlinedButtonTheme.lightOutlinedButtonTheme);
      
  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      textTheme: ECTextTheme.darkTextTheme,
      appBarTheme: ECAppBarTheme.darkAppbarTheme,
      bottomSheetTheme: ECBottomSheetTheme.darkBottomSheetTheme,
      elevatedButtonTheme: ECElevatedButtonTheme.darkElevatedButtonTheme,
      inputDecorationTheme: ECTextFieldTheme.darkInputDecorationTheme,
      outlinedButtonTheme: ECOutlinedButtonTheme.darkOutlinedButtonTheme);
}
