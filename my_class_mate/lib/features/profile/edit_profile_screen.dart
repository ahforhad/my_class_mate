// lib/features/profile/edit_profile_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final studentIdCtrl = TextEditingController(); // ✅ NEW
  final aboutCtrl = TextEditingController();
  final skillsCtrl = TextEditingController();
  final fbCtrl = TextEditingController();
  final githubCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageExt;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    studentIdCtrl.dispose(); // ✅ NEW
    aboutCtrl.dispose();
    skillsCtrl.dispose();
    fbCtrl.dispose();
    githubCtrl.dispose();
    linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (data == null) return;

    nameCtrl.text = (data['name'] ?? '').toString();
    studentIdCtrl.text = (data['student_id'] ?? '').toString(); // ✅ NEW
    aboutCtrl.text = (data['about'] ?? '').toString();
    skillsCtrl.text = (data['skills'] ?? '').toString();
    fbCtrl.text = (data['facebook'] ?? '').toString();
    githubCtrl.text = (data['github'] ?? '').toString();
    linkedinCtrl.text = (data['linkedin'] ?? '').toString();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageExt = file.path.split('.').last.toLowerCase();
    });
  }

  Future<String?> _uploadAvatar() async {
    if (_imageBytes == null) return null;

    final uid = supabase.auth.currentUser!.id;
    final ext = (_imageExt == null || _imageExt!.isEmpty) ? 'jpg' : _imageExt!;
    final path = '$uid/avatar.$ext';

    await supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          _imageBytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _save() async {
    setState(() => loading = true);

    try {
      final uid = supabase.auth.currentUser!.id;

      // upload avatar only if selected
      String? avatarUrl;
      if (_imageBytes != null) {
        avatarUrl = await _uploadAvatar();
      }

      // ✅ Use UPSERT so it works even if profile row doesn't exist yet
      await supabase.from('profiles').upsert({
        'id': uid,
        'name': nameCtrl.text.trim(),
        'student_id': studentIdCtrl.text.trim(), // ✅ NEW
        'about': aboutCtrl.text.trim(),
        'skills': skillsCtrl.text.trim(),
        'facebook': fbCtrl.text.trim(),
        'github': githubCtrl.text.trim(),
        'linkedin': linkedinCtrl.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('Name', nameCtrl),
          _field('Student ID', studentIdCtrl), // ✅ NEW
          _field('About', aboutCtrl, maxLines: 3),
          _field('Skills (comma separated)', skillsCtrl),
          _field('Facebook', fbCtrl),
          _field('GitHub', githubCtrl),
          _field('LinkedIn', linkedinCtrl),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text('Pick Image'),
            onPressed: _pickImage,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading ? null : _save,
            child: loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
