import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../add_task/add_task_screen.dart';
import 'widgets/achieved_tasks_card.dart';
import 'widgets/high_priority_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_palette.dart';
import 'widgets/task_tile.dart';

/// Person 2: Home Screen — built from the Figma design (Light + Dark).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static int _newestFirst(TaskModel a, TaskModel b) {
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : b.id.compareTo(a.id);
  }

  void _openAddTask(BuildContext context) {
    final userId = context.read<UserProvider>().userId?.toString() ?? '';
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddTaskScreen(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    final p = HomePalette.of(context);
    final provider = context.watch<TaskProvider>();

    final tasks = [...provider.tasks]..sort(_newestFirst);

    return Scaffold(
      backgroundColor: p.background,
      floatingActionButton: _AddTaskButton(
        onPressed: () => _openAddTask(context),
      ),
      body: SafeArea(
        bottom: false,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                children: [
                  const SizedBox(height: 5),
                  const HomeHeader(),
                  const SizedBox(height: 22),
                  const SizedBox(height: 16),
                  AchievedTasksCard(
                    completed: provider.completedTasksCount,
                    total: provider.totalTasksCount,
                    ratio: provider.progressRatio,
                  ),
                  const SizedBox(height: 8),
                  HighPriorityCard(tasks: provider.highPriorityTasks),
                  const SizedBox(height: 24),
                  Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tasks.isEmpty)
                    const EmptyTasksState()
                  else
                    for (final task in tasks) ...[
                      TaskTile(task: task),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
      ),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddTaskButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: HomePalette.green.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: HomePalette.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Add New Task'),
      ),
    );
  }
}
