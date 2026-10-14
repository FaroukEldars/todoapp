import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../home/widgets/home_palette.dart';
import '../shared/widgets/task_list.dart';
import '../shared/widgets/task_card.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final provider = context.watch<TaskProvider>();
    return TaskListScaffold(
      title: 'To Do Tasks',
      onBack: onBack,
      allowNavigatorBack: true,
      body: TaskList(
        tasks: provider.activeTasks,
        isLoading: provider.isLoading,
        hasError: provider.errorMessage != null,
        errorState: TaskMessage(
          icon: Icons.error_outline_rounded,
          iconSize: 56,
          iconColor: palette.checkBorder,
          title: 'Could not load tasks',
          subtitle: 'Please try again after reopening the app.',
          palette: palette,
        ),
        emptyState: TaskMessage(
          icon: Icons.task_alt_rounded,
          iconSize: 56,
          iconColor: palette.checkBorder,
          title: 'No active tasks',
          subtitle: 'Tasks you add will appear here.',
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
