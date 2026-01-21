import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lrqvdhahkercisoeyeeu.supabase.co',
    anonKey: 'sb_publishable_iNZKP8pL83uGayy3kZf0Qw_GRzKnDiy',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'my_class_mate',
      home: AuthGate(),
    );
  }
}
