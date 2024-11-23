import 'package:flutter/material.dart';

class ECBottomSheetTheme {
  ECBottomSheetTheme._();

  static final lightBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12))),
    constraints: const BoxConstraints(minWidth: double.infinity),
    modalBackgroundColor: Colors.white,
  );

  static final darkBottomSheetTheme = BottomSheetThemeData(
    
    backgroundColor: Colors.grey.shade800,
    showDragHandle: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    constraints: const BoxConstraints(minWidth: double.infinity),
    modalBackgroundColor: Colors.black,
  );
}
