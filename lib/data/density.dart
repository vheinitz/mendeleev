/// Dichte je Ordnungszahl.
/// Feststoffe/Flüssigkeiten in g/cm³, Gase in g/L (bei 0 °C/1 bar).
/// Elemente ohne bekannten Wert sind nicht enthalten.
const Map<int, double> densityByNumber = {
  1: 0.0899, 2: 0.1785, 3: 0.534, 4: 1.85, 5: 2.34, 6: 2.26, 7: 1.251,
  8: 1.429, 9: 1.696, 10: 0.9002, 11: 0.97, 12: 1.74, 13: 2.70, 14: 2.33,
  15: 1.82, 16: 2.07, 17: 3.214, 18: 1.784, 19: 0.86, 20: 1.55, 21: 2.99,
  22: 4.51, 23: 6.11, 24: 7.19, 25: 7.21, 26: 7.87, 27: 8.90, 28: 8.91,
  29: 8.92, 30: 7.14, 31: 5.91, 32: 5.32, 33: 5.73, 34: 4.81, 35: 3.12,
  36: 3.749, 37: 1.53, 38: 2.64, 39: 4.47, 40: 6.51, 41: 8.57, 42: 10.28,
  43: 11.5, 44: 12.45, 45: 12.41, 46: 12.02, 47: 10.49, 48: 8.65, 49: 7.31,
  50: 7.31, 51: 6.68, 52: 6.24, 53: 4.93, 54: 5.894, 55: 1.87, 56: 3.51,
  57: 6.16, 58: 6.77, 59: 6.77, 60: 7.01, 61: 7.26, 62: 7.52, 63: 5.24,
  64: 7.90, 65: 8.23, 66: 8.54, 67: 8.79, 68: 9.07, 69: 9.32, 70: 6.97,
  71: 9.84, 72: 13.31, 73: 16.65, 74: 19.25, 75: 21.02, 76: 22.59, 77: 22.56,
  78: 21.45, 79: 19.32, 80: 13.53, 81: 11.85, 82: 11.34, 83: 9.79, 84: 9.20,
  85: 7.0, 86: 9.73, 87: 1.87, 88: 5.5, 89: 10.07, 90: 11.72, 91: 15.37,
  92: 19.05, 93: 20.45, 94: 19.82, 95: 12.0, 96: 13.51, 97: 14.78, 98: 15.1,
  99: 8.84,
};

/// Elemente, die bei Raumtemperatur gasförmig sind (Dichte in g/L).
const Set<int> gasElements = {1, 2, 7, 8, 9, 10, 17, 18, 36, 54, 86};

/// Dichte eines Elements (oder null, wenn unbekannt).
double? densityOf(int number) => densityByNumber[number];

/// Lesbare Darstellung, z. B. "8,92 g/cm³" oder "0,09 g/L".
String densityLabel(int number) {
  final d = densityOf(number);
  if (d == null) return '—';
  final unit = gasElements.contains(number) ? 'g/L' : 'g/cm³';
  final s = d.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return '$s $unit';
}
