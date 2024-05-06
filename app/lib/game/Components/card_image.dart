import "package:flutter/material.dart";
import "package:rpg_game/game/fetch_request.dart";

// MyCardText

class MyCardImage extends StatefulWidget {
  final double width;
  final double height;
  final String imageName;
  final String text;
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
    required this.imageName,
    this.text = "",
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
  State<MyCardImage> createState() => _MyCardImageState();
}

class _MyCardImageState extends State<MyCardImage> {
  String imgDesc = '';

  @override
  void initState() {
    super.initState();
    if (widget.text != '') {
      setState(() {
        imgDesc = widget.text;
      });
    } else {
      fetchImgDesc(widget.imageName).then((value) => setState(
            () => imgDesc = value,
          ));
    }
    fetchImgDesc(widget.imageName).then((value) => setState(
          () => imgDesc = value,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Card(
        color: widget.cardColor,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                widget.isOnline
                    ? Image.network(
                        'http://10.10.2.97:8000/image/${widget.imageName}',
                        width: widget.width * 0.4,
                        height: widget.height * 0.8,
                      )
                    : Image.asset(
                        'assets/images/${widget.imageName}',
                        width: widget.width * 0.4,
                        height: widget.height * 0.8,
                      ),
                SizedBox(
                  width: widget.width * 0.1,
                ),
                SizedBox(
                  width: widget.width * 0.4,
                  child: Text(
                    imgDesc,
                    textAlign: widget.textAlign,
                    maxLines: widget.maxLines,
                    overflow: widget.overflow, // Overflow behavior
                    style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: widget.fontWeight,
                        color: widget.color),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
