import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.title, this.color, @required this.onPressed});

  final String title;
  final Color color;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        onPressed: () {
          //Go to login screen.
          onPressed();
        },
        minWidth: 200.0,
        height: 42.0,
        textColor: Colors.white,
        child: Text(
          title,
        ),
      ),
    );
  }
}
