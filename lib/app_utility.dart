import 'package:flutter/foundation.dart';

class AppUtility {
  static printLogMessage(var data, String tag) {
    const bool prod = bool.fromEnvironment('dart.vm.product');
    if (!kReleaseMode && !prod) {
      if (kDebugMode) {
        print("$tag:- $data");
      }
    }
  }
}
