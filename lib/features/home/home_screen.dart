import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../add_task/add_task_screen.dart';

/// Person 2: Home Screen — built from the Figma design (Light + Dark).
///
///  1. Header: avatar + greeting + quote + theme toggle
///  2. Headline ("Yuhuu , Your work Is almost done !")
///  3. Achieved Tasks card (circular progress)
///  4. High Priority Tasks card (+ arrow to the full list)
///  5. My Tasks list (checkbox + ⋮ menu)
///  + "Add New Task" button
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final provider = context.watch<TaskProvider>();

    final tasks = [...provider.tasks]..sort(_newestFirst);
    final highPriority = tasks.where((t) => t.isHighPriority).toList();

    return Scaffold(
      backgroundColor: p.background,
      floatingActionButton: const _AddTaskButton(),
      body: SafeArea(
        bottom: false,
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                children: [
                  const _Header(),
                  const SizedBox(height: 22),
                  _Headline(
                    completed: provider.completedTasksCount,
                    total: provider.totalTasksCount,
                  ),
                  const SizedBox(height: 16),
                  _AchievedCard(
                    completed: provider.completedTasksCount,
                    total: provider.totalTasksCount,
                    ratio: provider.progressRatio,
                  ),
                  const SizedBox(height: 8),
                  _HighPriorityCard(tasks: highPriority),
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
                    const _EmptyState()
                  else
                    for (final task in tasks) ...[
                      _TaskTile(task: task),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette (Light / Dark, taken from the design)
// ---------------------------------------------------------------------------
class _Palette {
  static const green = Color(0xFF17B66A);

  final Color background;
  final Color card;
  final Color? border;
  final Color text;
  final Color subText;
  final Color doneText;
  final Color checkBorder;
  final Color track;

  const _Palette({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.subText,
    required this.doneText,
    required this.checkBorder,
    required this.track,
  });

  factory _Palette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static const _light = _Palette(
    background: Color(0xFFF5F6F8),
    card: Colors.white,
    border: Color(0xFFE3E6EA),
    text: Color(0xFF1B1B1B),
    subText: Color(0xFF4A4D52),
    doneText: Color(0xFF5F6368),
    checkBorder: Color(0xFFC9CDD2),
    track: Color(0xFF8E9196),
  );

  static const _dark = _Palette(
    background: Color(0xFF181818),
    card: Color(0xFF282828),
    border: null,
    text: Colors.white,
    subText: Color(0xFFCFCFCF),
    doneText: Color(0xFFBDBDBD),
    checkBorder: Color(0xFF6B6B6B),
    track: Color(0xFF777777),
  );

  BoxDecoration cardDecoration(double radius) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: border == null ? null : Border.all(color: border!, width: 1),
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
int _newestFirst(TaskModel a, TaskModel b) {
  final c = b.createdAt.compareTo(a.createdAt);
  return c != 0 ? c : b.id.compareTo(a.id);
}

void _openAddTask(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
}

Future<void> _toggleTask(BuildContext context, TaskModel task) async {
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<TaskProvider>();
  try {
    await provider.toggleTask(task);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not update the task.')),
    );
  }
}

Future<void> _deleteTask(BuildContext context, TaskModel task) async {
  final messenger = ScaffoldMessenger.of(context);
  final provider = context.read<TaskProvider>();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete task?'),
      content: Text('"${task.title}" will be permanently deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

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

// ---------------------------------------------------------------------------
// 1. Header
// ---------------------------------------------------------------------------
class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  // The name typed in the Welcome screen lives in UserProvider. Home also keeps
  // its own copy in Hive so the name is still shown after the app restarts.
  static const _boxName = 'home_settings';
  static const _nameKey = 'userName';

  String _savedName = '';
  bool _hadProviderName = false;

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  Future<Box> _openBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
  }

  Future<void> _loadSavedName() async {
    try {
      final box = await _openBox();
      final saved = (box.get(_nameKey) as String?)?.trim() ?? '';
      if (mounted && saved.isNotEmpty && _savedName.isEmpty) {
        setState(() => _savedName = saved);
      }
    } catch (e) {
      debugPrint('Could not load saved name: $e');
    }
  }

  Future<void> _writeName(String? name) async {
    try {
      final box = await _openBox();
      if (name == null) {
        await box.delete(_nameKey);
      } else {
        await box.put(_nameKey, name);
      }
    } catch (e) {
      debugPrint('Could not save name: $e');
    }
  }

  /// Keeps the Hive copy in sync with the name in UserProvider.
  void _syncSavedName(String providerName) {
    if (providerName.isNotEmpty) {
      _hadProviderName = true;
      if (providerName != _savedName) {
        _savedName = providerName;
        unawaited(_writeName(providerName));
      }
    } else if (_hadProviderName) {
      // The user logged out (UserProvider.clearUser) -> forget the name.
      _hadProviderName = false;
      _savedName = '';
      unawaited(_writeName(null));
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final user = context.watch<UserProvider>();
    final quote = user.quote.trim();

    // 1) name from UserProvider (Welcome / Login)  2) else the one saved in Hive
    final providerName = user.name.trim();
    _syncSavedName(providerName);
    final name = providerName.isNotEmpty ? providerName : _savedName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(name: name, imagePath: user.imagePath),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? _greeting() : '${_greeting()} ,$name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: p.text,
                ),
              ),
              if (quote.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    quote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: p.subText,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _ThemeToggle(),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imagePath;

  const _Avatar({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    final path = imagePath;
    if (!kIsWeb && path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) image = FileImage(file);
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: _Palette.green.withValues(alpha: 0.18),
      foregroundImage: image,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(
          color: _Palette.green,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Material(
      color: isDark ? Colors.black : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.read<ThemeProvider>().toggleTheme(),
        child: Tooltip(
          message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Headline
// ---------------------------------------------------------------------------
class _Headline extends StatelessWidget {
  final int completed;
  final int total;

  const _Headline({required this.completed, required this.total});

  String _text() {
    if (total == 0) return "Let's start , Add your first task !";
    if (completed == total) return 'Amazing , All your tasks are done !';
    if (completed / total >= 0.5) return 'Yuhuu , Your work Is almost done !';
    return "Let's go , You can do it !";
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return Text(
      '${_text()} 👋',
      style: TextStyle(
        fontSize: 30,
        height: 1.45,
        fontWeight: FontWeight.w300,
        color: p.text,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Achieved Tasks
// ---------------------------------------------------------------------------
class _AchievedCard extends StatelessWidget {
  final int completed;
  final int total;
  final double ratio;

  const _AchievedCard({
    required this.completed,
    required this.total,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final safeRatio = ratio.clamp(0.0, 1.0).toDouble();

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: p.cardDecoration(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achieved Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: p.text,
                  ),
                ),
                Text(
                  '$completed Out of $total Done',
                  style: TextStyle(fontSize: 15, height: 1.3, color: p.subText),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: safeRatio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: p.track,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        _Palette.green,
                      ),
                    ),
                  ),
                  Text(
                    '${(safeRatio * 100).round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.text,
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

// ---------------------------------------------------------------------------
// 4. High Priority Tasks
// ---------------------------------------------------------------------------
class _HighPriorityCard extends StatelessWidget {
  final List<TaskModel> tasks;

  const _HighPriorityCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final visible = tasks.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: p.cardDecoration(24),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 22,
                child: Text(
                  'High Priority Tasks',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _Palette.green,
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
                for (final task in visible)
                  SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        _TaskCheckbox(
                          checked: task.isCompleted,
                          onTap: () => _toggleTask(context, task),
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
                        // Keeps the text clear of the arrow button.
                        const SizedBox(width: 52),
                      ],
                    ),
                  ),
            ],
          ),
          if (visible.isNotEmpty)
            Positioned(
              right: -4,
              bottom: 0,
              child: _ArrowButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _HighPriorityScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ArrowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: p.checkBorder, width: 1),
        ),
        child: Icon(Icons.north_east_rounded, size: 18, color: p.text),
      ),
    );
  }
}

/// Full list of high priority tasks (opened from the arrow button).
class _HighPriorityScreen extends StatelessWidget {
  const _HighPriorityScreen();

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final tasks =
        context
            .watch<TaskProvider>()
            .tasks
            .where((t) => t.isHighPriority)
            .toList()
          ..sort(_newestFirst);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'High Priority Tasks',
          style: TextStyle(color: _Palette.green, fontSize: 18),
        ),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No high priority tasks right now 🎉',
                style: TextStyle(fontSize: 15, color: p.subText),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _TaskTile(task: tasks[index]),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Tasks list
// ---------------------------------------------------------------------------
TextStyle _titleStyle(_Palette p, bool done, double size) => TextStyle(
  fontSize: size,
  color: done ? p.doneText : p.text,
  decoration: done ? TextDecoration.lineThrough : null,
  decorationColor: p.doneText,
);

class _TaskCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const _TaskCheckbox({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: checked ? _Palette.green : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: checked ? _Palette.green : p.checkBorder,
              width: 2,
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

enum _TaskAction { toggle, delete }

class _TaskTile extends StatelessWidget {
  final TaskModel task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final scheme = Theme.of(context).colorScheme;
    final done = task.isCompleted;
    final hasDescription = task.description.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(minHeight: hasDescription ? 72 : 56),
      padding: const EdgeInsets.fromLTRB(14, 6, 2, 6),
      decoration: p.cardDecoration(28),
      child: Row(
        children: [
          _TaskCheckbox(checked: done, onTap: () => _toggleTask(context, task)),
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
          PopupMenuButton<_TaskAction>(
            tooltip: 'More options',
            color: p.card,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert_rounded, size: 22, color: p.text),
            onSelected: (action) {
              if (action == _TaskAction.toggle) {
                _toggleTask(context, task);
              } else {
                _deleteTask(context, task);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _TaskAction.toggle,
                child: Text(
                  done ? 'Mark as active' : 'Mark as completed',
                  style: TextStyle(color: p.text),
                ),
              ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: Text('Delete', style: TextStyle(color: scheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);

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

// ---------------------------------------------------------------------------
// Add New Task button
// ---------------------------------------------------------------------------
class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _openAddTask(context),
      style: FilledButton.styleFrom(
        backgroundColor: _Palette.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text('Add New Task'),
    );
  }
}
