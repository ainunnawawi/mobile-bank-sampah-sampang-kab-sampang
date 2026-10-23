import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../dashboard/dashboard_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Landing Register, 1: Step 1 Data Diri, 2: Step 2 Akun, 3: Step 3 Selesai
  bool _isLoading = false;

  // Controllers Step 1
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String? _selectedGender;

  // Controllers Step 2
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override

  Future<void> _handleRegister() async {
    // 1. Validasi sederhana input form
    if (_namaController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data wajib'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 2. Memanggil ApiService.register()
    final result = await ApiService.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    // 3. Menangani Respon Balasan API
    if (result['success']) {
      // Jika sukses register & dapat token, lanjut ke Step 3 (Selesai)
      _nextPage();
    } else {
      // Menampilkan pesan error jika registrasi gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Biar ga bisa diswipe manual
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            _buildLandingRegister(),
            _buildStep1DataDiri(),
            _buildStep2InformasiAkun(),
            _buildStep3Selesai(),
          ],
        ),
      ),
    );
  }

  // --- 0. LANDING REGISTER ---
  Widget _buildLandingRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo & Name
          const Icon(Icons.recycling, size: 60, color: AppColors.primarySage),
          const SizedBox(height: 8),
          const Text('SAJUANG', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const Text('Sampah Jadi Uang', style: TextStyle(color: AppColors.textDark)),
          const SizedBox(height: 40),

          // Container White Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                const Text('Buat Akun Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text('Yuk Daftar dan mulai menabung Sampah Bersama SAJUANG!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDark, fontSize: 13)),
                const SizedBox(height: 24),

                // List Steps Summary
                _buildSummaryTile(Icons.person_outline, 'Isi Data diri'),
                const SizedBox(height: 12),
                _buildSummaryTile(Icons.badge_outlined, 'Informasi Akun'),
                const SizedBox(height: 12),
                _buildSummaryTile(Icons.check_circle_outline, 'Akun siap digunakan'),
                
                const SizedBox(height: 30),

                // Button Mulai Daftar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySage,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Mulai Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textDark)),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Kembali ke LoginScreen
                },
                child: const Text(
                  'Login disini',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 1. STEP 1: DATA DIRI ---
  Widget _buildStep1DataDiri() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperHeader(1, 'Data Diri', 'Lengkapi Data Diri Anda'),
          const SizedBox(height: 24),

          _buildInputField('Nama Lengkap', _namaController, 'Masukkan Nama Lengkap'),
          const SizedBox(height: 16),
          _buildInputField('No.HP', _noHpController, '08...'),
          const SizedBox(height: 16),
          _buildInputField('Email (opsional)', _emailController, 'contoh.@gmail.com'),
          const SizedBox(height: 16),
          
          // Tanggal Lahir
          const Text('Tanggal Lahir', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextField(
            controller: _tglLahirController,
            readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _tglLahirController.text = "${picked.day}/${picked.month}/${picked.year}";
              }
            },
            decoration: _inputDecoration('Pilih tanggal Lahir', suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20)),
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin Dropdown
          const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: _inputDecoration('pilih jenis kelamin'),
            items: ['Laki-laki', 'Perempuan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySage,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Lanjut', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. STEP 2: INFORMASI AKUN ---
  Widget _buildStep2InformasiAkun() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperHeader(2, 'Informasi Akun', ''),
          const SizedBox(height: 24),

          // Password
          const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: _inputDecoration(
              'Minimal 8 karakter',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Konfirmasi Password
          const Text('Konfirmasi Password', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmVisible,
            decoration: _inputDecoration(
              'Masukkan Kembali Password',
              suffixIcon: IconButton(
                icon: Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Validation Rules Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySage.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password harus mengandung', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                _buildCheckItem('Minimal 8 karakter'),
                _buildCheckItem('Huruf dan Angka'),
                _buildCheckItem('Minimal 1 Huruf Besar'),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister, // <--- Panggil fungsi _handleRegister di sini
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySage,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Lanjut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  // --- 3. STEP 3: SELESAI ---
  Widget _buildStep3Selesai() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepperHeader(3, 'Selesai', ''),
          const Spacer(),

          // Mascot / Success Illustration
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primarySage.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_nature_rounded, size: 90, color: AppColors.primarySage),
          ),
          const SizedBox(height: 24),

          const Text(
            'Akun Berhasil Dibuat',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          const Text(
            'Selamat bergabung di Bank Sampah SAJUANG yuk mulai menabung sampah untuk lingkungan yang lebih bersih!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark, height: 1.4),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Selesai -> Kembalikan ke Login Screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySage,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Mulai Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSummaryTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySage.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textDark),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(int activeStep, String stepTitle, String subtitle) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleStep(1, activeStep >= 1),
            _buildLineStep(activeStep >= 2),
            _buildCircleStep(2, activeStep >= 2),
            _buildLineStep(activeStep >= 3),
            _buildCircleStep(3, activeStep >= 3),
          ],
        ),
        const SizedBox(height: 12),
        Text('Step $activeStep - $stepTitle', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
        ]
      ],
    );
  }

  Widget _buildCircleStep(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySage : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('$step', style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLineStep(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppColors.primarySage : Colors.grey.shade300,
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.primarySage.withOpacity(0.15),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 18, color: AppColors.primarySage),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
      ],
    );
  }
}