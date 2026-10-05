import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pulse_ring.dart';

class UserMarker extends StatelessWidget {
  const UserMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return PulseRing(
      color: context.colors.primary,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: context.accentGradient,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.6),
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
