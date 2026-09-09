import 'package:flutter/material.dart';
import '../data/elements_data.dart';
import '../data/substances.dart';
import '../services/formula_parser.dart';
import '../services/l10n.dart';
import '../widgets/colors.dart';

class MolarMassScreen extends StatefulWidget {
  const MolarMassScreen({super.key});

  @override
  State<MolarMassScreen> createState() => _MolarMassScreenState();
}

class _MolarMassScreenState extends State<MolarMassScreen> {
  final TextEditingController _controller = TextEditingController();
  MolarMassResult? _result;
  String _formula = '';

  List<Substance> get _suggestions {
    final query = _controller.text.trim().toLowerCase();
    final source = query.isEmpty
        ? substances.take(3)
        : substances.where((s) =>
            s.name.toLowerCase().contains(query) ||
            substanceName(s).toLowerCase().contains(query) ||
            s.formula.toLowerCase().contains(query));
    return source.take(3).toList();
  }

  void _calculate() {
    final text = _controller.text.trim();
    setState(() {
      _formula = text;
      _result = FormulaParser.parse(text);
    });
  }

  void _select(Substance s) {
    _controller.text = s.formula;
    _calculate();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = null;
      _formula = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    final showNoHit = _controller.text.trim().isNotEmpty && suggestions.isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Molmasse-Rechner')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr('Gib einen Stoffnamen oder eine Formel ein.'), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: tr('z. B. Wasser oder H2O'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.science),
              suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _calculate(),
          ),
          const SizedBox(height: 10),
          if (suggestions.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final s in suggestions)
                  ActionChip(
                    avatar: const Icon(Icons.science_outlined, size: 18),
                    label: Text('${substanceName(s)} (${s.formula})'),
                    onPressed: () => _select(s),
                  ),
              ],
            ),
          if (showNoHit)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                tr('Kein Treffer – setze das Feld zurück und gib die Formel direkt ein.'),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: Text(tr('Molmasse berechnen')),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          const SizedBox(height: 20),
          if (_result != null) _ResultView(result: _result!, formula: _formula),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final MolarMassResult result;
  final String formula;

  const _ResultView({required this.result, required this.formula});

  @override
  Widget build(BuildContext context) {
    if (result.errors.isNotEmpty) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('⚠️ Fehler'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              for (final e in result.errors) Text('• ${tr(e)}'),
            ],
          ),
        ),
      );
    }

    final entries = result.counts.entries.toList()
      ..sort((a, b) => elementBySymbol[a.key]!.number.compareTo(elementBySymbol[b.key]!.number));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(formula, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tr('Molmasse'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(
                  '${result.totalMass.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')} g/mol',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(tr('Zusammensetzung'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (final entry in entries) _BreakdownRow(symbol: entry.key, count: entry.value),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String symbol;
  final int count;

  const _BreakdownRow({required this.symbol, required this.count});

  @override
  Widget build(BuildContext context) {
    final e = elementBySymbol[symbol]!;
    final subtotal = e.mass * count;
    return ListTile(
      dense: true,
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: elementColor(e), borderRadius: BorderRadius.circular(6)),
        child: Text(e.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      title: Text('${elementName(e)} · $count'),
      subtitle: Text('${e.massLabel} g/mol × $count'),
      trailing: Text(
        '${subtotal.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')} g/mol',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
