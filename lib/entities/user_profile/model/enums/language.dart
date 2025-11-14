import 'package:freezed_annotation/freezed_annotation.dart';

enum Language {
  @JsonValue('ES')
  es,

  @JsonValue('EN')
  en,

  @JsonValue('PT')
  pt,

  @JsonValue('FR')
  fr;

  String get displayName {
    switch (this) {
      case Language.es:
        return 'Español';
      case Language.en:
        return 'English';
      case Language.pt:
        return 'Portugués';
      case Language.fr:
        return 'Français';
    }
  }
}

extension LanguageExtension on Language {
  String toJson() {
    switch (this) {
      case Language.es:
        return 'ES';
      case Language.en:
        return 'EN';
      case Language.pt:
        return 'PT';
      case Language.fr:
        return 'FR';
    }
  }

  static Language fromString(String language) {
    switch (language.toUpperCase()) {
      case 'ES':
        return Language.es;
      case 'EN':
        return Language.en;
      case 'PT':
        return Language.pt;
      case 'FR':
        return Language.fr;
      default:
        throw ArgumentError('Unknown language: $language');
    }
  }
}
