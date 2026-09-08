import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Element;
import '../data/elements_data.dart';
import '../models/element.dart';
import '../services/app_settings.dart';
import '../widgets/periodic_table.dart';
import 'config_screen.dart';

/// Zeitbasiertes Quiz: Ein Elementname wird angezeigt, das Kind muss das
/// Element innerhalb der eingestellten Zeit in der Tabelle finden und
/// anklicken.
class FindElementScreen extends StatefulWidget {
  const FindElementScreen({super.key});

  @override
  State<FindElementScreen> createState() => _FindElementScreenState();
}

class _FindElementScreenState extends State<FindElementScreen> {
  final Random _random = Random();
  final AppSettings _settings = AppSettings.instance;

  late int _totalRounds;
  int _round = 0;
  int _score = 0;
  Element? _target;
  Element? _wrongPick;
  String? _feedback; // 'correct' | 'wrong' | 'timeout'
  bool _finished = false;

  final Set<int> _usedNumbers = {};
  final ValueNotifier<int> _remainingMs = ValueNotifier(0);
  int _totalMs = 5000;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final active = _settings.activeCount;
    _totalRounds = active == 0 ? 0 : min(10, active);
    if (_totalRounds > 0) _prepareRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remainingMs.dispose();
    super.dispose();
  }

  Element _pickUnused() {
    final pool = elements.where((e) => _settings.isActive(e.number)).toList();
    final unused = pool.where((e) => !_usedNumbers.contains(e.number)).toList();
    if (unused.isNotEmpty) return unused[_random.nextInt(unused.length)];
    return pool[_random.nextInt(pool.length)];
  }

  void _prepareRound() {
    _target = _pickUnused();
    _usedNumbers.add(_target!.number);
    _wrongPick = null;
    _feedback = null;
    _totalMs = _settings.findSeconds * 1000;
    _remainingMs.value = _totalMs;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      _remainingMs.value -= 100;
      if (_remainingMs.value <= 0) {
        t.cancel();
        _timeout();
      }
    });
  }

  void _answer(Element e) {
    if (_feedback != null) return;
    _timer?.cancel();
    setState(() {
      if (e.number == _target!.number) {
        _feedback = 'correct';
        _score++;
      } else {
        _wrongPick = e;
        _feedback = 'wrong';
        _settings.recordError(_target!.number);
      }
    });
  }

  void _timeout() {
    if (_feedback != null) return;
    _timer?.cancel();
    setState(() {
      _feedback = 'timeout';
      _settings.recordError(_target!.number);
    });
  }

  Map<int, Color> get _highlights {
    if (_feedback == null) return const {};
    return {
      _target!.number: Colors.green,
      if (_wrongPick != null && _wrongPick!.number != _target!.number) _wrongPick!.number: Colors.red,
    };
  }

  void _next() {
    if (_round + 1 >= _totalRounds) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _round++;
        _prepareRound();
      });
    }
  }

  void _restart() {
    setState(() {
      _usedNumbers.clear();
      _round = 0;
      _score = 0;
      _finished = false;
      _prepareRound();
    });
  }

  void _openTimeSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Zeit pro Element', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              for (final s in const [3, 5, 10, 15])
                ListTile(
                  title: Text('$s Sekunden'),
                  trailing: _settings.findSeconds == s ? const Icon(Icons.check, color: Colors.teal) : null,
                  onTap: () {
                    _settings.setFindSeconds(s);
                    Navigator.pop(context);
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
    if (_totalRounds == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Element finden'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text('Es sind keine Elemente aktiviert.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Aktiviere zuerst einige Elemente in der Konfiguration.', textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigScreen())),
                  icon: const Icon(Icons.tune),
                  label: const Text('Elemente konfigurieren'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Element finden'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_score >= 8 ? '🎉' : _score >= 5 ? '👍' : '💪', style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                const Text('Fertig!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Du hast $_score von $_totalRounds Elementen gefunden.', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: _restart, icon: const Icon(Icons.replay), label: const Text('Nochmal üben')),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Zurück zum Menü')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Element finden'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.timer_outlined), onPressed: _openTimeSettings),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text('Runde ${_round + 1} von $_totalRounds · Punkte: $_score'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    'Finde: ${_target!.nameDe}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _remainingMs,
                  builder: (context, ms, _) {
                    final seconds = (ms / 1000).ceil().clamp(0, _settings.findSeconds);
                    return Column(
                      children: [
                        LinearProgressIndicator(value: _totalMs == 0 ? 0 : ms / _totalMs, minHeight: 8),
                        const SizedBox(height: 4),
                        Text('⏱ $seconds s', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
                if (_feedback != null) ...[
                  const SizedBox(height: 8),
                  _FeedbackCard(feedback: _feedback!, target: _target!),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_round + 1 >= _totalRounds ? 'Ergebnis anzeigen' : 'Weiter'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: PeriodicTableGrid(
                  onTap: _feedback == null ? _answer : null,
                  highlights: _highlights,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final String feedback;
  final Element target;

  const _FeedbackCard({required this.feedback, required this.target});

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch (feedback) {
      'correct' => ('✅', 'Richtig!', Colors.green),
      'wrong' => ('❌', 'Falsch!', Colors.red),
      _ => ('⏰', 'Zeit abgelaufen!', Colors.orange),
    };
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text('$icon $text', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Gesucht war ${target.nameDe} (${target.symbol}).', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
