import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  final RegExp nameRegex = RegExp(r'^[A-Za-z .]+$');
  final RegExp emailRegex = RegExp(r'^cse_0182320012101[0-9]{3}@lus\.ac\.bd$');
  final RegExp batchRegex = RegExp(r'^62$');
  final RegExp deptRegex = RegExp(r'^CSE$');
  final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
  );

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    batchController.dispose();
    deptController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': nameController.text.trim(),
          'batch': batchController.text.trim(),
          'dept': deptController.text.trim(),
        },
      );

      if (res.user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signup failed: user not created"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered! Now login with your email & password."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF1479FF);
    const Color textDark = Color(0xFF2F3640);
    const Color hint = Color(0xFF8A94A6);

    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    height: screenHeight > 700 ? 220 : screenHeight * 0.28,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/university_header.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Name"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: nameController,
                        hintText: "Your name",
                        prefixIcon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (!nameRegex.hasMatch(v.trim())) {
                            return "Invalid format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _label("Email"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: emailController,
                        hintText: "cse_0182320012101xxx@lus.ac.bd",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (!emailRegex.hasMatch(v.trim().toLowerCase())) {
                            return "Invalid format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _label("Batch"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: batchController,
                        hintText: "62",
                        prefixIcon: Icons.confirmation_number_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (!batchRegex.hasMatch(v.trim())) {
                            return "Invalid format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _label("Department"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: deptController,
                        hintText: "CSE",
                        prefixIcon: Icons.school_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (!deptRegex.hasMatch(v.trim())) {
                            return "Invalid format";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _label("Password"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: passwordController,
                        hintText: "••••••••",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          splashRadius: 20,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: hint,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (!passwordRegex.hasMatch(v)) {
                            return "Invalid format";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                      _label("Confirm Password"),
                      const SizedBox(height: 8),
                      _pillField(
                        controller: confirmPasswordController,
                        hintText: "••••••••",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "This field cannot be empty";
                          }
                          if (v != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            disabledBackgroundColor: blue.withOpacity(0.55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: hint),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8A94A6),
      ),
    );
  }

  Widget _pillField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0B7C3)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF8A94A6)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1479FF), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    );
  }
}
