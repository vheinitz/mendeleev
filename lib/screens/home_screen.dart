import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../services/l10n.dart';
import 'config_screen.dart';
import 'periodic_table_screen.dart';
import 'quiz_screen.dart';
import 'molar_mass_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openLanguageSettings(BuildContext context) {
    final settings = AppSettings.instance;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(tr('Sprache'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final lang in const [('de', 'Deutsch'), ('en', 'English'), ('ru', 'Русский')])
              ListTile(
                title: Text(lang.$2),
                trailing: settings.language == lang.$1 ? const Icon(Icons.check, color: Colors.teal) : null,
                onTap: () {
                  settings.setLanguage(lang.$1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Periodensystem Lernprogramm')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: tr('Sprache'),
            onPressed: () => _openLanguageSettings(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🧪', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                tr('Chemie lernen leicht gemacht!'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _MenuButton(
                icon: '🗂️',
                title: tr('Periodensystem'),
                subtitle: tr('Alle Elemente als Tabelle ansehen und nachschlagen'),
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeriodicTableScreen())),
              ),
              _MenuButton(
                icon: '🎯',
                title: tr('Quiz & Üben'),
                subtitle: tr('Gruppe, Symbole, Lücken und lateinische Namen'),
                color: Colors.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizMenuScreen())),
              ),
              _MenuButton(
                icon: '⚖️',
                title: tr('Molmasse-Rechner'),
                subtitle: tr('Molmasse einer chemischen Formel berechnen'),
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MolarMassScreen())),
              ),
              _MenuButton(
                icon: '📊',
                title: tr('Fehler-Statistik'),
                subtitle: tr('Problem-Elemente mit rotem Rahmen anzeigen'),
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PeriodicTableScreen(forceStats: true))),
              ),
              _MenuButton(
                icon: '⚙️',
                title: tr('Elemente konfigurieren'),
                subtitle: tr('Auswählen, welche Elemente abgefragt werden'),
                color: Colors.blueGrey,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(icon, style: const TextStyle(fontSize: 36)),
        title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward, color: color),
        tileColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
