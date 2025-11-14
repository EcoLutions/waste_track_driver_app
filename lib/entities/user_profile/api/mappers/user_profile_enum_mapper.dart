import 'package:waste_track_driver_app/entities/user_profile/model/enums/language.dart';

class LanguageMapper {
  static Language parse(String? language) {
    if (language == null || language.isEmpty) {
      return Language.es;
    }

    try {
      return LanguageExtension.fromString(language);
    } catch (e) {
      return Language.es;
    }
  }

  static String parseToString(Language language) {
    return language.toString();
  }
}
