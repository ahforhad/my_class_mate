import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:my_class_mate/features/auth/auth_gate.dart'; // UserRole + AuthGate
import 'role_badge.dart';

// Screens
import 'package:my_class_mate/features/dashboard/dashboard_screen.dart';
import 'package:my_class_mate/features/classes/classes_screen.dart';
import 'package:my_class_mate/features/announcements/announcement_list.dart';
import 'package:my_class_mate/features/profile/profile_screen.dart';

class AppDrawer extends StatefulWidget {
  final UserRole role;
  final String name;
  final String email;

  const AppDrawer({
    super.key,
    required this.role,
    required this.name,
    required this.email,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _client = Supabase.instance.client;

  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final row = await _client
          .from('profiles')
          .select('avatar_url, updated_at')
          .eq('id', uid)
          .maybeSingle();

      final url = row?['avatar_url'] as String?;
      final updatedAt = row?['updated_at']?.toString();

      final cacheBusted = (url != null && updatedAt != null)
          ? '$url?t=$updatedAt'
          : url;

      if (!mounted) return;
      setState(() {
        _avatarUrl = cacheBusted;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const drawerColor = Color(0xFF1479FF);

    final displayName = widget.name.isNotEmpty ? widget.name : 'User';
    final firstLetter = displayName[0].toUpperCase();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: drawerColor),
            accountName: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            accountEmail: Text(widget.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                  ? NetworkImage(_avatarUrl!)
                  : null,
              child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                  ? Text(
                      firstLetter,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: drawerColor,
                      ),
                    )
                  : null,
            ),
            otherAccountsPictures: [RoleBadge(role: widget.role)],
          ),

          // ✅ NAV ITEMS
          _nav(
            context,
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            page: const DashboardScreen(),
          ),
          _nav(
            context,
            icon: Icons.class_rounded,
            title: 'Classes',
            page: const ClassesScreen(),
          ),
          _nav(
            context,
            icon: Icons.campaign_rounded,
            title: 'Announcements',
            page: const AnnouncementListScreen(),
          ),
          _nav(
            context,
            icon: Icons.person_rounded,
            title: 'Profile',
            page: const ProfileScreen(),
          ),

          const Spacer(),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // close drawer
              await _client.auth.signOut();

              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _nav(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
