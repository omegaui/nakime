class SessionTagConstants {
  SessionTagConstants._();

  static final Map<String, String> _tagDisplayNames = {
    "session-recovered": "session was restarted",
  };

  static final Map<String, String> _tagDescriptions = {
    "session-recovered":
        "This session may have lasted for up-to 1 more minute and not more than that. This fluctuation in data is encountered because whenever you restart your system, Windows doesn't gives enough time to the background service to save the session state successfully, as a result, when the system is turned on again, the background service of Nakime tries to recover the previous session by checking it's previous unsaved session data which is updated every minute, so there is chance that the system might not have been able to shutdown at the exact time recorded and would have taken from 1 second to up-to 1 minute to close. However, this fluctuation is negligible.",
  };

  static final Map<String, String> _tagTimeSignificances = {
    "session-recovered": "or up-to +1 more minute",
  };

  static String getTagDisplayName(String tag) {
    return _tagDisplayNames[tag] ?? "Unknown session tag";
  }

  static String getTagDescription(String tag) {
    return _tagDescriptions[tag] ??
        "No data found for unknown tag: `$tag`, this can happen if your installation has different versions of Nakime and it's Windows Service.";
  }

  static String getTagTimeSignificance(String tag) {
    return _tagTimeSignificances[tag] ?? "(no more info)";
  }
}
