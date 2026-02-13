import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';

Future<void> bootstrap() async {
  await Hive.initFlutter();
  await Hive.openBox<Map<dynamic, dynamic>>(AppConstants.cardsBoxName);
  await Hive.openBox<dynamic>(AppConstants.settingsBoxName);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint(details.exceptionAsString());
      debugPrint(details.stack.toString());
    }
  };
}
