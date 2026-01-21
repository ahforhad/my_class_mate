import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_gate.dart';
import 'create_class_screen.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String day;
  const ClassDetailsScreen({super.key, required this.day});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  bool get _isAdmin {
    final email = (_client.auth.currentUser?.email ?? '').toLowerCase();
    return email == kAdminEmail;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _client
          .from('class_routine')
          .select()
          .eq('day', widget.day)
          .order('start_time', ascending: true);

      setState(() => _items = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Load failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _client.from('class_routine').delete().eq('id', id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1479FF);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
        centerTitle: true,
        backgroundColor: blue,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: blue,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateClassScreen(day: widget.day),
                  ),
                );
                _load();
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
              child: Text(
                "No classes for this day",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final x = _items[i];

                final id = x['id'].toString();
                final start = (x['start_time'] ?? '').toString();
                final end = (x['end_time'] ?? '').toString();
                final course = (x['course_code'] ?? '').toString();
                final teacher = (x['teacher'] ?? '').toString();
                final room = (x['room'] ?? '').toString();

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$start\n-\n$end",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                teacher,
                                room,
                              ].where((s) => s.trim().isNotEmpty).join(" • "),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8A94A6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isAdmin) ...[
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateClassScreen(
                                  day: widget.day,
                                  existing: x,
                                ),
                              ),
                            );
                            _load();
                          },
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => _delete(id),
                          icon: const Icon(Icons.delete_rounded),
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
