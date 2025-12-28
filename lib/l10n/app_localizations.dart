import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  String get appTitle;
  String get home;
  String get scan;
  String get results;
  String get settings;
  String get oneTabClean;
  String get cleanNow;
  String get scanning;
  String get cleaning;
  String get storageAnalyzer;
  String get usedSpace;
  String get freeSpace;
  String get totalSpace;
  String get junkFiles;
  String get tempFiles;
  String get thumbnails;
  String get logFiles;
  String get residualFiles;
  String get appCache;
  String get ramBooster;
  String get boostRam;
  String get ramBefore;
  String get ramAfter;
  String get ramFreed;
  String get duplicateFinder;
  String get findDuplicates;
  String get duplicatePhotos;
  String get duplicateVideos;
  String get batterySaver;
  String get enableBatterySaver;
  String get batterySaverTip;
  String get cleanHistory;
  String get totalFreed;
  String get lastClean;
  String get cleanCount;
  String get darkMode;
  String get language;
  String get english;
  String get russian;
  String get spanish;
  String get about;
  String get version;
  String get permissions;
  String get grantPermissions;
  String get storagePermission;
  String get storagePermissionDesc;
  String get complete;
  String spaceFreed(String size);
  String itemsFound(int count);
  String get deleteSelected;
  String get selectAll;
  String get deselectAll;
  String get noJunkFound;
  String get noDuplicatesFound;
  String get cleaningComplete;
  String get deviceOptimized;
  String get apps;
  String get cache;
  String get junk;
  String get media;
  String get documents;
  String get other;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale".');
}
