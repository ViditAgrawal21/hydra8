import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  Function changePage;
  StartScreen(this.changePage, {super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool showButton = true;

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 215,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/images/icons/icon_transparent.png",
                  height: 110,
                ),
                const SizedBox(
                  height: 5,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  height: showButton ? 100 : 0,
                  child: !showButton
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text(
                            //   "Minimal",
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.w400,
                            //       fontSize: 22,
                            //       color: isDarkTheme
                            //           ? Colors.white
                            //           : const Color.fromRGBO(0, 0, 0, 0.7)),
                            // ),
                            Text(
                              "Hydra8",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: isDarkTheme
                                      ? Colors.white
                                      : const Color.fromRGBO(0, 0, 0, 0.8)),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          !showButton
              ? const SizedBox()
              : SizedBox(
                  height: 50,
                  child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showButton = false;
                        });
                        Future.delayed(const Duration(milliseconds: 1200), () {
                          widget.changePage(1);
                        });
                      },
                      style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                          side: WidgetStateProperty.all(BorderSide(
                              color: isDarkTheme
                                  ? const Color(0xff515151)
                                  : const Color(0xffE9E9E9)))),
                      child: Text(
                        "Start Now",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16),
                      )),
                ),
          showButton
              ? const SizedBox()
              : const SizedBox(
                  height: 22.5,
                ),
          showButton
              ? const SizedBox()
              : SizedBox(
                  height: 5,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: isDarkTheme
                          ? const Color(0xff1C1C1C)
                          : const Color(0xffF4F4F4),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
          showButton
              ? const SizedBox()
              : const SizedBox(
                  height: 22.5,
                )
        ],
      )),
    );
  }
}
