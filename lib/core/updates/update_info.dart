import 'dart:convert';

import 'package:http/http.dart';
import 'package:nakime/main.dart';

const _listReleasesEndpoint =
    "https://api.github.com/repos/omegaui/nakime/tags";

class UpdateInfo {
  final String version;
  final bool available;
  final String? error;

  UpdateInfo({
    this.version = "",
    required this.available,
    this.error,
  });

  static Future<UpdateInfo> checkForUpdates() async {
    try {
      final response = await get(Uri.parse(_listReleasesEndpoint));
      if (response.statusCode == 200) {
        final content = jsonDecode(response.body)[0];
        final version = content["name"];
        final installedVersion = "${appInfo.version}+${appInfo.buildNumber}";
        return UpdateInfo(
          version: version,
          available: version != installedVersion,
        );
      } else {
        throw Exception(
            "Check for updates finished with status code ${response.statusCode}: ${response.body}");
      }
    } catch (e, stack) {
      return UpdateInfo(
        available: false,
        error: "$e\n$stack",
      );
    }
  }
}
