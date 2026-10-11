import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';

class HiveService {
  static const String tasksBoxName = 'tasksBox';

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    if (!Hive.isBoxOpen(tasksBoxName)) {
      await Hive.openBox<TaskModel>(tasksBoxName);
    }
  }

  Box<TaskModel> get _tasksBox {
    return Hive.box<TaskModel>(tasksBoxName);
  }

  List<TaskModel> getTasksForUser(String userId) {
    return _tasksBox.values.where((task) => task.userId == userId).toList();
  }

  Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }
}
