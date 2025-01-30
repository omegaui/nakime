class SessionTagConstants {
  SessionTagConstants._();

  static final Map<String, String> _tagDisplayNames = {
    "session-recovered": "session was restarted",
  };

  static final Map<String, String> _tagDescriptions = {
    "session-recovered":
        "The session may have lasted up to 1 minute longer due to a delay in saving the session state when restarting the system. Windows doesn’t give enough time for the background service to save properly. When the system restarts, Nakime's background service tries to recover the previous session by checking unsaved data, which updates every minute. This can cause a slight fluctuation in the recorded shutdown time, but it’s negligible.",
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
