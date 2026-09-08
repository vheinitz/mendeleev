import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Element;
import '../data/elements_data.dart';
import '../data/electronegativity.dart';
import '../data/substances.dart';
import '../data/valences.dart';
import '../models/element.dart';
import '../services/app_settings.dart';
import '../services/distractors.dart';
import '../services/formula_parser.dart';
import '../widgets/colors.dart';
import 'config_screen.dart';
import 'find_element_screen.dart';

enum QuizType {
  group,
  symbolToName,
  nameToSymbol,
  latin,
  gap,
  valence,
  electronegativity,
  electronegativityToElement,
  substanceToFormula,
  formulaToSubstance,
  elementToMass,
  massToElement,
  amount,
}

class QuizMenuScreen extends StatelessWidget {
  const QuizMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz & Üben'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, '🔢', 'Gruppe nennen', 'Zu einem Element die Gruppe (1–18) finden', QuizType.group, Colors.red),
          _tile(context, '🔤', 'Symbol → Name', 'Zum Symbol den richtigen Namen finden', QuizType.symbolToName, Colors.blue),
          _tile(context, '🔡', 'Name → Symbol', 'Zum Namen die richtige Abkürzung finden', QuizType.nameToSymbol, Colors.indigo),
          _tile(context, '🏛️', 'Lateinische Namen', 'Deutsche und lateinische Namen zuordnen', QuizType.latin, Colors.purple),
          _tile(context, '🧩', 'Lücke füllen', 'Das fehlende Element zwischen Nachbarn finden', QuizType.gap, Colors.orange),
          _tile(context, '⚡', 'Wertigkeit', 'Die Wertigkeit eines Elements nennen', QuizType.valence, Colors.amber),
          _tile(context, '🎯', 'Element → Elektronegativität', 'Die EN eines Elements nennen', QuizType.electronegativity, Colors.deepOrange),
          _tile(context, '🧲', 'Elektronegativität → Element', 'Zum EN-Wert das Element finden', QuizType.electronegativityToElement, Colors.orangeAccent),
          _tile(context, '🔍', 'Element finden', 'Gesuchtes Element in der Tabelle anklicken (Zeit läuft!)', QuizType.electronegativity, Colors.pink, findMode: true),
          _tile(context, '🧪', 'Stoff → Formel', 'Zur Stoffbezeichnung die Formel finden', QuizType.substanceToFormula, Colors.teal),
          _tile(context, '📝', 'Formel → Stoff', 'Zur Formel den Stoffnamen finden', QuizType.formulaToSubstance, Colors.cyan),
          _tile(context, '⚖️', 'Element → Molmasse', 'Die Molmasse eines Elements nennen', QuizType.elementToMass, Colors.green),
          _tile(context, '🏋️', 'Molmasse → Element', 'Zur Molmasse das Element finden', QuizType.massToElement, Colors.lightGreen),
          _tile(context, '🧮', 'Stoffmenge (n, m, M)', 'Masse oder Stoffmenge berechnen', QuizType.amount, Colors.brown),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String icon, String title, String subtitle, QuizType type, Color color, {bool findMode = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Text(icon, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.play_circle, color: color, size: 30),
        tileColor: color.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => findMode ? const FindElementScreen() : QuizScreen(type: type)),
        ),
      ),
    );
  }
}

class Question {
  final String prompt;
  final Widget? header;
  final Element? answerElement; // für die Fehler-Statistik
  final String key; // eindeutig, verhindert Wiederholungen
  final Widget Function(BuildContext)? customPrompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? hint;

  Question({
    required this.prompt,
    this.header,
    this.answerElement,
    required this.key,
    this.customPrompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.hint,
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

  static const List<double> _niceMol = [0.5, 1, 2, 3, 4, 5, 10];

  late List<Question> _questions;
  late int _questionCount;
  final Set<String> _usedKeys = {};
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;
  bool _showHint = false;
  Timer? _advanceTimer;

  String get _title => switch (widget.type) {
        QuizType.group => 'Gruppe nennen',
        QuizType.symbolToName => 'Symbol → Name',
        QuizType.nameToSymbol => 'Name → Symbol',
        QuizType.latin => 'Lateinische Namen',
        QuizType.gap => 'Lücke füllen',
        QuizType.valence => 'Wertigkeit',
        QuizType.electronegativity => 'Element → Elektronegativität',
        QuizType.electronegativityToElement => 'Elektronegativität → Element',
        QuizType.substanceToFormula => 'Stoff → Formel',
        QuizType.formulaToSubstance => 'Formel → Stoff',
        QuizType.elementToMass => 'Element → Molmasse',
        QuizType.massToElement => 'Molmasse → Element',
        QuizType.amount => 'Stoffmenge (n, m, M)',
      };

  @override
  void initState() {
    super.initState();
    _questionCount = _targetCount();
    _questions = List.generate(_questionCount, (_) => _nextQuestion());
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  int _targetCount() {
    switch (widget.type) {
      case QuizType.substanceToFormula:
      case QuizType.formulaToSubstance:
      case QuizType.amount:
        return min(10, substances.length);
      default:
        final active = _settings.activeCount;
        return active == 0 ? 0 : min(10, active);
    }
  }

  Question _nextQuestion() {
    final q = _makeQuestion();
    _usedKeys.add(q.key);
    return q;
  }

  // ---------------------------------------------------------------- Helfer

  Element _pickElement(List<Element> candidates) {
    final unused = candidates.where((e) => !_usedKeys.contains('e${e.number}')).toList();
    if (unused.isNotEmpty) return unused[_random.nextInt(unused.length)];
    return candidates[_random.nextInt(candidates.length)];
  }

  Substance _pickSubstance(List<Substance> candidates, String prefix) {
    final unused = candidates.where((s) => !_usedKeys.contains('$prefix${s.formula}')).toList();
    if (unused.isNotEmpty) return unused[_random.nextInt(unused.length)];
    return candidates[_random.nextInt(candidates.length)];
  }

  ({List<String> options, int correctIndex}) _distinctOptions(String correct, List<String> candidates) {
    final others = <String>{};
    for (final c in candidates) {
      if (c != correct && c.isNotEmpty) others.add(c);
    }
    final opts = [correct, ...others.take(3)]..shuffle(_random);
    return (options: opts, correctIndex: opts.indexOf(correct));
  }

  ({List<String> options, int correctIndex}) _numericOptions(String correct, List<double> candidates) {
    final others = <String>{};
    for (final c in candidates) {
      if (c <= 0) continue;
      final s = _fmtNum(c);
      if (s != correct) others.add(s);
    }
    final opts = [correct, ...others.take(3)]..shuffle(_random);
    return (options: opts, correctIndex: opts.indexOf(correct));
  }

  String _fmtNum(double v) {
    if ((v - v.roundToDouble()).abs() < 0.005) return '${v.round()}';
    var s = v.toStringAsFixed(2);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ---------------------------------------------------------------- Fragen

  Question _makeQuestion() {
    switch (widget.type) {
      case QuizType.group:
        return _makeGroupQuestion();
      case QuizType.symbolToName:
      case QuizType.nameToSymbol:
        return _makeSymbolNameQuestion(toSymbol: widget.type == QuizType.nameToSymbol);
      case QuizType.latin:
        return _makeLatinQuestion();
      case QuizType.gap:
        return _makeGapQuestion();
      case QuizType.valence:
        return _makeValenceQuestion();
      case QuizType.electronegativity:
        return _makeElectronegativityQuestion();
      case QuizType.electronegativityToElement:
        return _makeElectronegativityToElementQuestion();
      case QuizType.substanceToFormula:
      case QuizType.formulaToSubstance:
        return _makeSubstanceQuestion(toFormula: widget.type == QuizType.substanceToFormula);
      case QuizType.elementToMass:
      case QuizType.massToElement:
        return _makeMolarMassQuestion(toMass: widget.type == QuizType.elementToMass);
      case QuizType.amount:
        return _makeAmountQuestion();
    }
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
      key: 'e${e.number}',
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
      header: toSymbol ? _ElementBadge(element: e, showSymbol: false) : _ElementBadge(element: e, showName: false),
      answerElement: e,
      key: 'e${e.number}',
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: toSymbol ? '${e.nameDe} hat das Symbol ${e.symbol}.' : '${e.symbol} steht für ${e.nameDe}.',
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
      header: askLatin ? _ElementBadge(element: e) : _ElementBadge(element: e, showName: false, nameOverride: e.nameLa),
      answerElement: e,
      key: 'e${e.number}',
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
    final unused = pool.where((t) => !_usedKeys.contains('e${t.hidden.number}')).toList();
    final chosen = (unused.isEmpty ? pool : unused)[_random.nextInt((unused.isEmpty ? pool : unused).length)];

    final options = _distinctOptions(chosen.hidden.nameDe, Distractors.names(chosen.hidden.nameDe, _random, count: 20));
    return Question(
      prompt: horizontal ? 'Welches Element fehlt in der Lücke?' : 'Welches Element steht zwischen den beiden?',
      answerElement: chosen.hidden,
      key: 'e${chosen.hidden.number}',
      customPrompt: (context) => _GapPrompt(left: chosen.left, right: chosen.right, horizontal: horizontal),
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: 'Zwischen ${chosen.left.nameDe} und ${chosen.right.nameDe} steht ${chosen.hidden.nameDe} (${chosen.hidden.symbol}).',
    );
  }

  Question _makeValenceQuestion() {
    final single = elements.where((e) => valencesOf(e.number).length == 1).toList();
    final active = single.where((e) => _settings.isActive(e.number)).toList();
    final e = _pickElement(active.isEmpty ? single : active);
    final correct = '${mainValence(e.number)}';
    final options = _distinctOptions(correct, const ['0', '1', '2', '3', '4', '5', '6', '7', '8']);
    return Question(
      prompt: 'Welche Wertigkeit hat dieses Element?',
      header: _ElementBadge(element: e),
      answerElement: e,
      key: 'e${e.number}',
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: '${e.nameDe} hat die Wertigkeit $correct.',
    );
  }

  Question _makeElectronegativityQuestion() {
    final withEn = elements.where((e) => electronegativityOf(e.number) != null).toList();
    final active = withEn.where((e) => _settings.isActive(e.number)).toList();
    final e = _pickElement(active.isEmpty ? withEn : active);
    final en = electronegativityOf(e.number)!;
    final correct = _fmtNum(en);
    // Falschantworten deutlich entfernt (außerhalb ±30 %), damit es um die
    // Größenordnung geht.
    final far = withEn.map((x) => electronegativityOf(x.number)!).toSet()
        .where((v) => (v - en).abs() > 0.3 * en).toList()
      ..shuffle(_random);
    final opts = [correct, ...far.take(3).map(_fmtNum)]..shuffle(_random);
    return Question(
      prompt: 'Welche Elektronegativität hat dieses Element?',
      header: _ElementBadge(element: e),
      answerElement: e,
      key: 'e${e.number}',
      options: opts,
      correctIndex: opts.indexOf(correct),
      explanation: '${e.nameDe} hat die Elektronegativität $correct.',
    );
  }

  Question _makeElectronegativityToElementQuestion() {
    final withEn = elements.where((e) => electronegativityOf(e.number) != null).toList();
    final active = withEn.where((e) => _settings.isActive(e.number)).toList();
    final e = _pickElement(active.isEmpty ? withEn : active);
    final en = electronegativityOf(e.number)!;
    // Elemente mit möglichst unterschiedlicher EN als Falschantworten.
    final sorted = withEn.where((x) => x.number != e.number).toList()
      ..sort((a, b) => (electronegativityOf(b.number)! - en).abs()
          .compareTo((electronegativityOf(a.number)! - en).abs()));
    final names = sorted.take(3).map((x) => x.nameDe).toList();
    final opts = [e.nameDe, ...names]..shuffle(_random);
    return Question(
      prompt: 'Welches Element hat die Elektronegativität ${_fmtNum(en)}?',
      header: _ClueBadge(text: 'EN ${_fmtNum(en)}'),
      answerElement: e,
      key: 'e${e.number}',
      options: opts,
      correctIndex: opts.indexOf(e.nameDe),
      explanation: 'Die Elektronegativität ${_fmtNum(en)} gehört zu ${e.nameDe} (${e.symbol}).',
    );
  }

  Question _makeSubstanceQuestion({required bool toFormula}) {
    final s = _pickSubstance(substances, toFormula ? 'sf' : 'fs');
    final options = toFormula
        ? _distinctOptions(s.formula, Distractors.similar(s.formula, substances.map((x) => x.formula).toList(), _random, count: 20))
        : _distinctOptions(s.name, Distractors.similar(s.name, substances.map((x) => x.name).toList(), _random, count: 20));
    return Question(
      prompt: toFormula ? 'Wie lautet die Formel dieses Stoffes?' : 'Wie heißt der Stoff mit dieser Formel?',
      header: _ClueBadge(text: toFormula ? s.name : s.formula),
      key: '${toFormula ? 'sf' : 'fs'}${s.formula}',
      options: options.options,
      correctIndex: options.correctIndex,
      explanation: toFormula ? '${s.name} hat die Formel ${s.formula}.' : '${s.formula} ist ${s.name}.',
    );
  }

  Question _makeMolarMassQuestion({required bool toMass}) {
    final active = elements.where((e) => _settings.isActive(e.number)).toList();
    final e = _pickElement(active.isEmpty ? elements : active);
    final mass = _fmtNum(e.mass);

    if (toMass) {
      final sorted = elements.map((x) => x.mass).toSet().toList()
        ..sort((a, b) => (a - e.mass).abs().compareTo((b - e.mass).abs()));
      final options = _numericOptions(mass, sorted.where((m) => (m - e.mass).abs() > 0.01).take(8).toList());
      return Question(
        prompt: 'Wie groß ist die Molmasse dieses Elements?',
        header: _ElementBadge(element: e),
        answerElement: e,
        key: 'e${e.number}',
        options: options.options,
        correctIndex: options.correctIndex,
        explanation: 'Die Molmasse von ${e.nameDe} ist $mass g/mol.',
      );
    } else {
      final sorted = elements.toList()..sort((a, b) => (a.mass - e.mass).abs().compareTo((b.mass - e.mass).abs()));
      final names = sorted.where((x) => x.number != e.number).take(3).map((x) => x.nameDe).toList();
      final opts = [e.nameDe, ...names]..shuffle(_random);
      return Question(
        prompt: 'Welches Element hat diese Molmasse?',
        header: _ClueBadge(text: '$mass g/mol'),
        answerElement: e,
        key: 'e${e.number}',
        options: opts,
        correctIndex: opts.indexOf(e.nameDe),
        explanation: '$mass g/mol ist die Molmasse von ${e.nameDe} (${e.symbol}).',
      );
    }
  }

  Question _makeAmountQuestion() {
    final s = _pickSubstance(substances, 'am');
    final M = FormulaParser.parse(s.formula).totalMass;
    final n = _niceMol[_random.nextInt(_niceMol.length)];
    final m = n * M;
    final givenN = _random.nextBool();

    final hint = 'M(${s.formula}) = ${_fmtNum(M)} g/mol';
    final header = _ClueBadge(text: '${s.name}\n${s.formula}');

    if (givenN) {
      final options = _numericOptions(_fmtNum(m), [m * 0.5, m * 2, m + M, m - M, M, m + 1, m * 3]);
      return Question(
        prompt: 'Berechne die Masse m von ${_fmtNum(n)} mol ${s.name} (${s.formula}).',
        header: header,
        key: 'am${s.formula}',
        options: options.options,
        correctIndex: options.correctIndex,
        hint: hint,
        explanation: 'm = n · M = ${_fmtNum(n)} mol · ${_fmtNum(M)} g/mol = ${_fmtNum(m)} g',
      );
    } else {
      final options = _numericOptions(_fmtNum(n), [n + 1, n - 1, n * 2, n / 2, n + 0.5, n - 0.5, n * 3]);
      return Question(
        prompt: 'Berechne die Stoffmenge n von ${_fmtNum(m)} g ${s.name} (${s.formula}).',
        header: header,
        key: 'am${s.formula}',
        options: options.options,
        correctIndex: options.correctIndex,
        hint: hint,
        explanation: 'n = m ÷ M = ${_fmtNum(m)} g ÷ ${_fmtNum(M)} g/mol = ${_fmtNum(n)} mol',
      );
    }
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
                Text('Du hast $_score von $_questionCount richtig beantwortet.', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
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

    final q = _questions[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Auto-Weiter',
            onPressed: _openAutoAdvanceSettings,
          ),
        ],
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
          if (q.hint != null) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => setState(() => _showHint = !_showHint),
              child: Text(_showHint ? 'Tipp ausblenden' : '💡 Tipp anzeigen'),
            ),
            if (_showHint)
              Text(q.hint!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.teal, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 16),
          for (var i = 0; i < q.options.length; i++) _optionButton(q, i),
          if (_answered) ...[
            const SizedBox(height: 16),
            Card(
              color: _selected == q.correctIndex ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(_selected == q.correctIndex ? '✅ Richtig!' : '❌ Leider falsch.', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        trailing: color == Colors.green
            ? const Icon(Icons.check_circle, color: Colors.green)
            : (color == Colors.red ? const Icon(Icons.cancel, color: Colors.red) : null),
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
      } else if (q.answerElement != null) {
        _settings.recordError(q.answerElement!.number);
      }
    });
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _advanceTimer?.cancel();
    final seconds = _settings.autoAdvanceSeconds;
    if (seconds > 0 && !_finished) {
      _advanceTimer = Timer(Duration(seconds: seconds), () {
        if (mounted && _answered && !_finished) _next();
      });
    }
  }

  void _openAutoAdvanceSettings() {
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
                child: Text('Auto-Weiter nach Antwort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              for (final s in const [0, 2, 3, 5])
                ListTile(
                  title: Text(s == 0 ? 'Aus (nur per Knopf)' : '$s Sekunden'),
                  trailing: _settings.autoAdvanceSeconds == s ? const Icon(Icons.check, color: Colors.teal) : null,
                  onTap: () {
                    _settings.setAutoAdvanceSeconds(s);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    _advanceTimer?.cancel();
    setState(() {
      if (_index == _questionCount - 1) {
        _finished = true;
      } else {
        _index++;
        _selected = null;
        _answered = false;
        _showHint = false;
      }
    });
  }

  void _restart() {
    _advanceTimer?.cancel();
    setState(() {
      _usedKeys.clear();
      _questions = List.generate(_questionCount, (_) => _nextQuestion());
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _showHint = false;
      _finished = false;
    });
  }
}

class _ElementBadge extends StatelessWidget {
  final Element element;
  final bool showSymbol;
  final bool showName;
  final String? nameOverride;

  const _ElementBadge({required this.element, this.showSymbol = true, this.showName = true, this.nameOverride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: elementColor(element), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text('${element.number}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
          if (showSymbol) Text(element.symbol, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          if (showName) Text(nameOverride ?? element.nameDe, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ClueBadge extends StatelessWidget {
  final String text;

  const _ClueBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          decoration: BoxDecoration(color: elementColor(e), borderRadius: BorderRadius.circular(8)),
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
          ? Row(mainAxisSize: MainAxisSize.min, children: [cell(left), questionMark, cell(right)])
          : Column(mainAxisSize: MainAxisSize.min, children: [cell(left), questionMark, cell(right)]),
    );
  }
}
