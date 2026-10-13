import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/auth_service.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../navigation/main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Send login request to the API.
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Read the user data returned by the API.
      final user = response['user'] as Map<String, dynamic>;

      final userId = int.tryParse(user['id'].toString());

      if (userId == null) {
        throw Exception('Invalid user ID returned by the server.');
      }

      // Save the logged-in user's information.
      if (!mounted) return;

      context.read<UserProvider>().setUser(
        userId: userId,
        name: user['fullName']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
      );

      // Load tasks belonging to the logged-in account.
      await context.read<TaskProvider>().loadTasks(userId.toString());

      if (!mounted) return;

      // Open the main navigation screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required bool isDark,
  }) {
    final borderColor =
        isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);
    final fillColor =
        isDark ? const Color(0xFF242424) : Colors.white;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : const Color(0xFF6E7177),
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isDark ? Colors.white60 : const Color(0xFF8E9196),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF15B86C), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF181818) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subTextColor =
        isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6E7177);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333333)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: textColor,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15B86C).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome Back 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage your tasks and stay productive',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: _buildInputDecoration(
                        labelText: 'Email Address',
                        hintText: 'name@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Please enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(color: textColor, fontSize: 15),
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },
                      decoration: _buildInputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF8E9196),
                            size: 20,
                          ),
                        ),
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF15B86C)
                                .withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15B86C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF15B86C)
                              .withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF6E7177),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFF15B86C),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
