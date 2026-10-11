import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isHighPriority;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isHighPriority,
    required this.isCompleted,
    required this.createdAt,
    required this.userId,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isHighPriority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      userId: userId,
    );
  }
}
