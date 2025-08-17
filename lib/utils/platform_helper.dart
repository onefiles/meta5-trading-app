import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformHelper {
  static bool get isIOS {
    if (kIsWeb) {
      // Web環境では常にfalseを返す（Androidライクな動作）
      return false;
    }
    return Platform.isIOS;
  }
  
  static bool get isAndroid {
    if (kIsWeb) {
      // Web環境では常にtrueを返す（Androidライクな動作）
      return true;
    }
    return Platform.isAndroid;
  }
  
  static bool get isWeb => kIsWeb;
  
  static String get operatingSystem {
    if (kIsWeb) {
      return 'web';
    }
    return Platform.operatingSystem;
  }
}