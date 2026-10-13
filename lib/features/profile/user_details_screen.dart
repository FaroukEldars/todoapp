import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quoteController;

  static const Color _green = Color(0xFF15B86C);

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController = TextEditingController(text: user.name);
    _quoteController = TextEditingController(text: user.quote);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final newQuote = _quoteController.text.trim();

    final userProvider = context.read<UserProvider>();
    if (newName.isNotEmpty) {
      userProvider.updateName(newName);
    }
    if (newQuote.isNotEmpty) {
      userProvider.updateQuote(newQuote);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile details updated successfully!'),
        backgroundColor: _green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF181818) : Colors.white;
    final cardColor = isDark ? const Color(0xFF282828) : const Color(0xFFF7F8FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subTextColor =
        isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6E7177);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'User Details',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email (Read-only badge)
                if (user.email.isNotEmpty) ...[
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E5EA),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: subTextColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Full Name
                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: subTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E5EA),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E5EA),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Motivation / Quote
                Text(
                  'Daily Quote / Bio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quoteController,
                  maxLines: 3,
                  style: TextStyle(color: textColor, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'One task at a time. One step closer.',
                    hintStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E5EA),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E5EA),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
