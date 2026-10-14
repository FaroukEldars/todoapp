import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import 'task_delete_dialog.dart';
import 'task_details_sheet.dart';

enum TaskAction { details, toggle, delete }

typedef TaskActionsBuilder =
    Widget Function(
      BuildContext context,
      bool isBusy,
      ValueChanged<TaskAction> onAction,
    );

/// Owns only the local operation state; task data stays in TaskProvider.
class TaskActions extends StatefulWidget {
  const TaskActions({super.key, required this.task, required this.builder});

  final TaskModel task;
  final TaskActionsBuilder builder;

  @override
  State<TaskActions> createState() => _TaskActionsState();
}

class _TaskActionsState extends State<TaskActions>
    with AutomaticKeepAliveClientMixin<TaskActions> {
  bool _isBusy = false;
  bool _confirmingDelete = false;

  @override
  bool get wantKeepAlive => _isBusy || _confirmingDelete;

  Future<void> _handleAction(TaskAction action) async {
    final task = widget.task;
    if (action == TaskAction.details) {
      await TaskDetailsSheet.show(context, task);
      return;
    }
    if (_isBusy || _confirmingDelete) return;

    if (action == TaskAction.delete) {
      // Lock confirmation without changing the card's existing appearance.
      _confirmingDelete = true;
      updateKeepAlive();
      bool? confirmed;
      try {
        confirmed = await TaskDeleteDialog.show(context, task);
      } finally {
        _confirmingDelete = false;
        if (mounted) updateKeepAlive();
      }
      if (!mounted || confirmed != true) return;
    }

    final provider = context.read<TaskProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final scaffold = Scaffold.of(context);
    setState(() => _isBusy = true);
    updateKeepAlive();
    try {
      if (action == TaskAction.delete) {
        await provider.deleteTask(task.id);
      } else {
        await provider.toggleTask(task);
      }
      // A successful operation can remove this card before the await resumes.
      if (!scaffold.mounted || !messenger.mounted) return;
      final message = action == TaskAction.delete
          ? (task.isCompleted ? 'Completed task deleted.' : 'Task deleted.')
          : (task.isCompleted ? 'Task moved back to To Do.' : null);
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted || !messenger.mounted) return;
      final message = action == TaskAction.delete
          ? 'Could not delete the task.'
          : (task.isCompleted
                ? 'Could not restore the task.'
                : 'Could not complete the task.');
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
        updateKeepAlive();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context, _isBusy, _handleAction);
  }
}
