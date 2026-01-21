import 'package:flutter/material.dart';
import 'day_routine_screen.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  static const List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1479FF);
    const hint = Color(0xFF8A94A6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Routine'),
        centerTitle: true,
        backgroundColor: blue,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final day = _days[i];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DayRoutineScreen(day: day)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Text(
                    "View",
                    style: TextStyle(color: hint, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: hint),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
