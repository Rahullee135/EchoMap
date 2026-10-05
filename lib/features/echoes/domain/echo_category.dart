import 'package:flutter/material.dart';

enum EchoCategory {
  tip('Local tip', Icons.lightbulb_rounded, Color(0xFFFFC107)),
  story('Story', Icons.auto_stories_rounded, Color(0xFFA78BFA)),
  history('History', Icons.account_balance_rounded, Color(0xFF38BDF8)),
  food('Food', Icons.restaurant_rounded, Color(0xFFFB7185)),
  secret('Hidden gem', Icons.diamond_rounded, Color(0xFF34D399));

  const EchoCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static EchoCategory fromName(String? name) =>
      values.firstWhere((c) => c.name == name, orElse: () => story);
}
