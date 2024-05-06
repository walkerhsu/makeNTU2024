import "package:flutter/material.dart";

// MyCardText

class MyMemoirImage extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String imageURL;
  final double titleFontSize;
  final double destFontSize;
  final Color color;
  final Color cardColor;
  final FontWeight titleFontWeight;
  final FontWeight destFontWeight;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  const MyMemoirImage({
    super.key,
    required this.imageURL,
    required this.title,
    this.width = 320,
    this.height = 150,
    this.titleFontSize = 24,
    this.destFontSize = 18,
    this.color = Colors.black,
    this.cardColor = const Color.fromARGB(255, 220, 220, 220),
    this.titleFontWeight = FontWeight.bold,
    this.destFontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.maxLines = 2,
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
                  Image.asset(
                    imageURL,
                    width: width * 0.4,
                    height: height * 0.8,
                  ),
                  SizedBox(
                    width: width * 0.1,
                  ),
                  SizedBox(
                    width: width * 0.4,
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: textAlign,
                          style: TextStyle(
                              fontSize: titleFontSize,
                              color: color,
                              fontWeight: titleFontWeight),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
    );
  }
}
