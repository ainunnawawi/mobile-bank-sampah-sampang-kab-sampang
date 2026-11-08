import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class AjukanSetoranScreen extends StatefulWidget {
  const AjukanSetoranScreen({super.key});

  @override
  State<AjukanSetoranScreen> createState() => _AjukanSetoranScreenState();
}

class _AjukanSetoranScreenState extends State<AjukanSetoranScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedJenisSampah;
  final _estimasiBeratController = TextEditingController();
  final _catatanController = TextEditingController();
  bool _isLoading = false;

  final List<String> _kategoriSampah = const [
    'Plastik (Botol/Gelas)',
    'Kertas / Kardus',
    'Besi / Logam',
    'Kaca / Botol Kaca',
    'Elektronik / Lainnya',
  ];

  @override
  void dispose() {
    _estimasiBeratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _kirimPengajuanSetoran() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJenisSampah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori jenis sampah terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil API backend untuk kirim estimasi setoran
    final result = await ApiService.ajukanSetoran(
      jenisSampah: _selectedJenisSampah!,
      estimasiBerat: double.tryParse(_estimasiBeratController.text.trim()) ?? 0,
      catatan: _catatanController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Pengajuan setoran berhasil dikirim!'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context, true); // Kembali ke beranda setelah berhasil
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
          'Ajukan Setoran Sampah',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Informasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primarySage, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Inputkan perkiraan sampah yang ingin kamu setor. Petugas akan menimbang ulang saat transaksi di lokasi.',
                        style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dropdown Jenis Sampah
              const Text(
                'Jenis / Kategori Sampah',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJenisSampah,
                hint: const Text('Pilih Kategori Sampah', style: TextStyle(fontSize: 14, color: Colors.black45)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _kategoriSampah
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: (val) => setState(() => _selectedJenisSampah = val),
              ),

              const SizedBox(height: 20),

              // Input Perkiraan Berat
              const Text(
                'Perkiraan Berat (Kg)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _estimasiBeratController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty ? 'Masukkan perkiraan berat sampah' : null,
                decoration: InputDecoration(
                  hintText: 'Contoh: 2.5',
                  suffixText: 'Kg',
                  suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              // Catatan Tambahan
              const Text(
                'Catatan Tambahan (opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kardus bekas & botol plastik sudah dibersihkan',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Kirim Pengajuan
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimPengajuanSetoran,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Pengajuan Setoran',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}