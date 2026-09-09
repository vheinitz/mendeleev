import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/elements_data.dart';

/// Zentrale, dauerhaft gespeicherte Einstellungen der App:
///  * welche Elemente abgefragt werden dürfen
///  * Fehler-Statistik pro Element
///  * ob die Statistik in der Tabelle angezeigt wird
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _keyActive = 'active_elements';
  static const _keyErrors = 'error_counts';
  static const _keyShowStats = 'show_stats';
  static const _keyFindSeconds = 'find_seconds';
  static const _keyAutoAdvance = 'auto_advance_seconds';
  static const _keyLanguage = 'language';

  Set<int> _activeNumbers = {};
  Map<int, int> _errorCounts = {};
  bool _showStats = false;
  int _findSeconds = 5;
  int _autoAdvanceSeconds = 2;
  String _language = 'de';

  Set<int> get activeNumbers => _activeNumbers;
  Map<int, int> get errorCounts => _errorCounts;
  bool get showStats => _showStats;
  int get findSeconds => _findSeconds;
  int get autoAdvanceSeconds => _autoAdvanceSeconds;
  String get language => _language;

  bool isActive(int number) => _activeNumbers.contains(number);
  int get activeCount => _activeNumbers.length;

  /// Lädt die gespeicherten Werte. Beim ersten Start sind die wichtigsten
  /// Elemente aktiv.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final activeStr = prefs.getString(_keyActive);
    if (activeStr == null) {
      _activeNumbers = Set<int>.from(importantNumbers);
    } else {
      _activeNumbers = activeStr
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toSet();
    }

    final errorsStr = prefs.getString(_keyErrors);
    _errorCounts = {};
    if (errorsStr != null && errorsStr.isNotEmpty) {
      for (final part in errorsStr.split(';')) {
        final idx = part.indexOf(':');
        if (idx > 0) {
          _errorCounts[int.parse(part.substring(0, idx))] =
              int.parse(part.substring(idx + 1));
        }
      }
    }

    _showStats = prefs.getBool(_keyShowStats) ?? false;
    _findSeconds = prefs.getInt(_keyFindSeconds) ?? 5;
    _autoAdvanceSeconds = prefs.getInt(_keyAutoAdvance) ?? 2;
    _language = prefs.getString(_keyLanguage) ?? 'de';
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyActive,
      _activeNumbers.map((n) => '$n').join(','),
    );
    await prefs.setString(
      _keyErrors,
      _errorCounts.entries.map((e) => '${e.key}:${e.value}').join(';'),
    );
    await prefs.setBool(_keyShowStats, _showStats);
    await prefs.setInt(_keyFindSeconds, _findSeconds);
    await prefs.setInt(_keyAutoAdvance, _autoAdvanceSeconds);
    await prefs.setString(_keyLanguage, _language);
  }

  /// Schaltet ein Element um (aktiv <-> ausgeblendet).
  Future<void> toggleElement(int number) async {
    if (_activeNumbers.contains(number)) {
      _activeNumbers.remove(number);
    } else {
      _activeNumbers.add(number);
    }
    notifyListeners();
    await _save();
  }

  Future<void> setActiveNumbers(Set<int> numbers) async {
    _activeNumbers = Set<int>.from(numbers);
    notifyListeners();
    await _save();
  }

  /// Merkt sich einen Fehler für ein Element (für die Statistik).
  Future<void> recordError(int number) async {
    _errorCounts[number] = (_errorCounts[number] ?? 0) + 1;
    notifyListeners();
    await _save();
  }

  Future<void> resetErrors() async {
    _errorCounts.clear();
    notifyListeners();
    await _save();
  }

  Future<void> setShowStats(bool value) async {
    _showStats = value;
    notifyListeners();
    await _save();
  }

  Future<void> setFindSeconds(int value) async {
    _findSeconds = value;
    notifyListeners();
    await _save();
  }

  Future<void> setAutoAdvanceSeconds(int value) async {
    _autoAdvanceSeconds = value;
    notifyListeners();
    await _save();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    await _save();
  }
}
