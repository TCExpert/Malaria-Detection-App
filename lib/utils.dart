import 'package:flutter/material.dart';

class Utils {
  static Future<bool> showAlertDialog(BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
      style:
      ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      child: const Text("Cancel"),
    );
    Widget continueButton = ElevatedButton(
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
      style:
      ButtonStyle(foregroundColor: WidgetStateProperty.all(Colors.white)),
      child: const Text("Yes"),
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(message),
      titleTextStyle: const TextStyle(fontSize: 15, color: Color(0xFFBC764A)),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }
}