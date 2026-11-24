import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  bool _isLoading = false;

  // Controllers Step 1 (Data Diri)
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _tglLahirController = TextEditingController();
  String? _selectedGender;

  // Controllers Step 2 (Buat Password)
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  // Validator Password Dinamis
  bool get _isMinLength => _passwordController.text.length >= 8;
  bool get _hasLetterAndNumber =>
      _passwordController.text.contains(RegExp(r'(?=.*[A-Za-z])(?=.*\d)'));
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));

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

  void _handleLanjutBuatPassword() {
    if (_namaController.text.trim().isEmpty ||
        _noHpController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Lengkap, No. HP, dan Email wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _nextPage();
  }

  Future<void> _handleRegisterSelesai() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
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

    final result = await ApiService.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _noHpController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _nextPage();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal membuat akun'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Wrapper pembantu agar setiap halaman punya tinggi penuh & tombol di bagian bawah
  Widget _buildBottomPinnedStep({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48.0,
            ),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildLandingRegister(),
            _buildStep1DataDiri(),
            _buildStep2BuatPassword(),
            _buildStep3Selesai(),
          ],
        ),
      ),
    );
  }

  // --- 0. LANDING REGISTER ---
  Widget _buildLandingRegister() {
    return _buildBottomPinnedStep(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.recycling, size: 60, color: AppColors.primarySage),
          const SizedBox(height: 8),
          const Text(
            'SAJUANG',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const Text(
            'Sampah Jadi Uang',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDark),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yuk Daftar dan mulai menabung Sampah Bersama SAJUANG!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 13),
                ),
                const SizedBox(height: 24),

                _buildSummaryTile(Icons.person_outline, 'Isi Data Diri'),
                const SizedBox(height: 12),
                _buildSummaryTile(Icons.lock_outline, 'Buat Password Akun'),
                const SizedBox(height: 12),
                _buildSummaryTile(
                  Icons.check_circle_outline,
                  'Akun Siap Digunakan',
                ),
              ],
            ),
          ),

          const Spacer(),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySage,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Mulai Daftar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
                'Sudah punya akun? ',
                style: TextStyle(color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Login disini',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
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
    return _buildBottomPinnedStep(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperHeader(1, 'Data Diri', 'Lengkapi Data Diri Anda'),
          const SizedBox(height: 24),

          _buildInputField(
            'Nama Lengkap',
            _namaController,
            'Masukkan Nama Lengkap',
          ),
          const SizedBox(height: 16),
          _buildInputField('No. HP', _noHpController, '08...', isNumber: true),
          const SizedBox(height: 16),
          _buildInputField('Email', _emailController, 'contoh@gmail.com'),
          const SizedBox(height: 16),

          const Text(
            'Tanggal Lahir',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
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
                _tglLahirController.text =
                    "${picked.day}/${picked.month}/${picked.year}";
              }
            },
            decoration: _inputDecoration(
              'Pilih tanggal Lahir',
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: _inputDecoration('Pilih jenis kelamin'),
            items: [
              'Laki-laki',
              'Perempuan',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),

          const Spacer(),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLanjutBuatPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySage,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Lanjut Buat Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. STEP 2: BUAT PASSWORD ---
  Widget _buildStep2BuatPassword() {
    return _buildBottomPinnedStep(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepperHeader(
            2,
            'Buat Password',
            'Buat Password Akun Baru Anda',
          ),
          const SizedBox(height: 24),

          const Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            onChanged: (val) => setState(() {}),
            decoration: _inputDecoration(
              'Minimal 8 karakter',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Konfirmasi Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmVisible,
            decoration: _inputDecoration(
              'Masukkan Kembali Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isConfirmVisible = !_isConfirmVisible),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySage.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password harus mengandung:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                _buildCheckItem('Minimal 8 karakter', _isMinLength),
                const SizedBox(height: 6),
                _buildCheckItem('Huruf dan Angka', _hasLetterAndNumber),
                const SizedBox(height: 6),
                _buildCheckItem('Minimal 1 Huruf Besar', _hasUppercase),
              ],
            ),
          ),

          const Spacer(),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegisterSelesai,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySage,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan & Selesaikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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

          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primarySage.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 100,
              color: AppColors.primarySage,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Akun Berhasil Dibuat',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Selamat bergabung di Bank Sampah SAJUANG! Silakan masuk untuk memverifikasi email dan mulai menabung sampah.',
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Mulai Masuk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
        color: AppColors.primarySage.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textDark),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(
    int activeStep,
    String stepTitle,
    String subtitle,
  ) {
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
        ],
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
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLineStep(bool isActive) {
    return Container(
      width: 55,
      height: 2,
      color: isActive ? AppColors.primarySage : Colors.grey.shade300,
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.primarySage.withValues(alpha: 0.15),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

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