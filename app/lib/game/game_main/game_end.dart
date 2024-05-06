import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rpg_game/game/Components/card_image.dart';
import 'package:rpg_game/game/fetch_request.dart';

class GameEndPage extends StatefulWidget {
  const GameEndPage({super.key});

  @override
  State<GameEndPage> createState() => _GameEndPageState();
}

class _GameEndPageState extends State<GameEndPage> {
  String? title;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchAllImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                  title: const Text("Results"),
                  leading: IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () async {
                      await QuickAlert.show(
                        context: context,
                        text:
                            "Are you sure you want to leave this story? This will not save your results!",
                        cancelBtnText: 'Not Yet~',
                        confirmBtnText: "Leave💔",
                        confirmBtnColor: const Color.fromARGB(255, 249, 163, 3),
                        type: QuickAlertType.confirm,
                        onCancelBtnTap: () => Navigator.pop(context),
                        onConfirmBtnTap: () {
                          Navigator.pop(context);
                          if (!mounted) return;
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      );
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.custom,
                          title: 'Saving Memori...',
                          barrierDismissible: true,
                          confirmBtnText: 'Save',
                          widget: TextFormField(
                            decoration: InputDecoration(
                                alignLabelWithHint: true,
                                hintText: 'Title',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Image.asset(
                                    'assets/images/tag.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                )),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => title = value,
                          ),
                          onConfirmBtnTap: () async {
                            if (title == null || title!.isEmpty) {
                              await QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                text: "Title cannot be empty!",
                              );
                              return;
                            }
                            Navigator.pop(context);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            if (!mounted || !context.mounted) return;
                            await QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: "Memori $title is saved!",
                            );
                            print(title!);
                            await postMemoryResponse(title!);
                            if (!mounted || !context.mounted) return;
                            Navigator.pop(context);
                          },
                        );
                      },
                    )
                  ]),
              body: ListView.builder(
                  itemCount: (snapshot.data as List).length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        MyCardImage(
                          imageName: snapshot.data![index],
                          width: 350,
                          height: 150,
                          fontSize: 12,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: Colors.black,
                          height: 10,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ],
                    );
                  }),
            );
          }
        });
  }
}
