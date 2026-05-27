

import 'package:flutter/material.dart';

Future push(context, widget) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return widget;
      },
    ),
  );
}