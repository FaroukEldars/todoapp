import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../home/widgets/home_palette.dart';
import '../shared/widgets/task_list.dart';
import '../shared/widgets/task_card.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final provider = context.watch<TaskProvider>();
    return TaskListScaffold(
      title: 'Completed Tasks',
      onBack: onBack,
      body: TaskList(
        tasks: provider.completedTasks,
        isLoading: provider.isLoading,
        hasError: provider.errorMessage != null,
        errorState: TaskMessage(
          icon: Icons.error_outline_rounded,
          iconSize: 52,
          iconColor: HomePalette.green,
          title: 'Could not load completed tasks',
          subtitle: 'Please try reopening the app.',
          palette: palette,
        ),
        emptyState: TaskMessage(
          icon: Icons.task_alt_rounded,
          iconSize: 52,
          iconColor: HomePalette.green,
          title: 'No completed tasks yet',
          subtitle: 'Finish a task to see it here.',
          palette: palette,
        ),
        cardBuilder: (context, task, isBusy, onAction) => TaskCard(
          task: task,
          palette: palette,
          isBusy: isBusy,
          onAction: onAction,
        ),
      ),
    );
  }
}
