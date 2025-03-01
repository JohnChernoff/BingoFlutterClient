import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {

  final String txt;
  final Color color;
  final double? width, height;
  final Color txtCol, borderCol;
  final double borderWidth, margin;

  const TextBox(this.txt, this.color, {super.key, this.width, this.height, this.txtCol = Colors.black, this.borderCol = Colors.white, this.borderWidth = 1, this.margin = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
          color: color,
          border: (borderWidth > 0) ? Border.all(color: borderCol, width: borderWidth) : null
      ),
      width: width, height: height,
      child: Center(child: Text(txt,style: TextStyle(color: txtCol))),
    );
  }

}
