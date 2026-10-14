import 'package:flutter/material.dart';

import '../../../data/models/task_model.dart';
import '../../home/widgets/home_palette.dart';
import 'task_actions.dart';

typedef TaskCardBuilder =
    Widget Function(
      BuildContext context,
      TaskModel task,
      bool isBusy,
      ValueChanged<TaskAction> onAction,
    );

/// Renders task states and owns the common ordering and action wiring.
class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.tasks,
    required this.isLoading,
    required this.hasError,
    required this.emptyState,
    required this.errorState,
    required this.cardBuilder,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final bool hasError;
  final Widget emptyState;
  final Widget errorState;
  final TaskCardBuilder cardBuilder;

  static int _newestFirst(TaskModel a, TaskModel b) {
    final byDate = b.createdAt.compareTo(a.createdAt);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (tasks.isEmpty) return hasError ? errorState : emptyState;

    final sortedTasks = [...tasks]..sort(_newestFirst);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: sortedTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return TaskActions(
          key: ValueKey(task.id),
          task: task,
          builder: (context, isBusy, onAction) =>
              cardBuilder(context, task, isBusy, onAction),
        );
      },
    );
  }
}

/// Shared page layout; each feature supplies its own title and content.
class TaskListScaffold extends StatelessWidget {
  const TaskListScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.allowNavigatorBack = false,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final bool allowNavigatorBack;

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final canGoBack =
        onBack != null ||
        (allowNavigatorBack && Navigator.of(context).canPop());
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: palette.text,
          ),
        ),
        centerTitle: false,
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: canGoBack ? 0 : 16,
        leading: canGoBack
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(top: false, bottom: false, child: body),
    );
  }
}

class TaskMessage extends StatelessWidget {
  const TaskMessage({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final String title;
  final String subtitle;
  final HomePalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: palette.subText),
            ),
          ],
        ),
      ),
    );
  }
}
