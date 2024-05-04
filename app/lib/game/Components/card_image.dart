import "package:flutter/material.dart";

// MyCardText

class MyCardImage extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final String imageName;
  final bool isOnline;
  final double fontSize;
  final Color color;
  final Color cardColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  const MyCardImage({
    super.key,
    required this.text,
    required this.imageName,
    this.isOnline = true,
    this.width = 320,
    this.height = 150,
    this.fontSize = 12,
    this.color = Colors.black,
    this.cardColor = const Color.fromARGB(255, 220, 220, 220),
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.maxLines = 3,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: cardColor,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                isOnline
                    ? Image.network(
                        'http://10.10.2.97:8000/image/$imageName',
                        width: width * 0.4,
                        height: height * 0.8,
                      )
                    : Image.asset(
                        'assets/images/$imageName',
                        width: width * 0.4,
                        height: height * 0.8,
                      ),
                SizedBox(
                  width: width * 0.1,
                ),
                SizedBox(
                  width: width * 0.4,
                  child: Text(
                    text,
                    textAlign: textAlign,
                    maxLines: maxLines,
                    overflow: overflow, // Overflow behavior
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: color),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
