import 'package:flutter/material.dart';
import '../../features/auth/auth_gate.dart'; // gives UserRole

// enum UserRole { admin, student }

class RoleBadge extends StatelessWidget {
  final UserRole role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;

    return Chip(
      label: Text(isAdmin ? 'Admin' : 'Student'),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isAdmin ? Colors.redAccent : Colors.green,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
