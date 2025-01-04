import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/aboutscreen-widgets/attribution_tile.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = "/about";
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).scaffoldBackgroundColor,
              statusBarIconBrightness:
                  isDarkTheme ? Brightness.light : Brightness.dark),
          title: const Text("About"),
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context, true),
          )),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/images/icons/icon_transparent.png",
            height: 130,
          ),
          Text(
            "Minimal Water Tracker",
            style: TextStyle(
                fontSize: 20,
                color: isDarkTheme
                    ? Colors.white
                    : const Color.fromRGBO(0, 0, 0, 0.8)),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "v1.0.4",
            style: TextStyle(
                fontSize: 13,
                color: isDarkTheme
                    ? Colors.white54
                    : const Color.fromRGBO(0, 0, 0, 0.3)),
          ),
          TextButton(
            onPressed: () async {
              await launchUrl(Uri.parse(
                  "https://sites.google.com/view/minimal-water-tracker-privacy/startseite"));
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Text("Privacy Policy"),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: AttributionTile(
                url:
                    "https://www.freepik.com/free-vector/collection-beverage-vectors_2800691.htm#query=soda%20bottle&position=21&from_view=keyword",
                urlText: "Collection of beverage vectors",
                sourceText: "rawpixel.com on Freepik"),
          ),
          const SizedBox(
            height: 100,
          ),
        ]),
      ),
    );
  }
}
