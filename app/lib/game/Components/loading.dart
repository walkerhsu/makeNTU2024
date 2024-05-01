import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';

class MyLoading extends StatelessWidget {
  const MyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        size: 100,
        color: Colors.blue,
      ),
    ) ;
  }
}