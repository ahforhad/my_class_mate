import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_gate.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  final _client = Supabase.instance.client;

  bool get _isAdmin =>
      (_client.auth.currentUser?.email ?? '').toLowerCase() == kAdminEmail;

  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      _items = (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _snack('Load failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _delete(String id) async {
    await _client.from('announcements').delete().eq('id', id);
    _snack('Deleted');
    _load();
  }

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final isEdit = item != null;

    final titleCtrl = TextEditingController(text: item?['title']);
    final bodyCtrl = TextEditingController(text: item?['body']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Announcement' : 'New Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleCtrl.text.trim(),
                'body': bodyCtrl.text.trim(),
              };

              if (isEdit) {
                await _client
                    .from('announcements')
                    .update(data)
                    .eq('id', item['id']);
                _snack('Updated');
              } else {
                await _client.from('announcements').insert(data);
                _snack('Posted');
              }

              if (mounted) Navigator.pop(context);
              _load();
            },
            child: Text(isEdit ? 'Save' : 'Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1479FF);
    const hint = Color(0xFF8A94A6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        centerTitle: true,
        backgroundColor: blue,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: blue,
              onPressed: () => _openForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
              child: Text(
                'No announcements yet',
                style: TextStyle(color: hint, fontWeight: FontWeight.w700),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = _items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign, color: blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a['body'],
                              style: const TextStyle(color: hint),
                            ),
                          ],
                        ),
                      ),
                      if (_isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: blue),
                          onPressed: () => _openForm(item: a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(a['id']),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
