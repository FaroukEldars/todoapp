import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';

import 'home_palette.dart';
import 'task_tile.dart';

class HighPriorityCard extends StatelessWidget {
  final List<TaskModel> tasks;

  const HighPriorityCard({super.key, required this.tasks});

  TextStyle _titleStyle(HomePalette p, bool done, double size) {
    return TextStyle(
      fontSize: size,
      color: done ? p.doneText : p.text,
      decoration: done ? TextDecoration.lineThrough : null,
      decorationColor: p.doneText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final visible = tasks.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: p.cardDecoration(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 22,
            child: Text(
              'High Priority Tasks',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: HomePalette.green,
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (visible.isEmpty)
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No high priority tasks right now 🎉',
                  style: TextStyle(fontSize: 14, color: p.subText),
                ),
              ),
            )
          else
            ...visible.map(
              (task) => SizedBox(
                height: 32,
                child: Row(
                  children: [
                    TaskCheckbox(
                      checked: task.isCompleted,
                      onTap: () {
                        context.read<TaskProvider>().toggleTask(task);
                      },
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _titleStyle(p, task.isCompleted, 14),
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
