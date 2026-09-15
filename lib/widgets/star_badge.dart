import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An 8-point star (two overlapping squares, one rotated 45°) — a nod to
/// the rub el hizb / khatam motif from Islamic geometric art. Used as the
/// icon container for the "next prayer" hero, in place of a generic M3
/// blob shape.
class StarBadge extends StatelessWidget {
  const StarBadge({super.key, required this.icon, this.size = 40});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = size * 0.22;

    Widget square({double angle = 0}) => Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Transform.rotate(
              angle: angle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          ),
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          square(),
          square(angle: math.pi / 4),
          Icon(icon, color: scheme.onPrimary, size: size * 0.42),
        ],
      ),
    );
  }
}
