import 'package:flutter/services.dart';

class Haptics {
  Haptics._();

  static void swipeCommit() => HapticFeedback.mediumImpact();
  static void tabSwitch() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.heavyImpact();
}
