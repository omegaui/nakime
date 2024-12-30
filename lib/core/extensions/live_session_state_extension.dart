import 'package:nakime/core/sessions/live_session.dart';

extension LiveSessionStateExtension on LiveSessionState {
  bool get isStable => this == LiveSessionState.stable;

  bool get isError => this == LiveSessionState.error;

  bool get isEmpty => this == LiveSessionState.empty;
}
