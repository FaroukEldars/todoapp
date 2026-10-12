import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/data/models/task_model.dart';
import 'package:todoapp/providers/task_provider.dart';


class AddTaskScreen extends StatefulWidget {
  final String userId;

  const AddTaskScreen({
    super.key,
    required this.userId
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const Color _bg = Color(0xFF1C1C1C);
  static const Color _field = Color(0xFF2A2A2A);
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

    final task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: widget.userId,
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

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 15),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Task',
          style: TextStyle(color: Colors.white, fontSize: 18),
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
                        _label('Task Name'),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            'Finish UI design for login screen',
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter a task name'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        _label('Task Description'),
                        TextFormField(
                          controller: _descController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 6,
                          decoration: _decoration(
                            'Finish onboarding UI and hand off to devs by Thursday.',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'High Priority',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Switch(
                              value: _isHighPriority,
                              onChanged: (value) {
                                setState(() => _isHighPriority = value);
                              },
                              activeColor: Colors.white,
                              activeTrackColor: _green,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: _field,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _green.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
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
                      style: TextStyle(fontSize: 15),
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
