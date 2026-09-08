import 'dart:math';
import 'package:flutter/material.dart' hide Element;
import '../data/elements_data.dart';
import '../models/element.dart';
import '../services/app_settings.dart';
import '../services/distractors.dart';
import '../widgets/colors.dart';
import 'config_screen.dart';

enum QuizType { group, symbolToName, nameToSymbol, latin, gap }

class QuizMenuScreen extends StatelessWidget {
  const QuizMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz & Üben'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _quizTile(
            context,
            icon: '🔢',
            title: 'Gruppe nennen',
            subtitle: 'Zu einem Element die richtige Gruppe (1–18) finden',
            type: QuizType.group,
            color: Colors.red,
          ),
          _quizTile(
            context,
            icon: '🔤',
            title: 'Symbol → Name',
            subtitle: 'Zum Symbol den richtigen Namen finden',
            type: QuizType.symbolToName,
            color: Colors.blue,
          ),
          _quizTile(
            context,
            icon: '🔡',
            title: 'Name → Symbol',
            subtitle: 'Zum Namen die richtige Abkürzung finden',
            type: QuizType.nameToSymbol,
            color: Colors.indigo,
          ),
          _quizTile(
            context,
            icon: '🏛️',
            title: 'Lateinische Namen',
            subtitle: 'Deutsche und lateinische Namen zuordnen',
            type: QuizType.latin,
            color: Colors.purple,
          ),
          _quizTile(
            context,
            icon: '🧩',
            title: 'Lücke füllen',
            subtitle: 'Das fehlende Element zwischen Nachbarn finden',
            type: QuizType.gap,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _quizTile(BuildContext context, {required String icon, required String title, required String subtitle, required QuizType type, required Color color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(icon, style: const TextStyle(fontSize: 36)),
        title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.play_circle, color: color, size: 32),
        tileColor: color.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuizScreen(type: type)),
        ),
      ),
    );
  }
}

class Question {
  final String prompt;
  final Widget? header; // optionales Hinweis-Kästchen (verrät die Antwort nicht)
  final Element answerElement; // das gesuchte Element (für Statistik)
  final Widget Function(BuildContext)? customPrompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({
    required this.prompt,
    this.header,
    required this.answerElement,
    this.customPrompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  final QuizType type;

  const QuizScreen({super.key, required this.type});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();
  final AppSettings _settings = AppSettings.instance;

  late List<Question> _questions;
  late int _questionCount;
  final Set<int> _usedNumbers = {};
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  String get _title => switch (widget.type) {
        QuizType.group => 'Gruppe nennen',
        QuizType.symbolToName => 'Symbol → Name',
        QuizType.nameToSymbol => 'Name → Symbol',
        QuizType.latin => 'Lateinische Namen',
        QuizType.gap => 'Lücke füllen',
      };

  @override
  void initState() {
    super.initState();
    final active = _settings.activeCount;
    _questionCount = active == 0 ? 0 : min(10, active);
    _questions = List.generate(_questionCount, (_) => _nextQuestion());
  }

  /// Erzeugt eine Frage und merkt sich das gesuchte Element, damit es sich
  /// innerhalb der Session nicht wiederholt.
  Question _nextQuestion() {
    final q = _makeQuestion();
    _usedNumbers.add(q.answerElement.number);
    return q;
  }

  // ---------------------------------------------------------------- Fragen

  Question _makeQuestion() {
    // Jeder Fragetyp versucht zuerst, ein aktives, noch nicht verwendetes
    // Element zu wählen; sonst wird auf alle Elemente zurückgegriffen.
    switch (widget.type) {
      case QuizType.group:
        return _makeGroupQuestion();
      case QuizType.symbolToName:
        return _makeSymbolNameQuestion(toSymbol: false);
      case QuizType.nameToSymbol:
        return _makeSymbolNameQuestion(toSymbol: true);
      case QuizType.latin:
        return _makeLatinQuestion();
      case QuizType.gap:
        return _makeGapQuestion();
    }
  }

  Element _pickElement(List<Element> candidates) {
    final unused = candidates.where((e) => !_usedNumbers.contains(e.number)).toList();
    if (unused.isNotEmpty) return unused[_random.nextInt(unused.length)];
    return candidates[_random.nextInt(candidates.length)];
  }

  Question _makeGroupQuestion() {
    final activeMain = elements.where((e) => e.series == null && _settings.isActive(e.number)).toList();
    final allMain = elements.where((e) => e.series == null).toList();
    final e = _pickElement(activeMain.isEmpty ? allMain : activeMain);

    final options = _distinctOptions('${e.group}', [for (var g = 1; g <= 18; g++) '$g']);
    return Question(
      prompt: 'In welcher Gruppe steht dieses Element?',
      header: _ElementBadge(element: e),
      answerElement: e,
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: '${e.nameDe} (${e.symbol}) steht in Gruppe ${e.group}.',
    );
  }

  Question _makeSymbolNameQuestion({required bool toSymbol}) {
    final active = elements.where((e) => _settings.isActive(e.number)).toList();
    final e = _pickElement(active.isEmpty ? elements : active);

    final options = toSymbol
        ? _distinctOptions(e.symbol, Distractors.symbols(e.symbol, _random, count: 20))
        : _distinctOptions(e.nameDe, Distractors.names(e.nameDe, _random, count: 20));

    return Question(
      prompt: toSymbol ? 'Wie lautet das Symbol von ${e.nameDe}?' : 'Wie heißt das Element mit dem Symbol ${e.symbol}?',
      // Nur den Hinweis anzeigen, nicht die Antwort:
      header: toSymbol
          ? _ElementBadge(element: e, showSymbol: false)
          : _ElementBadge(element: e, showName: false),
      answerElement: e,
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: toSymbol
          ? '${e.nameDe} hat das Symbol ${e.symbol}.'
          : '${e.symbol} steht für ${e.nameDe}.',
    );
  }

  Question _makeLatinQuestion() {
    final activeLatin = elements.where((e) => e.nameDe != e.nameLa && _settings.isActive(e.number)).toList();
    final allLatin = elements.where((e) => e.nameDe != e.nameLa).toList();
    final e = _pickElement(activeLatin.isEmpty ? allLatin : activeLatin);

    final askLatin = _random.nextBool();
    final options = askLatin
        ? _distinctOptions(e.nameLa, Distractors.latin(e.nameLa, _random, count: 20))
        : _distinctOptions(e.nameDe, Distractors.names(e.nameDe, _random, count: 20));

    return Question(
      prompt: askLatin
          ? 'Wie lautet der lateinische Name von ${e.nameDe}?'
          : 'Welches Element hat den lateinischen Namen ${e.nameLa}?',
      // Bei der Frage nach dem deutschen Namen nur den lateinischen Namen zeigen
      // (und umgekehrt), damit die Antwort nicht verraten wird.
      header: askLatin
          ? _ElementBadge(element: e)
          : _ElementBadge(element: e, showName: false, nameOverride: e.nameLa),
      answerElement: e,
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: askLatin
          ? '${e.nameDe} heißt auf Lateinisch ${e.nameLa}.'
          : '${e.nameLa} ist der lateinische Name von ${e.nameDe}.',
    );
  }

  Question _makeGapQuestion() {
    final horizontal = _random.nextBool();
    final rows = horizontal ? [...periodRows, ...fBlockRows] : groupColumns;

    // Alle möglichen Lücken mit aktivem gesuchtem Element sammeln.
    final activeTriples = <({Element left, Element hidden, Element right})>[];
    final allTriples = <({Element left, Element hidden, Element right})>[];
    for (final row in rows) {
      for (var i = 1; i < row.length - 1; i++) {
        final triple = (left: row[i - 1], hidden: row[i], right: row[i + 1]);
        allTriples.add(triple);
        if (_settings.isActive(triple.hidden.number)) activeTriples.add(triple);
      }
    }

    final pool = activeTriples.isEmpty ? allTriples : activeTriples;
    final unused = pool.where((t) => !_usedNumbers.contains(t.hidden.number)).toList();
    final chosen = (unused.isEmpty ? pool : unused)[_random.nextInt((unused.isEmpty ? pool : unused).length)];

    final options = _distinctOptions(chosen.hidden.nameDe, Distractors.names(chosen.hidden.nameDe, _random, count: 20));

    return Question(
      prompt: horizontal ? 'Welches Element fehlt in der Lücke?' : 'Welches Element steht zwischen den beiden?',
      answerElement: chosen.hidden,
      customPrompt: (context) => _GapPrompt(left: chosen.left, right: chosen.right, horizontal: horizontal),
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: 'Zwischen ${chosen.left.nameDe} und ${chosen.right.nameDe} steht ${chosen.hidden.nameDe} (${chosen.hidden.symbol}).',
    );
  }

  /// Nimmt die richtige Antwort und einen Pool ähnlicher Kandidaten und
  /// baut daraus die Auswahl (richtige Antwort + 3 Distraktoren, gemischt).
  ({List<String> options, int correctIndex}) _distinctOptions(String correct, List<String> candidates) {
    final others = <String>{};
    for (final c in candidates) {
      if (c != correct && c.isNotEmpty) others.add(c);
    }
    final opts = [correct, ...others.take(3)]..shuffle(_random);
    return (options: opts, correctIndex: opts.indexOf(correct));
  }

  // ---------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    if (_questionCount == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(_title), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                const Text(
                  'Es sind keine Elemente aktiviert.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aktiviere zuerst einige Elemente in der Konfiguration.',
                  textAlign: TextAlign.center,
                ),
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
        appBar: AppBar(title: Text(_title), centerTitle: true),
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
                Text(
                  'Du hast $_score von $_questionCount richtig beantwortet.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay),
                  label: const Text('Nochmal üben'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Zurück zum Menü'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                LinearProgressIndicator(value: _index / _questionCount, minHeight: 6),
                const SizedBox(height: 6),
                Text('Frage ${_index + 1} von $_questionCount · Punkte: $_score'),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (q.header != null) ...[
            Center(child: q.header!),
            const SizedBox(height: 8),
          ],
          Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          if (q.customPrompt != null) ...[
            const SizedBox(height: 12),
            q.customPrompt!(context),
          ],
          const SizedBox(height: 20),
          for (var i = 0; i < q.options.length; i++) _optionButton(q, i),
          if (_answered) ...[
            const SizedBox(height: 16),
            Card(
              color: _selected == q.correctIndex ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      _selected == q.correctIndex ? '✅ Richtig!' : '❌ Leider falsch.',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(q.explanation, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _next,
              child: Text(_index == _questionCount - 1 ? 'Ergebnis anzeigen' : 'Weiter'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionButton(Question q, int i) {
    Color? color;
    if (_answered) {
      if (i == q.correctIndex) {
        color = Colors.green;
      } else if (i == _selected) {
        color = Colors.red;
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: color?.withValues(alpha: 0.15),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: color != null ? BorderSide(color: color, width: 2) : BorderSide.none,
        ),
        title: Text(q.options[i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: color == Colors.green ? const Icon(Icons.check_circle, color: Colors.green) : (color == Colors.red ? const Icon(Icons.cancel, color: Colors.red) : null),
        onTap: _answered ? null : () => _answer(i),
      ),
    );
  }

  void _answer(int i) {
    final q = _questions[_index];
    setState(() {
      _selected = i;
      _answered = true;
      if (i == q.correctIndex) {
        _score++;
      } else {
        _settings.recordError(q.answerElement.number);
      }
    });
  }

  void _next() {
    setState(() {
      if (_index == _questionCount - 1) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
        _answered = false;
      }
    });
  }

  void _restart() {
    setState(() {
      _usedNumbers.clear();
      _questions = List.generate(_questionCount, (_) => _nextQuestion());
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _finished = false;
    });
  }
}

class _ElementBadge extends StatelessWidget {
  final Element element;
  final bool showSymbol;
  final bool showName;
  final String? nameOverride;

  const _ElementBadge({
    required this.element,
    this.showSymbol = true,
    this.showName = true,
    this.nameOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: elementColor(element),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('${element.number}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
          if (showSymbol)
            Text(element.symbol, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          if (showName)
            Text(nameOverride ?? element.nameDe, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _GapPrompt extends StatelessWidget {
  final Element left;
  final Element right;
  final bool horizontal;

  const _GapPrompt({required this.left, required this.right, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    Widget cell(Element e) => Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: elementColor(e),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${e.number}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              Text(e.symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        );

    Widget questionMark = Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      alignment: Alignment.center,
      child: const Text('?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );

    return Center(
      child: horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [cell(left), questionMark, cell(right)],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [cell(left), questionMark, cell(right)],
            ),
    );
  }
}
