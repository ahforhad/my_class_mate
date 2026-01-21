import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _ensureProfileRow(String uid) async {
    await supabase.from('profiles').upsert({
      'id': uid,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _loadProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final uid = user.id;

      await _ensureProfileRow(uid);

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        profile = data ?? {};
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Load failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = (profile?['name'] ?? 'No name').toString();
    final about = (profile?['about'] ?? 'No about information').toString();
    final skillsRaw = (profile?['skills'] ?? '').toString();
    final facebook = (profile?['facebook'] ?? '').toString();
    final github = (profile?['github'] ?? '').toString();
    final linkedin = (profile?['linkedin'] ?? '').toString();
    final avatar = (profile?['avatar_url'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 54,
              backgroundImage: avatar.trim().isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
              child: avatar.trim().isEmpty
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),

          Text(
            about,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 16),

          if (skillsRaw.trim().isNotEmpty) ...[
            const Text('Skills', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skillsRaw
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .map<Widget>((e) => Chip(label: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (facebook.trim().isNotEmpty) Text('Facebook: $facebook'),
          if (github.trim().isNotEmpty) Text('GitHub: $github'),
          if (linkedin.trim().isNotEmpty) Text('LinkedIn: $linkedin'),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              await _loadProfile();
            },
          ),
        ],
      ),
    );
  }
}
