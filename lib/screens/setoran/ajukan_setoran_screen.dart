import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  // State untuk Foto Bukti Sampah
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedFoto;
  Uint8List? _selectedFotoBytes;

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

  void _showFotoPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload Foto Bukti Sampah',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primarySage),
                  title: const Text('Ambil Foto dari Kamera'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickFotoSampah(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: AppColors.primarySage),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickFotoSampah(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFotoSampah(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedFoto = picked;
        _selectedFotoBytes = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    final beratText = _estimasiBeratController.text.trim().replaceAll(',', '.');
    final estimasiBerat = double.tryParse(beratText) ?? 0;

    if (estimasiBerat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perkiraan berat sampah harus lebih dari 0 Kg!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.ajukanSetoran(
      jenisSampah: _selectedJenisSampah!,
      estimasiBerat: estimasiBerat,
      catatan: _catatanController.text.trim(),
      fotoBukti: _selectedFoto,
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
        Navigator.pop(context, true);
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
                  color: AppColors.primarySage.withValues(alpha: 0.15),
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
                initialValue: _selectedJenisSampah,
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

              // Input Perkiraan Berat (Hanya angka dan titik/koma desimal)
              const Text(
                'Perkiraan Berat (Kg)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _estimasiBeratController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
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

              // Upload Foto Bukti Sampah (Kamera / Galeri)
              const Text(
                'Foto Bukti Sampah (opsional)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showFotoPickerOptions,
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primarySage.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: _selectedFotoBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.memory(
                                _selectedFotoBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFoto = null;
                                    _selectedFotoBytes = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, size: 38, color: AppColors.primarySage),
                            SizedBox(height: 8),
                            Text(
                              'Ketuk untuk ambil foto atau pilih dari galeri',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Format JPG/PNG (Maks. 2MB)',
                              style: TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
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