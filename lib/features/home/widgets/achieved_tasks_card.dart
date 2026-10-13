import 'package:flutter/material.dart';

import 'home_palette.dart';

class AchievedTasksCard extends StatelessWidget {
  final int completed;
  final int total;
  final double ratio;

  const AchievedTasksCard({
    super.key,
    required this.completed,
    required this.total,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final safeRatio = ratio.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: p.cardDecoration(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achieved Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: p.text,
                  ),
                ),
                Text(
                  '$completed Out of $total Done',
                  style: TextStyle(fontSize: 15, height: 1.3, color: p.subText),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeRatio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: p.track,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        HomePalette.green,
                      ),
                    ),
                  ),
                  Text(
                    '${(safeRatio * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
