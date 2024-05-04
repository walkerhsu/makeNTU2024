import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';

class MyLoading extends StatefulWidget {
  const MyLoading(
      {super.key, this.loadingText = "Generating the following part of story"});
  final String loadingText;

  @override
  State<MyLoading> createState() => _MyLoadingState();
}

class _MyLoadingState extends State<MyLoading> {
  late final Timer? timer;
  String dots = "";

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 333), (Timer timer) {
      setState(() {
        dots = "$dots.";
        if (dots.length > 3) {
          dots = "";
        }
      });
    });
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Center(
            child: Text(
              widget.loadingText + dots,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodySmall!.color),
            ),
          ),
        ],
      ),
    );
  }
}
