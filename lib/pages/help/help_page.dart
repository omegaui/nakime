import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class _FAQ {
  final String question;
  final String answer;

  _FAQ({required this.question, required this.answer});
}

class _FAQs {
  _FAQs._();

  static List<_FAQ> all = [
    _FAQ(
      question: "How do I check my previous sessions?",
      answer:
          "On Home Page, when you click 'View Stats', it takes you to a page where you are shown all of active sessions for today or when the first session was started. Below 'Total System Uptime' you would see a link saying 'See previous sessions', if you click on that, another page opens where you specify the start and end dates, then, Nakime loads a graph of session activity along with the list of sessions grouped by date, you can export this data by click the 'Export' button on the top right corner of the page.",
    ),
    _FAQ(
      question: "How to check for app updates?",
      answer:
          "By going to 'App Info' page, you can see a button saying 'Check for updates' on the top right corner. Make sure to have internet connection before clicking it, when you do so, it checks Nakime's GitHub repository 'main' branch for updates, if there are any updates available you will be redirected to GitHub release page.",
    ),
    _FAQ(
      question: "Can I export my data in JSON format?",
      answer:
          "Yes, Nakime already uses JSON to store session records, you don't even need to export it. Just go to 'C:\\ProgramData\\Nakime' and you will see your sessions in JSON format, grouped by date.",
    ),
    _FAQ(
      question: "How can I delete my session data without uninstalling Nakime?",
      answer:
          "Just delete all the files under 'C:\\ProgramData\\Nakime' except '.poll-session' and '.live-session' file.",
    ),
    _FAQ(
      question: "Where are all my data exported in excel format stored?",
      answer:
          "You can find all your exports at 'C:\\ProgramData\\Nakime\\exports'.",
    ),
    _FAQ(
      question: "Does Nakime collects any of my data in any way?",
      answer:
          "No, not at all. Nakime never collects your data. The internet connection is only used to install the Poppins font on first launch and when you check for updates in the 'App Info' page. Nakime is open-source, and you can verify this by checking its source code at https://github.com/omegaui/nakime.",
    ),
  ];
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                    const Gap(10),
                    const Text(
                      "Help",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    launchUrlString(
                        'https://github.com/omegaui/nakime/issues/new?template=%F0%9F%AA%B2.md');
                  },
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Report an issue"),
                      const Gap(4),
                      Icon(
                        Icons.open_in_new,
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._FAQs.all.map(
                      (e) => ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          "${_FAQs.all.indexOf(e) + 1}. ${e.question}",
                          style: TextStyle(
                            color: AppColors.onSurface,
                          ),
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          Text(
                            e.answer,
                            style: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Clipp extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 90, size.width, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
