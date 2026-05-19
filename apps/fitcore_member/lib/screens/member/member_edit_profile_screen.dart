import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../providers/member_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_guard.dart';

/// Edit member profile (mock — persists to local storage via [AuthService]).
class MemberEditProfileScreen extends ConsumerStatefulWidget {
  const MemberEditProfileScreen({super.key});

  @override
  ConsumerState<MemberEditProfileScreen> createState() => _MemberEditProfileScreenState();
}

class _MemberEditProfileScreenState extends ConsumerState<MemberEditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _saving = false;

  bool _fieldsInitialized = false;

  void _initFields() {
    if (_fieldsInitialized) return;
    _fieldsInitialized = true;
    final user = ref.read(authServiceProvider);
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(authServiceProvider.notifier).updateProfile(name: name, email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFields();
    final membership = ref.watch(memberMembershipProvider);

    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          title: Text(
            'Edit profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(
                labelText: 'Full name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gym: ${membership.gymName}\nDesk ID: ${membership.memberDeskId}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 24),
            FitCoreButton(
              label: _saving ? 'Saving…' : 'Save changes',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
