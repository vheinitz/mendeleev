import 'package:flutter/material.dart' hide Element;
import '../models/element.dart';
import '../services/l10n.dart';

/// Farbe je Element-Kategorie (kindgerecht & übersichtlich).
Color categoryColor(String category) {
  switch (category) {
    case 'Alkalimetall':
      return Colors.red.shade300;
    case 'Erdalkalimetall':
      return Colors.orange.shade300;
    case 'Übergangsmetall':
      return Colors.amber.shade300;
    case 'Lanthanoid':
      return Colors.pink.shade200;
    case 'Actinoid':
      return Colors.deepPurple.shade200;
    case 'Metall':
      return Colors.lightBlue.shade300;
    case 'Halbmetall':
      return Colors.teal.shade300;
    case 'Nichtmetall':
      return Colors.green.shade300;
    case 'Halogen':
      return Colors.cyan.shade300;
    case 'Edelgas':
      return Colors.indigo.shade200;
    default:
      return Colors.blueGrey.shade200;
  }
}

/// Farbe für ein Element-Kästchen.
Color elementColor(Element e) => categoryColor(e.category);

/// Kategorie mit Farbe als kleine Legende.
class CategoryLegend extends StatelessWidget {
  const CategoryLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Alkalimetall',
      'Erdalkalimetall',
      'Übergangsmetall',
      'Metall',
      'Halbmetall',
      'Nichtmetall',
      'Halogen',
      'Edelgas',
      'Lanthanoid',
      'Actinoid',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final c in categories)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: categoryColor(c),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(categoryName(c), style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}
