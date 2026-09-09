import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mendeleev/main.dart';
import 'package:mendeleev/data/elements_data.dart';
import 'package:mendeleev/data/density.dart';
import 'package:mendeleev/data/electronegativity.dart';
import 'package:mendeleev/data/names.dart';
import 'package:mendeleev/data/substances.dart';
import 'package:mendeleev/data/valences.dart';
import 'package:mendeleev/services/app_settings.dart';
import 'package:mendeleev/services/distractors.dart';
import 'package:mendeleev/services/electron_shells.dart';
import 'package:mendeleev/services/formula_parser.dart';

void main() {
  testWidgets('App startet und zeigt das Hauptmenü', (tester) async {
    await tester.pumpWidget(const MendeleevApp());
    expect(find.text('Periodensystem Lernprogramm'), findsOneWidget);
    expect(find.text('Periodensystem'), findsWidgets);
    expect(find.text('Quiz & Üben'), findsOneWidget);
    expect(find.text('Molmasse-Rechner'), findsOneWidget);
    expect(find.text('Elemente konfigurieren'), findsOneWidget);
    expect(find.text('Fehler-Statistik'), findsOneWidget);
  });

  test('Es gibt 118 Elemente', () {
    expect(elements.length, 118);
  });

  test('Symbole sind eindeutig', () {
    final symbols = elements.map((e) => e.symbol).toList();
    expect(symbols.toSet().length, 118);
  });

  test('Molmasse von Wasser (H2O)', () {
    final r = FormulaParser.parse('H2O');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(18.015, 0.001));
    expect(r.counts['H'], 2);
    expect(r.counts['O'], 1);
  });

  test('Molmasse von Glucose (C6H12O6)', () {
    final r = FormulaParser.parse('C6H12O6');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(180.156, 0.01));
  });

  test('Molmasse mit Klammern Ca(OH)2', () {
    final r = FormulaParser.parse('Ca(OH)2');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(74.092, 0.01));
    expect(r.counts['Ca'], 1);
    expect(r.counts['O'], 2);
    expect(r.counts['H'], 2);
  });

  test('Molmasse Fe2(SO4)3', () {
    final r = FormulaParser.parse('Fe2(SO4)3');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(399.87, 0.1));
    expect(r.counts['Fe'], 2);
    expect(r.counts['S'], 3);
    expect(r.counts['O'], 12);
  });

  test('Hydrat CuSO4·5H2O', () {
    final r = FormulaParser.parse('CuSO4·5H2O');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(249.68, 0.1));
    expect(r.counts['Cu'], 1);
    expect(r.counts['S'], 1);
    expect(r.counts['O'], 9);
    expect(r.counts['H'], 10);
  });

  test('Distraktoren: Symbol-Falschantworten enthalten nicht die richtige Antwort', () {
    final rng = Random(42);
    final d = Distractors.symbols('Cl', rng);
    expect(d, isNot(contains('Cl')));
    expect(d.length, 3);
    // Alle angebotenen Symbole beginnen mit C (ähnlich).
    for (final s in d) {
      expect(s.startsWith('C'), isTrue);
    }
  });

  test('Distraktoren: Namens-Falschantworten für Chlor ähneln sich', () {
    final rng = Random(7);
    final d = Distractors.names('Chlor', rng);
    expect(d, isNot(contains('Chlor')));
    expect(d.length, 3);
    expect(d.every((n) => n.startsWith('C')), isTrue);
  });

  test('Einstellungen: Standard-Auswahl sind die wichtigsten Elemente', () async {
    SharedPreferences.setMockInitialValues({});
    final s = AppSettings.instance;
    await s.load();
    expect(s.activeNumbers, containsAll([1, 6, 8, 26, 79]));
    expect(s.activeNumbers, isNot(contains(57))); // Lanthan ist standardmäßig aus
    expect(s.activeNumbers, isNot(contains(90))); // Thorium ist standardmäßig aus
    expect(s.findSeconds, 5); // Standard-Zeit beim Element-Finden
    expect(s.autoAdvanceSeconds, 2); // Standard: Auto-Weiter nach 2 s
  });

  test('Dichte (g/cm³ bzw. g/L)', () {
    expect(densityOf(29), closeTo(8.92, 0.001)); // Kupfer
    expect(densityOf(12), closeTo(1.74, 0.001)); // Magnesium
    expect(densityLabel(1), '0.09 g/L'); // Wasserstoff (Gas)
    expect(densityLabel(29), '8.92 g/cm³'); // Kupfer (Feststoff)
  });

  test('Übersetzungen: Element-, Kategorie- und Stoffnamen', () {
    expect(elementNameEn[26], 'Iron'); // Eisen
    expect(elementNameRu[26], 'Железо');
    expect(categoryEn['Edelgas'], 'Noble gas');
    expect(substanceNameEn['Wasser'], 'Water');
    expect(substanceNameRu['Wasser'], 'Вода');
  });

  test('Elektronegativität (Pauling)', () {
    expect(electronegativityOf(9), closeTo(3.98, 0.001)); // Fluor
    expect(electronegativityOf(8), closeTo(3.44, 0.001)); // Sauerstoff
    expect(electronegativityOf(2), isNull); // Helium: nicht definiert
    expect(electronegativityLabel(9), '3.98');
  });

  test('Elektronenschalen (Bohr-Modell)', () {
    expect(electronShells(1), [1]); // Wasserstoff
    expect(electronShells(2), [2]); // Helium
    expect(electronShells(11), [2, 8, 1]); // Natrium
    expect(electronShells(26), [2, 8, 14, 2]); // Eisen
    expect(electronShells(29), [2, 8, 18, 1]); // Kupfer (Ausnahme)
    expect(electronShells(79), [2, 8, 18, 32, 18, 1]); // Gold (Ausnahme)
    expect(shellText(11), 'K=2  L=8  M=1');
  });

  test('Stoffliste enthält die wichtigsten Stoffe', () {
    expect(substances.length, greaterThanOrEqualTo(100));
    expect(substances.first.name, 'Wasser');
    expect(substances.first.formula, 'H2O');
    expect(substances.any((s) => s.name == 'Schwefelsäure' && s.formula == 'H2SO4'), isTrue);
  });

  test('Molmasse von Methanol (CH3OH)', () {
    final r = FormulaParser.parse('CH3OH');
    expect(r.errors, isEmpty);
    expect(r.totalMass, closeTo(32.042, 0.01));
  });

  test('Wertigkeiten (Valenz)', () {
    expect(mainValence(1), 1); // Wasserstoff
    expect(mainValence(8), 2); // Sauerstoff
    expect(mainValence(6), 4); // Kohlenstoff
    expect(valenceLabel(26), '2, 3'); // Eisen
    expect(valencesOf(2), [0]); // Helium
  });

  test('Distraktoren: ähnliche Formeln enthalten nicht die richtige Formel', () {
    final rng = Random(3);
    final d = Distractors.similar('H2O', substances.map((s) => s.formula).toList(), rng);
    expect(d, isNot(contains('H2O')));
    expect(d.length, 3);
  });
}
