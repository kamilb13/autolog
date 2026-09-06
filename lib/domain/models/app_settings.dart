import 'package:flutter/material.dart';

enum AppLanguage {
  system,
  pl,
  en;

  String get code {
    switch (this) {
      case AppLanguage.pl:
        return 'pl';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.system:
        return '';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLanguage.pl:
        return const Locale('pl');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.system:
        return null;
    }
  }

  static AppLanguage fromCode(String? code) {
    if (code == 'pl') return AppLanguage.pl;
    if (code == 'en') return AppLanguage.en;
    return AppLanguage.system;
  }
}

enum AppCurrency {
  pln,
  eur,
  usd;

  String get code {
    switch (this) {
      case AppCurrency.pln:
        return 'PLN';
      case AppCurrency.eur:
        return 'EUR';
      case AppCurrency.usd:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case AppCurrency.pln:
        return 'zł';
      case AppCurrency.eur:
        return '€';
      case AppCurrency.usd:
        return '\$';
    }
  }

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.pln;
    switch (code.toUpperCase()) {
      case 'EUR':
        return AppCurrency.eur;
      case 'USD':
        return AppCurrency.usd;
      case 'PLN':
      default:
        return AppCurrency.pln;
    }
  }
}

enum DistanceUnit {
  km,
  mi;

  String get label {
    switch (this) {
      case DistanceUnit.km:
        return 'km';
      case DistanceUnit.mi:
        return 'mi';
    }
  }

  static DistanceUnit fromCode(String? code) {
    if (code == 'mi') return DistanceUnit.mi;
    return DistanceUnit.km;
  }
}

class AppSettings {
  final AppLanguage language;
  final AppCurrency currency;
  final DistanceUnit distanceUnit;
  final ThemeMode themeMode;

  const AppSettings({
    this.language = AppLanguage.system,
    this.currency = AppCurrency.pln,
    this.distanceUnit = DistanceUnit.km,
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({
    AppLanguage? language,
    AppCurrency? currency,
    DistanceUnit? distanceUnit,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, String> toSettingsMap() {
    return {
      'language': language.code,
      'currency': currency.code,
      'distance_unit': distanceUnit.name,
      'theme_mode': themeMode.name,
    };
  }

  factory AppSettings.fromSettingsMap(Map<String, String> map) {
    final langCode = map['language'];
    final currCode = map['currency'];
    final unitCode = map['distance_unit'];
    final themeName = map['theme_mode'];

    ThemeMode theme = ThemeMode.system;
    if (themeName == 'light') theme = ThemeMode.light;
    if (themeName == 'dark') theme = ThemeMode.dark;

    return AppSettings(
      language: AppLanguage.fromCode(langCode),
      currency: AppCurrency.fromCode(currCode),
      distanceUnit: DistanceUnit.fromCode(unitCode),
      themeMode: theme,
    );
  }
}
