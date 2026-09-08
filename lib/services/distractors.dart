import 'dart:math';
import '../data/elements_data.dart';

/// Erzeugt plausible, ähnlich aussehende Falschantworten (Distraktoren),
/// damit Multiple-Choice-Fragen nicht zu leicht sind.
///
/// Es werden bevorzugt Begriffe mit gleichem/ähnlichem Anfangsbuchstaben
/// angeboten (z. B. bei Cl: Chlor, Chrom, Calcium, ...) und zusätzlich
/// „erfundene“ Varianten, die wie echte Namen/Symbole aussehen.
class Distractors {
  static const List<String> _nameSuffixes = [
    'ium', 'at', 'on', 'an', 'in', 'id', 'yl', 'ogen', 'or', 'en',
  ];
  static const List<String> _latinSuffixes = [
    'ium', 'um', 'on', 'us', 'at', 'an',
  ];

  // ------------------------------------------------------------ öffentlich

  /// Ähnliche Element-Namen (deutsch).
  static List<String> names(String correct, Random rng, {int count = 3}) {
    final pool = elements.map((e) => e.nameDe).toList();
    return _pick(correct, [...pool, ..._invented(correct, _nameSuffixes, rng)], count, rng);
  }

  /// Ähnliche Element-Symbole (real + erfunden, z. B. C, Cr, Cl, Cx).
  static List<String> symbols(String correct, Random rng, {int count = 3}) {
    final pool = elements.map((e) => e.symbol).toList();
    return _pick(correct, [...pool, ..._inventedSymbols(correct, rng)], count, rng);
  }

  /// Ähnliche lateinische Namen.
  static List<String> latin(String correct, Random rng, {int count = 3}) {
    final pool = elements.map((e) => e.nameLa).toList();
    return _pick(correct, [...pool, ..._invented(correct, _latinSuffixes, rng)], count, rng);
  }

  /// Ähnliche Begriffe aus einem frei wählbaren Pool (z. B. Formeln oder
  /// Stoffnamen), ohne erfundene Varianten.
  static List<String> similar(String correct, List<String> pool, Random rng, {int count = 3}) {
    return _pick(correct, pool, count, rng);
  }

  // ------------------------------------------------------------ Kern

  static List<String> _pick(String correct, List<String> pool, int count, Random rng) {
    final seen = <String>{};
    final candidates = <String>[];
    for (final c in pool) {
      if (c == correct) continue;
      if (c.isNotEmpty && seen.add(c)) candidates.add(c);
    }

    candidates.sort((a, b) => _score(b, correct).compareTo(_score(a, correct)));

    // Aus den ähnlichsten Kandidaten zufällig auswählen (für Abwechslung).
    final top = candidates.take(count * 4).toList()..shuffle(rng);
    final result = top.take(count).toList();

    // Fallback, falls es nicht genug Kandidaten gibt.
    if (result.length < count) {
      for (final c in candidates) {
        if (result.length >= count) break;
        if (!result.contains(c)) result.add(c);
      }
    }
    return result;
  }

  /// Ähnlichkeits-Score: gleicher Anfangsbuchstabe und gemeinsame Vorsilbe
  /// zählen stark, Länge/Levenshtein-Abstand fließen ebenfalls ein.
  static int _score(String candidate, String correct) {
    final a = candidate.toLowerCase();
    final b = correct.toLowerCase();
    if (a.isEmpty || b.isEmpty) return -1000;

    var s = 0;
    if (a[0] == b[0]) s += 6;
    final prefix = _commonPrefixLength(a, b);
    s += prefix * 2;
    s -= _levenshtein(a, b);
    s -= (a.length - b.length).abs();
    return s;
  }

  static int _commonPrefixLength(String a, String b) {
    var i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return i;
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;
    var prev = List<int>.generate(n + 1, (i) => i);
    var curr = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        final del = prev[j] + 1;
        final ins = curr[j - 1] + 1;
        final sub = prev[j - 1] + cost;
        curr[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }

  /// Erfundene Namen: richtiger Begriff + chemisch klingende Endung
  /// (z. B. Chlor -> Chlorium, Chlorat, ...) sowie Vorsilben-Varianten.
  static List<String> _invented(String correct, List<String> suffixes, Random rng) {
    final result = <String>{};
    final base = correct.length <= 3 ? correct : correct.substring(0, 3);
    for (final suffix in suffixes) {
      final full = '$correct$suffix';
      if (full != correct) result.add(full);
      final short = '$base$suffix';
      if (short != correct && short.length > 2) result.add(short);
    }
    return result.toList()..shuffle(rng);
  }

  /// Erfundene Symbole: gleicher Anfangsbuchstabe + zufälliger zweiter
  /// Buchstabe (z. B. Cx, Cj), die es als echtes Symbol nicht gibt.
  static List<String> _inventedSymbols(String correct, Random rng) {
    if (correct.isEmpty) return const [];
    final first = correct[0].toUpperCase();
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    final real = elements.map((e) => e.symbol).toSet();

    final result = <String>{};
    var attempts = 0;
    while (result.length < 5 && attempts < 200) {
      attempts++;
      final second = letters[rng.nextInt(letters.length)];
      final candidate = '$first$second';
      if (candidate != correct && !real.contains(candidate)) {
        result.add(candidate);
      }
    }
    return result.toList();
  }
}
