import "package:flutter/material.dart";

// MyCardText

class MyCardText extends StatelessWidget {
  final double width;
  final String text;
  final double fontSize;
  final Color color;
  final Color cardColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  const MyCardText({
    super.key,
    required this.text,
    this.width = 320,
    this.fontSize = 12,
    this.color = Colors.black,
    this.cardColor = Colors.white,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow, // Overflow behavior
            style: TextStyle(
                fontSize: fontSize, fontWeight: fontWeight, color: color),
          ),
        ),
      ),
    );
  }
}
