import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AttributionTile extends StatelessWidget {
  final String url;
  final String urlText;
  final String sourceText;

  const AttributionTile(
      {required this.url,
      required this.urlText,
      required this.sourceText,
      super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            children: [
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0))),
                  onPressed: () async {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Text(urlText)),
              const SizedBox(
                width: 10,
              ),
              Text(
                "by $sourceText",
                style: TextStyle(
                    color: isDarkTheme
                        ? Colors.white70
                        : const Color.fromRGBO(0, 0, 0, 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
