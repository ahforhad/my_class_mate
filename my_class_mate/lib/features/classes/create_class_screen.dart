import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateClassScreen extends StatefulWidget {
  final String day;
  final Map<String, dynamic>? existing; // if not null => edit mode

  const CreateClassScreen({super.key, required this.day, this.existing});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController startCtrl;
  late final TextEditingController endCtrl;
  late final TextEditingController courseCtrl;
  late final TextEditingController teacherCtrl;
  late final TextEditingController roomCtrl;

  bool _saving = false;

  bool get _editMode => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final ex = widget.existing;

    startCtrl = TextEditingController(
      text: (ex?['start_time'] ?? '').toString(),
    );
    endCtrl = TextEditingController(text: (ex?['end_time'] ?? '').toString());
    courseCtrl = TextEditingController(
      text: (ex?['course_code'] ?? '').toString(),
    );
    teacherCtrl = TextEditingController(
      text: (ex?['teacher'] ?? '').toString(),
    );
    roomCtrl = TextEditingController(text: (ex?['room'] ?? '').toString());
  }

  @override
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    courseCtrl.dispose();
    teacherCtrl.dispose();
    roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final payload = {
        'day': widget.day,
        'start_time': startCtrl.text.trim(),
        'end_time': endCtrl.text.trim(),
        'course_code': courseCtrl.text.trim(),
        'teacher': teacherCtrl.text.trim(),
        'room': roomCtrl.text.trim(),
      };

      if (_editMode) {
        final id = widget.existing!['id'];
        await _client.from('class_routine').update(payload).eq('id', id);
      } else {
        await _client.from('class_routine').insert(payload);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1479FF);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editMode ? "Edit Routine" : "Add Routine"),
        centerTitle: true,
        backgroundColor: blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Day: ${widget.day}",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              _field(
                controller: startCtrl,
                label: "Start time (HH:MM)",
                hint: "08:50",
                validator: (v) => _timeValidate(v),
              ),
              const SizedBox(height: 12),

              _field(
                controller: endCtrl,
                label: "End time (HH:MM)",
                hint: "10:00",
                validator: (v) => _timeValidate(v),
              ),
              const SizedBox(height: 12),

              _field(
                controller: courseCtrl,
                label: "Course code",
                hint: "CSE-2231",
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),

              _field(
                controller: teacherCtrl,
                label: "Teacher (optional)",
                hint: "MNM",
                validator: (_) => null,
              ),
              const SizedBox(height: 12),

              _field(
                controller: roomCtrl,
                label: "Room (optional)",
                hint: "RKB-402 / ACL-3",
                validator: (_) => null,
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _editMode ? "Update" : "Add",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _timeValidate(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "Required";
    final ok = RegExp(r'^\d{2}:\d{2}$').hasMatch(s);
    if (!ok) return "Use HH:MM (example 08:50)";
    return null;
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
