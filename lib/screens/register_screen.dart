import 'package:flutter/material.dart';
import '../services/firestore_auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_auth_field.dart';
import '../widgets/firestore_auth_banner.dart';
import 'dashboard_screen.dart';

/// Screen allowing new users to create an account stored in Google Cloud Firestore.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Developer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _roles = ['Developer', 'Student', 'Staff', 'Administrator'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await FirestoreAuthService.instance.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess && result.user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(user: result.user!),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo[900],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Register your profile to store credentials in Firestore',
                  icon: Icons.person_add_alt_1,
                ),
                const SizedBox(height: 16),
                const FirestoreAuthBanner(),
                const SizedBox(height: 18),

                // Full Name
                CustomAuthField(
                  controller: _nameController,
                  labelText: 'Full Name *',
                  hintText: 'e.g., Jennifer Parker',
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter full name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email
                CustomAuthField(
                  controller: _emailController,
                  labelText: 'Email Address *',
                  hintText: 'e.g., jennifer@cloudcorp.io',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter email address';
                    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!regex.hasMatch(val.trim())) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Account Role *',
                    prefixIcon: const Icon(Icons.shield_outlined, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 14),

                // Password
                CustomAuthField(
                  controller: _passwordController,
                  labelText: 'Password *',
                  hintText: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  isObscured: _obscurePassword,
                  onToggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter password';
                    if (val.trim().length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirm Password
                CustomAuthField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password *',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_reset,
                  isPassword: true,
                  isObscured: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Register & Store in Firestore',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: TextStyle(color: Colors.grey[600])),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

