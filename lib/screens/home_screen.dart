import 'package:flutter/material.dart';
import 'config_screen.dart';
import 'periodic_table_screen.dart';
import 'quiz_screen.dart';
import 'molar_mass_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodensystem Lernprogramm'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🧪',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chemie lernen leicht gemacht!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _MenuButton(
                icon: '🗂️',
                title: 'Periodensystem',
                subtitle: 'Alle Elemente als Tabelle ansehen und nachschlagen',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeriodicTableScreen()),
                ),
              ),
              _MenuButton(
                icon: '🎯',
                title: 'Quiz & Üben',
                subtitle: 'Gruppe, Symbole, Lücken und lateinische Namen',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizMenuScreen()),
                ),
              ),
              _MenuButton(
                icon: '⚖️',
                title: 'Molmasse-Rechner',
                subtitle: 'Molmasse einer chemischen Formel berechnen',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MolarMassScreen()),
                ),
              ),
              _MenuButton(
                icon: '📊',
                title: 'Fehler-Statistik',
                subtitle: 'Problem-Elemente mit rotem Rahmen anzeigen',
                color: Colors.red,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeriodicTableScreen(forceStats: true)),
                ),
              ),
              _MenuButton(
                icon: '⚙️',
                title: 'Elemente konfigurieren',
                subtitle: 'Auswählen, welche Elemente abgefragt werden',
                color: Colors.blueGrey,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfigScreen()),
                ),
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

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

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
