import 'package:flutter/material.dart';
import 'package:freecodecamp_tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'An error occurred',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {'Cancel': false, 'Log out': true},
  ).then((value) => value ?? false);
}
