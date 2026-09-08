import '../data/elements_data.dart';

/// Ergebnis einer Molmassen-Berechnung.
class MolarMassResult {
  final double totalMass; // g/mol
  final Map<String, int> counts; // Symbol -> Anzahl
  final List<String> errors; // Fehlermeldungen

  MolarMassResult(this.totalMass, this.counts, this.errors);
}

/// Zerlegt eine chemische Summenformel und berechnet die Molmasse.
///
/// Unterstützt:
///  * Element-Symbole (ein Großbuchstabe + optional ein Kleinbuchstabe)
///  * Indizes (z. B. H2O, C6H12O6)
///  * Klammern mit Index (z. B. Ca(OH)2, Fe2(SO4)3)
///  * Hydrate / Trennzeichen: ·, *, •, +, Leerzeichen (z. B. CuSO4·5H2O)
///  * Führende Koeffizienten (z. B. 5H2O)
class FormulaParser {
  static MolarMassResult parse(String formula) {
    final counts = <String, int>{};
    final errors = <String>[];
    final normalized = formula
        .replaceAll('·', '*')
        .replaceAll('•', '*')
        .replaceAll('∙', '*')
        .trim();

    if (normalized.isEmpty) {
      return MolarMassResult(0, counts, ['Bitte eine Formel eingeben.']);
    }

    final index = _parseSequence(normalized, 0, normalized.length, counts, errors);
    if (index < normalized.length) {
      errors.add('Ungültige Stelle in der Formel bei Zeichen ${index + 1}.');
    }

    double total = 0;
    for (final entry in counts.entries) {
      final symbol = entry.key;
      if (!elementBySymbol.containsKey(symbol)) {
        errors.add('Unbekanntes Element „$symbol“.');
        continue;
      }
      total += elementBySymbol[symbol]!.mass * entry.value;
    }

    return MolarMassResult(total, counts, errors.toSet().toList());
  }

  /// Parst eine Folge von Gruppen, getrennt durch +, * oder Leerzeichen.
  /// Gibt den Index zurück, bis zu dem gelesen wurde.
  static int _parseSequence(String s, int start, int end, Map<String, int> counts, List<String> errors) {
    var i = start;
    while (i < end) {
      // Trennzeichen und Leerzeichen überspringen.
      while (i < end && (_isSeparator(s[i]) || s[i] == ' ')) {
        i++;
      }
      if (i >= end) break;

      // Optionaler führender Koeffizient (z. B. 5H2O).
      final numResult = _readNumber(s, i, end);
      final coefficient = numResult.value == 0 ? 1 : numResult.value;
      i = numResult.next;

      // Eine zusammenhängende Gruppe (Elemente und Klammern) parsen.
      final sub = <String, int>{};
      final next = _parseGroup(s, i, end, sub, errors);
      if (next == i) {
        errors.add('Unerwartetes Zeichen „${s[i]}“ an Stelle ${i + 1}.');
        return i;
      }
      for (final entry in sub.entries) {
        counts[entry.key] = (counts[entry.key] ?? 0) + entry.value * coefficient;
      }
      i = next;
    }
    return i;
  }

  /// Parst eine zusammenhängende Gruppe (Elemente und Klammern) von [start] bis [end].
  /// Stoppt an Trennzeichen. Gibt den Index zurück, bis zu dem gelesen wurde.
  static int _parseGroup(String s, int start, int end, Map<String, int> counts, List<String> errors) {
    var i = start;
    while (i < end) {
      final ch = s[i];
      if (_isSeparator(ch) || ch == ' ') {
        break; // Ende dieser Gruppe, Trennzeichen übernimmt die Sequenz.
      }
      if (ch == '(') {
        final close = _findClosing(s, i, end);
        if (close == -1) {
          errors.add('Fehlende schließende Klammer.');
          return i;
        }
        final sub = <String, int>{};
        final innerEnd = _parseGroup(s, i + 1, close, sub, errors);
        if (innerEnd != close) return innerEnd;
        final numResult = _readNumber(s, close + 1, end);
        final factor = numResult.value == 0 ? 1 : numResult.value;
        for (final entry in sub.entries) {
          counts[entry.key] = (counts[entry.key] ?? 0) + entry.value * factor;
        }
        i = numResult.next;
      } else if (_isUpper(ch)) {
        var symbol = ch;
        var j = i + 1;
        if (j < end && _isLower(s[j])) {
          symbol += s[j];
          j++;
        }
        final numResult = _readNumber(s, j, end);
        final factor = numResult.value == 0 ? 1 : numResult.value;
        counts[symbol] = (counts[symbol] ?? 0) + factor;
        i = numResult.next;
      } else {
        errors.add('Unerwartetes Zeichen „$ch“ an Stelle ${i + 1}.');
        return i;
      }
    }
    return i;
  }

  static int _findClosing(String s, int open, int end) {
    var depth = 1;
    for (var i = open + 1; i < end; i++) {
      if (s[i] == '(') depth++;
      if (s[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  static ({int value, int next}) _readNumber(String s, int start, int end) {
    var i = start;
    var value = 0;
    while (i < end && _isDigit(s[i])) {
      value = value * 10 + int.parse(s[i]);
      i++;
    }
    return (value: value, next: i);
  }

  static bool _isSeparator(String c) => c == '+' || c == '*';
  static bool _isUpper(String c) => c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90;
  static bool _isLower(String c) => c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122;
  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}
