import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/data/models/task_model.dart';
import 'package:todoapp/providers/task_provider.dart';
import 'package:todoapp/providers/user_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? userId;

  const AddTaskScreen({super.key, this.userId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const Color _green = Color(0xFF16B978);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  bool _isHighPriority = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final effectiveUserId =
        widget.userId ?? context.read<UserProvider>().userId?.toString() ?? '1';

    final task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: effectiveUserId,
      title: _nameController.text.trim(),
      description: _descController.text.trim(),
      isHighPriority: _isHighPriority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    try {
      await context.read<TaskProvider>().addTask(task);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save task')));
    } finally {
      if (!mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _decoration(
    String hint,
    Color field,
    Color hintColor,
    Color borderColor,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      filled: true,
      fillColor: field,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _label(String text, Color textColor) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF181818) : const Color(0xFFF5F6F8);
    final field = isDark ? const Color(0xFF282828) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final hintColor = isDark
        ? const Color(0xFF6B6B6B)
        : const Color(0xFF8E9196);
    final borderColor = isDark
        ? const Color(0xFF383838)
        : const Color(0xFFE3E6EA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Task',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Task Name', textColor),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: textColor),
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            'Finish UI design for login screen',
                            field,
                            hintColor,
                            borderColor,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter a task name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _label('Task Description', textColor),
                        TextFormField(
                          controller: _descController,
                          style: TextStyle(color: textColor),
                          maxLines: 6,
                          decoration: _decoration(
                            'Finish onboarding UI and hand off to devs by Thursday.',
                            field,
                            hintColor,
                            borderColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'High Priority',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Switch(
                              value: _isHighPriority,
                              onChanged: (value) {
                                setState(() => _isHighPriority = value);
                              },
                              activeThumbColor: Colors.white,
                              activeTrackColor: _green,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: isDark
                                  ? const Color(0xFF3A3A3C)
                                  : const Color(0xFFE5E5EA),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _green.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
