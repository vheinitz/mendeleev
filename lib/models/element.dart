/// Ein chemisches Element des Periodensystems.
class Element {
  final int number; // Ordnungszahl
  final String symbol; // Abkürzung / Symbol
  final String nameDe; // deutscher Name
  final String nameLa; // lateinischer / internationaler Name
  final double mass; // Atommasse in g/mol
  final int group; // Hauptgruppe 1..18
  final int period; // Periode 1..7
  final String category; // Kategorie (Metall, Nichtmetall, ...)
  final String? series; // 'la' = Lanthanoide, 'ac' = Actinoide, sonst null

  const Element({
    required this.number,
    required this.symbol,
    required this.nameDe,
    required this.nameLa,
    required this.mass,
    required this.group,
    required this.period,
    required this.category,
    this.series,
  });

  String get massLabel => mass.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

  bool get isFBlock => series != null;
}
