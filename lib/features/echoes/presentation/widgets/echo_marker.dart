import 'package:flutter/material.dart';

import '../../../../core/widgets/pulse_ring.dart';
import '../../domain/echo.dart';

/// Glowing orb for an echo on the map. Pulses while that echo is playing.
class EchoMarker extends StatelessWidget {
  const EchoMarker({
    super.key,
    required this.echo,
    required this.playing,
    required this.inRange,
    required this.onTap,
  });

  final Echo echo;
  final bool playing;
  final bool inRange;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = echo.category.color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PulseRing(
        color: color,
        active: playing || inRange,
        child: AnimatedScale(
          scale: playing ? 1.2 : 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, Colors.black, 0.35)!],
              ),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              playing ? Icons.graphic_eq_rounded : echo.category.icon,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}
