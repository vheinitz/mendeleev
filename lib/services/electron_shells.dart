import 'dart:math' as math;

/// Elektronenverteilung auf die Schalen (vereinfachtes Bohr-Modell).
///
/// Gibt für jedes Element die Anzahl der Elektronen je besetzter Schale
/// zurück (K, L, M, N, O, P, Q). Gefüllt wird nach der Aufbau-/Madelung-
/// Reihenfolge; für bekannte Ausnahmen (z. B. Chrom, Kupfer, Silber,
/// Gold) ist die tatsächliche Verteilung hinterlegt.
List<int> electronShells(int atomicNumber) {
  final z = atomicNumber.clamp(1, 118);

  final override = _exceptions[z];
  if (override != null) return List<int>.from(override);

  // (Schale n, Kapazität) in Aufbau-Reihenfolge.
  const order = <List<int>>[
    [1, 2], [2, 2], [2, 6], [3, 2], [3, 6], [4, 2], [3, 10], [4, 6],
    [5, 2], [4, 10], [5, 6], [6, 2], [4, 14], [5, 10], [6, 6],
    [7, 2], [5, 14], [6, 10], [7, 6],
  ];

  final shells = List<int>.filled(7, 0, growable: true);
  var remaining = z;
  for (final o in order) {
    if (remaining <= 0) break;
    final n = o[0];
    final cap = o[1];
    final take = math.min(remaining, cap);
    shells[n - 1] += take;
    remaining -= take;
  }

  // Leere äußere Schalen entfernen.
  while (shells.isNotEmpty && shells.last == 0) {
    shells.removeLast();
  }
  return shells;
}

/// Schalenbezeichnungen (K, L, M, N, O, P, Q).
const List<String> shellLetters = ['K', 'L', 'M', 'N', 'O', 'P', 'Q'];

/// Lesbarer Text, z. B. "K=2 · L=8 · M=8 · N=1".
String shellText(int atomicNumber) {
  final shells = electronShells(atomicNumber);
  return [
    for (var i = 0; i < shells.length; i++) '${shellLetters[i]}=${shells[i]}',
  ].join('  ');
}

/// Bekannte Ausnahmen von der einfachen Aufbau-Reihenfolge.
final Map<int, List<int>> _exceptions = {
  24: [2, 8, 13, 1], // Chrom
  29: [2, 8, 18, 1], // Kupfer
  41: [2, 8, 18, 12, 1], // Niob
  42: [2, 8, 18, 13, 1], // Molybdän
  44: [2, 8, 18, 15, 1], // Ruthenium
  45: [2, 8, 18, 16, 1], // Rhodium
  46: [2, 8, 18, 18], // Palladium
  47: [2, 8, 18, 18, 1], // Silber
  57: [2, 8, 18, 18, 9, 2], // Lanthan
  58: [2, 8, 18, 19, 9, 2], // Cer
  64: [2, 8, 18, 25, 9, 2], // Gadolinium
  78: [2, 8, 18, 32, 17, 1], // Platin
  79: [2, 8, 18, 32, 18, 1], // Gold
  89: [2, 8, 18, 32, 18, 9, 2], // Actinium
  90: [2, 8, 18, 32, 18, 10, 2], // Thorium
  91: [2, 8, 18, 32, 20, 9, 2], // Protactinium
  92: [2, 8, 18, 32, 21, 9, 2], // Uran
  93: [2, 8, 18, 32, 22, 9, 2], // Neptunium
  96: [2, 8, 18, 32, 25, 9, 2], // Curium
};
