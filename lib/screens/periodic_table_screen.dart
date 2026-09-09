import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../services/l10n.dart';
import '../widgets/colors.dart';
import '../widgets/periodic_table.dart';
import 'config_screen.dart';

/// Referenz-Ansicht des Periodensystems.
/// Mit [forceStats] = true wird die Fehler-Statistik sofort angezeigt.
class PeriodicTableScreen extends StatefulWidget {
  final bool forceStats;

  const PeriodicTableScreen({super.key, this.forceStats = false});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.forceStats) {
      AppSettings.instance.setShowStats(true);
    }
  }

  void _openSettings() {
    final settings = AppSettings.instance;
    showModalBottomSheet(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(tr('Einstellungen'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SwitchListTile(
                title: Text(tr('Fehler-Statistik anzeigen')),
                subtitle: Text(tr('Rote Rahmen zeigen Problem-Elemente')),
                value: settings.showStats,
                onChanged: (v) => settings.setShowStats(v),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(tr('Statistik zurücksetzen')),
                onTap: () {
                  settings.resetErrors();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('Statistik wurde zurückgesetzt.'))),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(tr('Elemente konfigurieren')),
                subtitle: Text(tr('Auswählen, welche Elemente abgefragt werden')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forceStats ? tr('Fehler-Statistik') : tr('Periodensystem')),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        ],
      ),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final errorCounts = settings.showStats || widget.forceStats ? settings.errorCounts : null;
          final problemCount = settings.errorCounts.length;
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: CategoryLegend(),
              ),
              if (widget.forceStats)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    tr('Elemente mit Fehlern: {a} · Je dicker der rote Rahmen, desto mehr Probleme.', {'a': '$problemCount'}),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(12),
                    child: PeriodicTableGrid(
                      onTap: (e) => showElementDetails(context, e),
                      errorCounts: errorCounts,
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
