import 'package:flutter/material.dart' hide Element;
import '../data/density.dart';
import '../data/electronegativity.dart';
import '../data/elements_data.dart';
import '../data/valences.dart';
import '../models/element.dart';
import '../services/electron_shells.dart';
import 'colors.dart';
import 'electron_shell_diagram.dart';

/// Wiederverwendbare Periodensystem-Tabelle.
///
/// * [onTap] – Aktion beim Antippen eines Elements (z. B. Details oder Umschalten)
/// * [errorCounts] – Fehler je Ordnungszahl -> roter Rahmen (Statistik)
/// * [disabledNumbers] – ausgeblendete Elemente -> grau dargestellt
/// * [highlights] – farbige Markierungen je Ordnungszahl (z. B. richtig/falsch)
class PeriodicTableGrid extends StatelessWidget {
  final void Function(Element element)? onTap;
  final Map<int, int>? errorCounts;
  final Set<int>? disabledNumbers;
  final Map<int, Color>? highlights;
  final double cellW;
  final double cellH;

  const PeriodicTableGrid({
    super.key,
    this.onTap,
    this.errorCounts,
    this.disabledNumbers,
    this.highlights,
    this.cellW = 34,
    this.cellH = 46,
  });

  Element? _mainElementAt(int period, int group) {
    for (final e in elements) {
      if (e.period == period && e.group == group && e.series == null) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 4),
        for (var p = 1; p <= 7; p++) _buildPeriodRow(p),
        const SizedBox(height: 12),
        _buildFBlockRow('Lanthanoide', fBlockRows[0]),
        const SizedBox(height: 4),
        _buildFBlockRow('Actinoide', fBlockRows[1]),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        const SizedBox(width: 22),
        for (var g = 1; g <= 18; g++)
          SizedBox(
            width: cellW,
            child: Text(
              '$g',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
      ],
    );
  }

  Widget _buildPeriodRow(int period) {
    final children = <Widget>[
      SizedBox(
        width: 22,
        child: Text(
          '$period',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ),
    ];
    for (var g = 1; g <= 18; g++) {
      final e = _mainElementAt(period, g);
      if (e != null) {
        children.add(_cell(e));
      } else if ((period == 6 || period == 7) && g == 3) {
        children.add(_markerCell(period == 6 ? 'La–Lu' : 'Ac–Lr'));
      } else {
        children.add(SizedBox(width: cellW, height: cellH));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(children: children),
    );
  }

  Widget _buildFBlockRow(String label, List<Element> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ),
          for (final e in row) _cell(e),
        ],
      ),
    );
  }

  Widget _markerCell(String text) {
    return Container(
      width: cellW,
      height: cellH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(3),
        color: Colors.grey.shade100,
      ),
      child: Text(text, style: const TextStyle(fontSize: 8, color: Colors.grey)),
    );
  }

  Widget _cell(Element e) {
    final disabled = disabledNumbers?.contains(e.number) ?? false;
    final errors = errorCounts?[e.number] ?? 0;
    final highlight = highlights?[e.number];

    final Color bg = disabled ? Colors.grey.shade300 : elementColor(e);
    Border? border;
    if (highlight != null) {
      border = Border.all(color: highlight, width: 2.5);
    } else if (errors > 0) {
      final width = 1.0 + errors.clamp(0, 5).toDouble();
      border = Border.all(color: Colors.red.withValues(alpha: (0.4 + errors.clamp(0, 5) * 0.1).clamp(0.0, 1.0)), width: width);
    }

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(e),
      child: Container(
        width: cellW,
        height: cellH,
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(3),
          border: border,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${e.number}',
                    style: TextStyle(fontSize: 7, color: disabled ? Colors.black38 : Colors.black54),
                  ),
                  Text(
                    e.symbol,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: disabled ? Colors.black38 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (errors > 0)
              Positioned(
                right: 1,
                bottom: 0,
                child: Text(
                  '$errors',
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Detail-Ansicht eines Elements als Bottom-Sheet (inkl. Atommodell).
void showElementDetails(BuildContext context, Element e) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: elementColor(e),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${e.number}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                        Text(e.symbol, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.nameDe, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Lateinisch: ${e.nameLa}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    ElectronShellDiagram(atomicNumber: e.number, size: 170),
                    const SizedBox(height: 8),
                    Text(
                      'Schalen: ${shellText(e.number)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Ordnungszahl', value: '${e.number}'),
              _InfoRow(label: 'Gruppe', value: '${e.group}'),
              _InfoRow(label: 'Periode', value: '${e.period}'),
              _InfoRow(label: 'Wertigkeit', value: valenceLabel(e.number)),
              _InfoRow(label: 'Elektronegativität', value: electronegativityLabel(e.number)),
              _InfoRow(label: 'Dichte', value: densityLabel(e.number)),
              _InfoRow(label: 'Kategorie', value: e.category),
              _InfoRow(label: 'Molmasse', value: '${e.massLabel} g/mol'),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Schließen'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
