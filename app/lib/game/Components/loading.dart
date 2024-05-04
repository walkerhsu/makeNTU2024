import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';

class MyLoading extends StatelessWidget {
  const MyLoading(
      {super.key, this.loadingText = "Generating the following part of story..."});
  final String loadingText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          height: 50,
        ),
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            size: 150,
            color: Colors.blue,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          loadingText,
          style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).textTheme.bodySmall!.color),
        ),
      ],
    );
  }
}
