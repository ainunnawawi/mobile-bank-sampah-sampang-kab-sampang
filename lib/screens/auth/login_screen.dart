import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'register_screen.dart'; 
import '../dashboard/dashboard_screen.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Gambar Ilustrasi Background (Opsional jika ada asset-nya)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Bg-flutter.jpeg', // Ganti dengan nama file background kamu
              fit: BoxFit.cover, // Biar gambarnya memenuhi layar HP
            ),
          ),
          
          // 2. Form Login
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo & Brand SAJUANG
                  Center(
                    child: Column(
                      children: [
                        // Placeholder Logo (Ganti dengan Image.asset jika asset logo sudah ada)
                        Image.asset(
                          'assets/images/Logo.png', // Ganti dengan nama file logo kamu
                          width: 160,       // Atur lebar logo
                          height: 160,      // Atur tinggi logo
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Teks Sapaan
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masuk Untuk Melanjutkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Field Email / No HP
                  const Text(
                    'Email / no.HP',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan email atau no.HP',
                      filled: true,
                      fillColor: AppColors.primarySage.withOpacity(0.35),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Field Password
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Masukkan Password',
                      filled: true,
                      fillColor: AppColors.primarySage.withOpacity(0.35),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color.fromARGB(255, 252, 252, 252),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  // Lupa Password Link
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Masuk
                  ElevatedButton(
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email dan password wajib diisi!')),
                        );
                        return;
                      }

                      // Tampilkan loading dialog sederhana
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // Panggil ApiService
                      final result = await ApiService.login(email: email, password: password);

                      // Tutup loading dialog
                      if (context.mounted) Navigator.pop(context);

                      if (result['success'] == true) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'] ?? 'Login Berhasil!')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 2, 143, 101),
                        
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Banner Registrasi (Belum punya akun? Daftar di sini)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 230, 253, 238).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                        // Cari GestureDetector 'Daftar di sini' di bagian bawah
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Daftar di sini',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}