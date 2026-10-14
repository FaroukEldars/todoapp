import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../../home/widgets/home_palette.dart';

class TaskDetailsSheet extends StatelessWidget {
  const TaskDetailsSheet({
    super.key,
    required this.task,
    required this.completed,
  });

  final TaskModel task;
  final bool completed;

  static Future<void> show(BuildContext context, TaskModel task) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: HomePalette.of(context).card,
      builder: (_) => TaskDetailsSheet(task: task, completed: task.isCompleted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final date = task.createdAt;
    final createdOn =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: p.text,
                decoration: completed ? TextDecoration.lineThrough : null,
                decorationColor: completed ? p.doneText : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              task.description.trim().isEmpty
                  ? 'No description added.'
                  : task.description,
              style: TextStyle(fontSize: 15, color: p.subText, height: 1.5),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: task.isHighPriority
                      ? const Color(0xFFFFB547)
                      : p.subText,
                ),
                const SizedBox(width: 8),
                Text(
                  task.isHighPriority ? 'High priority' : 'Normal priority',
                  style: TextStyle(color: p.text),
                ),
                const Spacer(),
                Text(
                  createdOn,
                  style: TextStyle(fontSize: 13, color: p.subText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
