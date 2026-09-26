import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(title: Text('Create Account',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, color: Color(0xFF888899)))),
            const SizedBox(height: 16),
            TextField(controller: _emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF888899)))),
            const SizedBox(height: 16),
            TextField(controller: _phoneCtrl,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF888899)))),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFF888899)))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
