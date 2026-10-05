import 'package:flutter/material.dart';

/// Expanding, fading ring — used for the user dot and playing echoes.
class PulseRing extends StatefulWidget {
  const PulseRing({
    super.key,
    required this.color,
    required this.child,
    this.active = true,
  });

  final Color color;
  final Widget child;
  final bool active;

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.active)
          AnimatedBuilder(
            animation: _controller,
            builder: (_, _) {
              final t = _controller.value;
              return IgnorePointer(
                child: Container(
                  width: 28 + 44 * t,
                  height: 28 + 44 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.35 * (1 - t)),
                  ),
                ),
              );
            },
          ),
        widget.child,
      ],
    );
  }
}
