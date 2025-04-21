import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';
import 'es.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en,
    'ar_SA': ar,
    'es_ES': es,
  };
}
