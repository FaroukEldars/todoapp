import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../../home/widgets/home_palette.dart';
import 'task_actions.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.palette,
    required this.isBusy,
    required this.onAction,
  });

  final TaskModel task;
  final HomePalette palette;
  final bool isBusy;
  final ValueChanged<TaskAction> onAction;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    final hasDescription = !completed && task.description.trim().isNotEmpty;
    return Container(
      constraints: BoxConstraints(minHeight: hasDescription ? 74 : 62),
      decoration: palette.cardDecoration(18),
      padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
      child: Row(
        children: [
          Semantics(
            label: completed
                ? 'Restore ${task.title} to To Do'
                : 'Mark ${task.title} as completed',
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isBusy ? null : () => onAction(TaskAction.toggle),
              child: SizedBox(
                height: 44,
                width: completed ? 38 : 36,
                child: Center(
                  child: isBusy
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: completed ? HomePalette.green : null,
                            border: completed
                                ? null
                                : Border.all(
                                    color: palette.checkBorder,
                                    width: 1.8,
                                  ),
                          ),
                          child: completed
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(width: completed ? 4 : 8),
          Expanded(
            child: InkWell(
              onTap: isBusy ? null : () => onAction(TaskAction.details),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: completed
                                  ? palette.doneText
                                  : palette.text,
                              fontSize: 15,
                              fontWeight: completed
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: completed
                                  ? palette.doneText
                                  : null,
                            ),
                          ),
                        ),
                        if (!completed && task.isHighPriority) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'High priority',
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB547),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: palette.subText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<TaskAction>(
            enabled: !isBusy,
            tooltip: 'Task options',
            color: palette.card,
            surfaceTintColor: Colors.transparent,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert_rounded, color: palette.subText),
            onSelected: onAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TaskAction.details,
                child: Text('View details'),
              ),
              PopupMenuItem(
                value: TaskAction.toggle,
                child: Text(
                  completed ? 'Undo completion' : 'Mark as completed',
                ),
              ),
              PopupMenuItem(
                value: TaskAction.delete,
                child: Text(
                  'Delete task',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
