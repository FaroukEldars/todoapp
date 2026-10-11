import 'package:flutter/foundation.dart';

import '../data/models/task_model.dart';
import '../data/services/hive_service.dart';

class TaskProvider extends ChangeNotifier {
  final HiveService _hiveService;

  TaskProvider(this._hiveService);

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  List<TaskModel> get activeTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<TaskModel> get highPriorityTasks {
    return _tasks.where((task) => !task.isCompleted && task.isHighPriority).toList();
  }

  int get totalTasksCount => _tasks.length;
  int get activeTasksCount => activeTasks.length;
  int get completedTasksCount => completedTasks.length;

  double get progressRatio {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks.length / _tasks.length;
  }

  // Load tasks belonging to the logged-in user from Hive.
  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = _hiveService.getTasksForUser(userId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a task locally to Hive.
  Future<void> addTask(TaskModel task) async {
    _errorMessage = null;

    try {
      // Ensure task has a valid unique ID if not already provided.
      final taskId = task.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : task.id;

      final taskToSave = task.id.isEmpty
          ? TaskModel(
              id: taskId,
              title: task.title,
              description: task.description,
              isHighPriority: task.isHighPriority,
              isCompleted: task.isCompleted,
              createdAt: task.createdAt,
              userId: task.userId,
            )
          : task;

      await _hiveService.saveTask(taskToSave);

      _tasks.removeWhere((item) => item.id == taskToSave.id);
      _tasks.add(taskToSave);

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Toggle task completion status locally in Hive.
  Future<void> toggleTask(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    _errorMessage = null;

    try {
      await _hiveService.updateTask(updatedTask);

      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete a task locally from Hive.
  Future<void> deleteTask(String taskId) async {
    _errorMessage = null;

    try {
      await _hiveService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear in-memory tasks (e.g. when logging out).
  void clearTasks() {
    _tasks = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
