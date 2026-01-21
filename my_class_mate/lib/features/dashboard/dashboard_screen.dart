import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_drawer.dart';
import '../auth/auth_gate.dart';
import '../classes/classes_screen.dart';
import '../announcements/announcement_list.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color primary = Color(0xFF4F46E5);
  static const Color textMain = Color(0xFF0F172A);

  UserRole _roleFromEmail(String? email) {
    return (email ?? '').toLowerCase() == kAdminEmail
        ? UserRole.admin
        : UserRole.student;
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    final email = user?.email ?? '';
    final name = (user?.userMetadata?['name'] ?? 'User').toString();
    final role = _roleFromEmail(email);

    return Scaffold(
      backgroundColor: bg,
      drawer: AppDrawer(role: role, name: name, email: email),

      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: textMain,
      ),

      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
        children: [
          _IconTile(
            icon: Icons.class_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClassesScreen()),
            ),
          ),
          _IconTile(
            icon: Icons.campaign_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnnouncementListScreen()),
            ),
          ),
          _IconTile(
            icon: Icons.person_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          _IconTile(
            icon: Icons.logout_rounded,
            color: Colors.red,
            onTap: () async {
              await client.auth.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _IconTile({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF4F46E5);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(child: Icon(icon, size: 42, color: c)),
      ),
    );
  }
}
