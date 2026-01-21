import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../dashboard/dashboard_screen.dart';

/// ✅ Admin email
const String kAdminEmail = 'admin@lus.ac.bd';

enum UserRole { admin, student }

UserRole roleFromEmail(String? email) {
  final e = (email ?? '').toLowerCase();
  return e == kAdminEmail ? UserRole.admin : UserRole.student;
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = auth.currentUser;
        if (user == null) return const LoginPage();
        return const DashboardScreen();
      },
    );
  }
}
