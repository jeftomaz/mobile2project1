import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ribbon diagonal verde "✓ Assistido" no canto superior do pôster.
/// Deve ser colocado diretamente dentro de um [Stack] sobre a imagem.
class WatchedRibbon extends StatelessWidget {
  const WatchedRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      left: -24,
      child: Transform.rotate(
        angle: -math.pi / 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 3),
          color: Colors.green.shade600,
          child: const Text(
            '✓ ASSISTIDO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
