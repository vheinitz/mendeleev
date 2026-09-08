import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/electron_shells.dart';

/// Grafisches Bohr'sches Atommodell: konzentrische Schalen mit Elektronen.
class ElectronShellDiagram extends StatelessWidget {
  final int atomicNumber;
  final double size;

  const ElectronShellDiagram({super.key, required this.atomicNumber, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ShellPainter(shells: electronShells(atomicNumber)),
    );
  }
}

class _ShellPainter extends CustomPainter {
  final List<int> shells;

  _ShellPainter({required this.shells});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 6;
    final ringGap = maxRadius / shells.length;

    // Atomkern.
    canvas.drawCircle(center, 6, Paint()..color = Colors.red.shade400);

    final ringPaint = Paint()
      ..color = Colors.blueGrey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dotPaint = Paint()..color = Colors.blue.shade700;

    for (var i = 0; i < shells.length; i++) {
      final r = ringGap * (i + 1);
      canvas.drawCircle(center, r, ringPaint);

      final count = shells[i];
      final dotRadius = count > 18 ? 1.8 : (count > 8 ? 2.4 : 3.2);
      for (var k = 0; k < count; k++) {
        final angle = 2 * math.pi * k / count;
        final pos = center + Offset(math.cos(angle), math.sin(angle)) * r;
        canvas.drawCircle(pos, dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShellPainter oldDelegate) => oldDelegate.shells != shells;
}
