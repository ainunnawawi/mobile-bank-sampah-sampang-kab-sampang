import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String namaAwal;
  final String noTelpAwal;
  final String alamatAwal;

  const EditProfileScreen({
    super.key,
    required this.namaAwal,
    required this.noTelpAwal,
    this.alamatAwal = '',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _namaController;
  late TextEditingController _noTelpController;
  late TextEditingController _alamatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaAwal);
    _noTelpController = TextEditingController(text: widget.noTelpAwal);
    _alamatController = TextEditingController(text: widget.alamatAwal);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final nama = _namaController.text.trim();
    final noHp = _noTelpController.text.trim();
    final alamat = _alamatController.text.trim();

    if (nama.isEmpty || noHp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Nomor Telepon wajib diisi!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.updateProfile(
      nama: nama,
      noHp: noHp,
      alamat: alamat,
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
        Navigator.pop(context, true); // Kirim sinyal true agar layar Profile refresh data
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
        title: const Text('Edit Data Diri', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
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
            _buildInputField('Nama Lengkap', _namaController, 'Masukkan Nama Lengkap'),
            const SizedBox(height: 16),
            _buildInputField('Nomor Telepon', _noTelpController, 'Masukkan Nomor HP', isNumber: true),
            const SizedBox(height: 16),
            _buildInputField('Alamat Tempat Tinggal', _alamatController, 'Masukkan Alamat Lengkap', maxLines: 3),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
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
                  : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}