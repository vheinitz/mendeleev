import 'package:flutter/material.dart';
import '../data/elements_data.dart';
import '../services/app_settings.dart';
import '../widgets/colors.dart';
import '../widgets/periodic_table.dart';

/// Konfigurations-Seite: Elemente antippen, um sie für Quiz-Fragen
/// ein- oder auszublenden. Ausgeblendete Elemente erscheinen grau.
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Elemente konfigurieren'), centerTitle: true),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final inactive = {
            for (final e in elements)
              if (!settings.isActive(e.number)) e.number,
          };
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Tippe auf ein Element, um es ein- oder auszublenden.\nGraue Elemente werden nicht abgefragt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => settings.setActiveNumbers({for (final e in elements) e.number}),
                      child: const Text('Alle'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => settings.setActiveNumbers({}),
                      child: const Text('Keine'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => settings.setActiveNumbers(Set<int>.from(importantNumbers)),
                      child: const Text('Wichtige Auswahl'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Aktiv: ${settings.activeCount} von ${elements.length}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: CategoryLegend(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    child: PeriodicTableGrid(
                      onTap: (e) => settings.toggleElement(e.number),
                      disabledNumbers: inactive,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
