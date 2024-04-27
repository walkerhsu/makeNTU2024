import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            Image.asset(
              "assets/images/quiz.jpg",
              width: MediaQuery.of(context).size.width * 0.9,
            ),
            const SizedBox(
              height: 70,
            ),
            const Text(
              "CaRPG",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 52,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  color: Colors.yellow),
            ),
            const SizedBox(height: 100),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/game/settings');
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)))),
                    child: const Text(
                      "Play",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ))),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/game/settings');
                      QuickAlert.show(
                          context: context,
                          title: "Coming Soon",
                          text: "This feature is coming soon",
                          type: QuickAlertType.error
                          );
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)))),
                    child: const Text(
                      "Log in ??",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ))),
          ],
        ),
      ),
    );
  }
}