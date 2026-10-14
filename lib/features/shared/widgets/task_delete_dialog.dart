import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';

class TaskDeleteDialog extends StatelessWidget {
  const TaskDeleteDialog({super.key, required this.task});

  final TaskModel task;

  static Future<bool?> show(BuildContext context, TaskModel task) {
    return showDialog<bool>(
      context: context,
      builder: (_) => TaskDeleteDialog(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.isCompleted ? 'Delete completed task?' : 'Delete task?'),
      content: Text('"${task.title}" will be permanently deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
