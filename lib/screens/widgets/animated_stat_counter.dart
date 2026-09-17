import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedStatCounter extends StatelessWidget {
  final num target;
  final String prefix;
  final String suffix;
  final TextStyle style;
  final Duration duration;
  final bool isCurrency;

  const AnimatedStatCounter({
    super.key,
    required this.target,
    this.prefix = '',
    this.suffix = '',
    required this.style,
    this.duration = const Duration(milliseconds: 1400),
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        String formattedNumber;
        if (isCurrency) {
          formattedNumber = NumberFormat('#,##,###').format(value.toInt());
        } else {
          formattedNumber = value.toInt().toString();
        }
        return Text(
          '$prefix$formattedNumber$suffix',
          style: style,
        );
      },
    );
  }
}
