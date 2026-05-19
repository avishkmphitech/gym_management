import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_logo.dart';
import '../../services/auth_service.dart';

/// Gym invitation / first-login password setup (prototype).
class InvitationSetupScreen extends ConsumerStatefulWidget {
  const InvitationSetupScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<InvitationSetupScreen> createState() => _InvitationSetupScreenState();
}

class _InvitationSetupScreenState extends ConsumerState<InvitationSetupScreen> {
  late final TextEditingController _emailController = TextEditingController(text: widget.initialEmail ?? '');
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider.notifier).completeInvitationSetup(
            email: _emailController.text,
            password: _passwordController.text,
            fullName: _nameController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account ready. Sign in with your new password.')),
        );
        context.go('/login');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(backgroundColor: AppColors.primaryBg, title: const Text('Set up account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: FitCoreLogo(size: 48)),
            const SizedBox(height: 20),
            Text(
              'Complete your profile',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Your gym created this account. Set a password to continue (demo emails: member@, trainer@, reception@fitcore.com).',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(labelText: 'Email from invitation', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(labelText: 'Confirm password', border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Finish setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
