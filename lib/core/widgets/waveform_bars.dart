import 'package:flutter/material.dart';

/// Rounded vertical bars; [levels] are 0‥1 and the newest value is last.
class WaveformBars extends StatelessWidget {
  const WaveformBars({
    super.key,
    required this.levels,
    required this.color,
    this.barCount = 36,
    this.height = 56,
  });

  final List<double> levels;
  final Color color;
  final int barCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(levels, color, barCount),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter(this.levels, this.color, this.barCount);

  final List<double> levels;
  final Color color;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / barCount;
    final barWidth = slot * 0.55;
    final start = levels.length - barCount;
    for (var i = 0; i < barCount; i++) {
      final index = start + i;
      final level = index >= 0 ? levels[index] : 0.0;
      final h = (size.height * (0.08 + 0.92 * level)).clamp(4.0, size.height);
      final paint = Paint()
        ..color = color.withValues(alpha: 0.35 + 0.65 * (i / barCount));
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(slot * i + slot / 2, size.height / 2),
          width: barWidth,
          height: h,
        ),
        Radius.circular(barWidth),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.levels != levels || old.color != color;
}
