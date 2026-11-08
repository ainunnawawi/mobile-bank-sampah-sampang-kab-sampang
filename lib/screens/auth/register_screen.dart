import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  final String? deepLinkToken;
  final String? deepLinkEmail;

  const RegisterScreen({
    super.key,
    this.deepLinkToken,
    this.deepLinkEmail,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Landing, 1: Data Diri, 2: Verifikasi Email, 3: Buat Password, 4: Selesai
  bool _isLoading = false;

  // Controllers Step 1 (Data Diri)
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String? _selectedGender;

  // Controllers Buat Password Baru
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  // Validator Password Dinamis
  bool get _isMinLength => _passwordController.text.length >= 8;
  bool get _hasLetterAndNumber =>
      _passwordController.text.contains(RegExp(r'(?=.*[A-Za-z])(?=.*\d)'));
  bool get _hasUppercase =>
      _passwordController.text.contains(RegExp(r'[A-Z]'));

  @override
  void initState() {
    super.initState();
    // Jika layar dibuka dari Deep Link (bawa token & email dari URL email)
    if (widget.deepLinkToken != null && widget.deepLinkEmail != null) {
      _emailController.text = widget.deepLinkEmail!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(3); // Direct ke Step Buat Password
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _tglLahirController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 1. Fungsi Kirim Email Verifikasi (Dipanggil di Step Data Diri)
  Future<void> _handleKirimVerifikasi() async {
    if (_namaController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan Email wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil API backend untuk kirim link email verifikasi
    final result = await ApiService.kirimVerifikasiEmail(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _noHpController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _nextPage(); // Lanjut ke Step 2 (Halaman Instruksi Cek Email)
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim email verifikasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 2. Fungsi Simpan Password & Selesaikan Akun (Dipanggil di Step Password)
  Future<void> _handleSetPassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi password dan konfirmasi password!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isMinLength || !_hasLetterAndNumber || !_hasUppercase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password belum memenuhi seluruh kriteria keamanan!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.setPasswordRegister(
      email: _emailController.text.trim(),
      token: widget.deepLinkToken ?? '',
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _nextPage(); // Lanjut ke Step Selesai
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menyimpan password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentStep = index;
            });
          },
          children: [
            _buildLandingRegister(),
            _buildStep1DataDiri(),
            _buildStep2CekEmail(),
            _buildStep3BuatPassword(),
            _buildStep4Selesai(),
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
          const Icon(Icons.recycling, size: 60, color: AppColors.primarySage),
          const SizedBox(height: 8),
          const Text('SAJUANG', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const Text('Sampah Jadi Uang', style: TextStyle(color: AppColors.textDark)),
          const SizedBox(height: 40),

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

                _buildSummaryTile(Icons.person_outline, 'Isi Data Diri & Email'),
                const SizedBox(height: 12),
                _buildSummaryTile(Icons.mark_email_read_outlined, 'Verifikasi Email'),
                const SizedBox(height: 12),
                _buildSummaryTile(Icons.lock_outline, 'Buat Password Akun'),

                const SizedBox(height: 30),

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
                onTap: () => Navigator.pop(context),
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
          _buildStepperHeader(1, 'Data Diri', 'Lengkapi Data Diri & Email Anda'),
          const SizedBox(height: 24),

          _buildInputField('Nama Lengkap', _namaController, 'Masukkan Nama Lengkap'),
          const SizedBox(height: 16),
          _buildInputField('No. HP', _noHpController, '08...'),
          const SizedBox(height: 16),
          _buildInputField('Email Verifikasi', _emailController, 'contoh@gmail.com'),
          const SizedBox(height: 16),

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
            onPressed: _isLoading ? null : _handleKirimVerifikasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySage,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Kirim Kode Verifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 2. STEP 2: CEK EMAIL (INSTRUKSI VERIFIKASI) ---
  Widget _buildStep2CekEmail() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepperHeader(2, 'Verifikasi Email', ''),
          const Spacer(),

          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primarySage.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded, size: 70, color: AppColors.primarySage),
          ),
          const SizedBox(height: 24),

          const Text(
            'Cek Email Anda',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Kami telah mengirimkan link verifikasi ke email:\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textDark, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Silakan klik link di email Anda untuk melanjutkan pembuatan password akun.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primarySage),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Sudah Verifikasi? Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primarySage)),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. STEP 3: INFORMASI AKUN (BUAT PASSWORD DINAMIS) ---
  Widget _buildStep3BuatPassword() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperHeader(3, 'Buat Password', 'Buat Password Akun Baru Anda'),
          const SizedBox(height: 24),

          const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            onChanged: (val) {
              setState(() {}); // Refresh otomatis saat mengetik untuk mengecek syarat password
            },
            decoration: _inputDecoration(
              'Minimal 8 karakter',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 16),

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

          // Box Kriteria Password (Dinamis Real-time)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySage.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password harus mengandung:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 10),
                _buildCheckItem('Minimal 8 karakter', _isMinLength),
                const SizedBox(height: 6),
                _buildCheckItem('Huruf dan Angka', _hasLetterAndNumber),
                const SizedBox(height: 6),
                _buildCheckItem('Minimal 1 Huruf Besar', _hasUppercase),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySage,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan & Selesaikan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 4. STEP 4: SELESAI ---
  Widget _buildStep4Selesai() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepperHeader(4, 'Selesai', ''),
          const Spacer(),

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
            'Selamat bergabung di Bank Sampah SAJUANG! Yuk mulai menabung sampah untuk lingkungan yang lebih bersih!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark, height: 1.4),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
            _buildLineStep(activeStep >= 4),
            _buildCircleStep(4, activeStep >= 4),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Step $activeStep - $stepTitle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
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

  // Helper Widget Item Syarat Password (Hijau/Merah Dinamis)
  Widget _buildCheckItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isValid ? FontWeight.bold : FontWeight.normal,
            color: isValid ? Colors.green.shade800 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}