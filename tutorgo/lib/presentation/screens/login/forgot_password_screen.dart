import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_step_learning/data/providers/auth_provider.dart';
import 'package:next_step_learning/data/services/auth_service.dart';
import '../../../core/utils/size_config.dart';
import '../../components/animations/fade_in.dart';
import '../../widgets/phone_number_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // 0 = verify identity (email + phone), 1 = set new password
  int _step = 0;
  String _phone = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _resetToken = '';

  AuthService get _authService =>
      AuthService(baseUrl: context.read<AuthProvider>().baseUrl);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _verifyIdentity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await _authService.verifyIdentity(
        email: _emailController.text.trim(),
        phone: _phone.trim(),
      );

      if (!mounted) return;
      setState(() {
        _resetToken = result['resetToken'] ?? '';
        _step = 1;
      });
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        resetToken: _resetToken,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated. Please log in with your new password.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _field({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
      child: child,
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: SizeConfig.w(300),
        padding: EdgeInsets.symmetric(vertical: SizeConfig.h(14)),
        decoration: BoxDecoration(
          color: _isLoading
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      children: [
        FadeIn(
          delay: 150,
          child: Text(
            "Enter the email and phone number on your account to verify it's you.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(height: SizeConfig.h(24)),
        FadeIn(
          delay: 250,
          child: _field(
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
              decoration: _decoration(
                label: 'Email',
                icon: Icons.email_rounded,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(18)),
        FadeIn(
          delay: 350,
          child: _field(
            child: PhoneNumberField(
              onChanged: (value) => _phone = value,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(30)),
        FadeIn(
          delay: 450,
          child: _primaryButton(label: 'Verify', onTap: _verifyIdentity),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        FadeIn(
          delay: 150,
          child: Text(
            'Identity verified. Create your new password.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(height: SizeConfig.h(24)),
        FadeIn(
          delay: 250,
          child: _field(
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              decoration: _decoration(
                label: 'New Password',
                icon: Icons.lock_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(20)),
        FadeIn(
          delay: 350,
          child: _field(
            child: TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: _decoration(
                label: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(30)),
        FadeIn(
          delay: 450,
          child: _primaryButton(label: 'Reset Password', onTap: _resetPassword),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final titles = ['Forgot Password', 'New Password'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              setState(() => _step -= 1);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.h(10)),
                FadeIn(
                  delay: 100,
                  child: SizedBox(
                    height: SizeConfig.h(90),
                    width: SizeConfig.h(150),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(20)),
                Text(
                  titles[_step],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: SizeConfig.h(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(30)),
                  child: _step == 0
                      ? _buildIdentityStep()
                      : _buildPasswordStep(),
                ),
                SizedBox(height: SizeConfig.h(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
