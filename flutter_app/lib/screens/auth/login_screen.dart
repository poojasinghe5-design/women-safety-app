import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text('SafeHer', style: GoogleFonts.poppins(
                fontSize: 40, fontWeight: FontWeight.w800,
                color: const Color(0xFFE91E8C), letterSpacing: -1)),
              const SizedBox(height: 8),
              Text('Your personal safety companion', style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF666677))),
              const SizedBox(height: 50),
              Text('Sign In', style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF888899))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF888899)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF888899)),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.push('/register'),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: "Don't have an account? ",
                      style: GoogleFonts.poppins(color: const Color(0xFF666677))),
                    TextSpan(text: 'Sign Up',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE91E8C), fontWeight: FontWeight.w600)),
                  ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
