import 'package:flutter/material.dart';

class WaitResultPage extends StatelessWidget {
  const WaitResultPage({super.key});
  @override
  Widget build(BuildContext context) {
    print("in");
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting for result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Waiting for result...'),
          ],
        ),
      ),
    );
  }
}
