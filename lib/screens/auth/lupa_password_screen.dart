import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class LupaPasswordScreen extends StatefulWidget {
  final String? deepLinkToken;
  final String? deepLinkEmail;

  const LupaPasswordScreen({
    super.key,
    this.deepLinkToken,
    this.deepLinkEmail,
  });

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailSubmitted = false;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void initState() {
    super.initState();
    // Jika masuk lewat Deep Link reset password (sajuang://reset-password)
    if (widget.deepLinkToken != null && widget.deepLinkEmail != null) {
      _emailController.text = widget.deepLinkEmail!;
      _isEmailSubmitted = true; // langsung tampilkan form password baru
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 1. Kirim Email Minta Reset Password
  Future<void> _kirimEmailReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email Anda!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.kirimResetPasswordEmail(email: email);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        setState(() => _isEmailSubmitted = true);
      }
    }
  }

  // 2. Simpan Password Baru
  Future<void> _resetPasswordBaru() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi password baru!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.submitPasswordBaru(
      email: _emailController.text.trim(),
      token: widget.deepLinkToken ?? '',
      password: password,
      passwordConfirmation: confirm,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context); // Kembali ke halaman Login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primarySage,
        elevation: 0,
        title: const Text(
          'Lupa Password',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Jika token deep link ada, tampilkan Form Buat Password Baru
            widget.deepLinkToken != null || (_isEmailSubmitted && widget.deepLinkToken != null)
                ? _buildFormPasswordBaru()
                : _isEmailSubmitted
                    ? _buildTampilanCekEmail()
                    : _buildFormMintaEmail(),
          ],
        ),
      ),
    );
  }

  // Form Step 1: Input Email
  Widget _buildFormMintaEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_rounded, size: 80, color: AppColors.primarySage),
        const SizedBox(height: 16),
        const Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan email terdaftar Anda. Kami akan mengirimkan link untuk me-reset password akun Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 32),

        const Text('Email Terdaftar', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'contoh@gmail.com',
            filled: true,
            fillColor: AppColors.primarySage.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),

        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _kirimEmailReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarySage,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Kirim Link Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  // Pesan Instruksi Setelah Email Dikirim
  Widget _buildTampilanCekEmail() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.mark_email_read_rounded, size: 80, color: AppColors.primarySage),
        const SizedBox(height: 16),
        const Text(
          'Cek Email Anda',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          'Link reset password telah dikirim ke:\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const Text(
          'Buka email tersebut di HP ini dan klik link yang tersedia untuk membuat password baru.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45, fontSize: 13),
        ),
        const SizedBox(height: 40),
        OutlinedButton(
          onPressed: () => setState(() => _isEmailSubmitted = false),
          child: const Text('Ubah Email'),
        ),
      ],
    );
  }

  // Form Step 2: Input Password Baru (dari Link)
  Widget _buildFormPasswordBaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Buat Password Baru',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ketik password baru untuk akun Anda',
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 24),

        const Text('Password Baru', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Minimal 8 karakter',
            filled: true,
            fillColor: AppColors.primarySage.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Konfirmasi Password Baru', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmVisible,
          decoration: InputDecoration(
            hintText: 'Ulangi password baru',
            filled: true,
            fillColor: AppColors.primarySage.withOpacity(0.15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: IconButton(
              icon: Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
            ),
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _isLoading ? null : _resetPasswordBaru,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarySage,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Simpan Password Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}