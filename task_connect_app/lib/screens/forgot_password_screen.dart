import 'package:flutter/material.dart';
import 'package:task_connect_app/services/api_service.dart';

enum _ResetStage { email, code, password, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  _ResetStage stage = _ResetStage.email;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Enter a valid email');
      return;
    }
    setState(() => isLoading = true);
    try {
      await ApiService.requestPasswordReset(email);
      _showSnack('If registered, a reset code has been sent.');
      setState(() => stage = _ResetStage.code);
    } catch (e) {
      _showSnack('Failed to request reset: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    if (code.length < 4) {
      _showSnack('Enter the code sent to your email');
      return;
    }
    setState(() => isLoading = true);
    try {
      await ApiService.verifyResetCode(email, code);
      _showSnack('Code verified. Enter a new password.');
      setState(() => stage = _ResetStage.password);
    } catch (e) {
      _showSnack('Code verification failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      _showSnack('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.resetPassword(email, code, password, confirmPassword);
      setState(() => stage = _ResetStage.success);
    } catch (e) {
      _showSnack('Reset failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3E5FC),
              Color.fromARGB(255, 170, 198, 218),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (stage == _ResetStage.email) _buildEmailStep(colorScheme),
                    if (stage == _ResetStage.code) _buildCodeStep(colorScheme),
                    if (stage == _ResetStage.password)
                      _buildPasswordStep(colorScheme),
                    if (stage == _ResetStage.success)
                      _buildSuccessStep(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(ColorScheme colorScheme) {
    return Column(
      children: [
        const Text(
          'Forgot your password?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter the email associated with your account. We will send you a verification code.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _requestCode,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Send Code'),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep(ColorScheme colorScheme) {
    return Column(
      children: [
        const Text(
          'Enter Verification Code',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a 6-digit code to ${emailController.text.trim()}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            prefixIcon: Icon(Icons.check_circle_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _verifyCode,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Verify Code'),
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : _requestCode,
          child: const Text('Resend code'),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(ColorScheme colorScheme) {
    return Column(
      children: [
        const Text(
          'Set a New Password',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resetPassword,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Reset Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(ColorScheme colorScheme) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 12),
        const Text(
          'Password Updated!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can now log in with your new password.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }
}

