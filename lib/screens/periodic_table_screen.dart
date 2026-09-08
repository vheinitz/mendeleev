import 'package:flutter/material.dart';
import '../services/app_settings.dart';
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
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Einstellungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SwitchListTile(
                title: const Text('Fehler-Statistik anzeigen'),
                subtitle: const Text('Rote Rahmen zeigen Problem-Elemente'),
                value: settings.showStats,
                onChanged: (v) => settings.setShowStats(v),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Statistik zurücksetzen'),
                onTap: () {
                  settings.resetErrors();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Statistik wurde zurückgesetzt.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Elemente konfigurieren'),
                subtitle: const Text('Auswählen, welche Elemente abgefragt werden'),
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
        title: Text(widget.forceStats ? 'Fehler-Statistik' : 'Periodensystem'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
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
                    'Elemente mit Fehlern: $problemCount · Je dicker der rote Rahmen, desto mehr Probleme.',
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
