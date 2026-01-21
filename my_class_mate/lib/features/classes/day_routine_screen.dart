import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_gate.dart';

class DayRoutineScreen extends StatefulWidget {
  final String day;
  const DayRoutineScreen({super.key, required this.day});

  @override
  State<DayRoutineScreen> createState() => _DayRoutineScreenState();
}

class _DayRoutineScreenState extends State<DayRoutineScreen> {
  final _client = Supabase.instance.client;

  bool get _isAdmin =>
      (_client.auth.currentUser?.email ?? '').toLowerCase() == kAdminEmail;

  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

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
          .order('start_time');

      _rows = (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      _snack('Load failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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
    await _client.from('class_routine').delete().eq('id', id);
    _snack('Deleted');
    _load();
  }

  Future<void> _openForm({Map<String, dynamic>? row}) async {
    final isEdit = row != null;

    final start = TextEditingController(text: row?['start_time']);
    final end = TextEditingController(text: row?['end_time']);
    final course = TextEditingController(text: row?['course_code']);
    final teacher = TextEditingController(text: row?['teacher']);
    final room = TextEditingController(text: row?['room']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Class' : 'Add Class'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field(start, 'Start time (HH:MM)'),
              _field(end, 'End time (HH:MM)'),
              _field(course, 'Course code'),
              _field(teacher, 'Teacher'),
              _field(room, 'Room / Link'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'day': widget.day,
                'start_time': start.text.trim(),
                'end_time': end.text.trim(),
                'course_code': course.text.trim(),
                'teacher': teacher.text.trim(),
                'room': room.text.trim(),
              };

              if (isEdit) {
                await _client
                    .from('class_routine')
                    .update(data)
                    .eq('id', row['id']);
                _snack('Updated');
              } else {
                await _client.from('class_routine').insert(data);
                _snack('Added');
              }

              if (mounted) Navigator.pop(context);
              _load();
            },
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1479FF);
    const hint = Color(0xFF8A94A6);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
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
          : _rows.isEmpty
          ? Center(
              child: Text(
                _isAdmin
                    ? 'No classes yet. Tap + to add.'
                    : 'No classes today.',
                style: const TextStyle(
                  color: hint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = _rows[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.class_, color: blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['course_code'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${r['start_time']} - ${r['end_time']}',
                              style: const TextStyle(
                                color: hint,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if ((r['room'] ?? '').toString().isNotEmpty)
                              Text(
                                r['room'],
                                style: const TextStyle(color: hint),
                              ),
                          ],
                        ),
                      ),
                      if (_isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: blue),
                          onPressed: () => _openForm(row: r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(r['id']),
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
