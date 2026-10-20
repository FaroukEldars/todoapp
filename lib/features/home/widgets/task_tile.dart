import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../shared/widgets/task_delete_dialog.dart';
import 'home_palette.dart';

enum TaskAction { toggle, delete }

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  Future<void> _toggleTask(BuildContext context, TaskModel task) async {
    try {
      await context.read<TaskProvider>().toggleTask(task);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the task.')),
        );
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, TaskModel task) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<TaskProvider>();

    final confirmed = await TaskDeleteDialog.show(context, task);

    if (confirmed != true) return;

    try {
      await provider.deleteTask(task.id);
      messenger.showSnackBar(const SnackBar(content: Text('Task deleted.')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the task.')),
      );
    }
  }

  TextStyle _titleStyle(HomePalette p, bool done, double size) => TextStyle(
    fontSize: size,
    color: done ? p.doneText : p.text,
    decoration: done ? TextDecoration.lineThrough : null,
    decorationColor: p.doneText,
  );

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final done = task.isCompleted;
    final hasDescription = task.description.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(minHeight: hasDescription ? 72 : 56),
      padding: const EdgeInsets.fromLTRB(14, 6, 2, 6),
      decoration: p.cardDecoration(28),
      child: Row(
        children: [
          TaskCheckbox(checked: done, onTap: () => _toggleTask(context, task)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle(p, done, 16),
                ),
                if (hasDescription)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: p.subText),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<TaskAction>(
            tooltip: 'More options',
            color: p.card,
            surfaceTintColor: Colors.transparent,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: p.border, width: 1),
            ),
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert_rounded, size: 22, color: p.text),
            onSelected: (action) {
              if (action == TaskAction.toggle) {
                _toggleTask(context, task);
              } else {
                _deleteTask(context, task);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: TaskAction.toggle,
                child: Text(
                  done ? 'Mark as active' : 'Mark as completed',
                  style: TextStyle(color: p.text),
                ),
              ),
              PopupMenuItem(
                value: TaskAction.delete,
                child: Text('Delete', style: TextStyle(color: scheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const TaskCheckbox({super.key, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: checked ? HomePalette.green : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: checked ? HomePalette.green : p.checkBorder,
              width: 1.8,
            ),
          ),
          child: checked
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class EmptyTasksState extends StatelessWidget {
  const EmptyTasksState({super.key});

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: p.checkBorder),
          const SizedBox(height: 10),
          Text('No tasks yet', style: TextStyle(fontSize: 18, color: p.text)),
          const SizedBox(height: 4),
          Text(
            'Tap "Add New Task" to create your first one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: p.subText),
          ),
        ],
      ),
    );
  }
}
