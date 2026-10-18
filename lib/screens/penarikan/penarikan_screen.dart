import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class PenarikanScreen extends StatefulWidget {
  const PenarikanScreen({super.key});

  @override
  State<PenarikanScreen> createState() => _PenarikanScreenState();
}

class _PenarikanScreenState extends State<PenarikanScreen> {
  int _selectedTab = 0; // 0: Ajukan Penarikan, 1: Riwayat Penarikan
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  bool _isLoading = false;

  void _kirimPengajuan() async {
    final nominalStr = _nominalController.text.trim();
    if (nominalStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal penarikan!')),
      );
      return;
    }

    final nominal = double.tryParse(nominalStr) ?? 0;
    if (nominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal penarikan adalah Rp 10.000!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.ajukanPenarikan(
      nominal: nominal,
      metodePenarikan: 'tunai', // Default tunai sesuai backend
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
        _nominalController.clear();
        _catatanController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER & TAB NAVIGATION
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 50),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySage, // Menggunakan Primary Sage Palette
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              title: 'Ajukan Penarikan',
                              isSelected: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTabButton(
                              title: 'Riwayat Penarikan',
                              isSelected: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card Saldo Melayang (Butter Yellow Palette)
                Positioned(
                  bottom: -30,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Saldo Tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp 125.000',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // 2. KONTEN (AJUKAN ATAU RIWAYAT)
            _selectedTab == 0 ? _buildFormPenarikan() : _buildRiwayatPenarikan(),
          ],
        ),
      ),
    );
  }

  // Tab Button Helper
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E9B71) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  // Form Penarikan
  Widget _buildFormPenarikan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nominal Penarikan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nominalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'masukkan nominal',
              suffixText: 'Rp',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Minimal Penarikan Rp 10.000',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),

          const SizedBox(height: 24),

          const Text(
            'Catatan (opsional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'contoh: Untuk kebutuhan harian',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Tombol Ajukan Penarikan (Aksen Tombol Sage Dark)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _kirimPengajuan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF427A53),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Ajukan Penarikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Info Box Paling Bawah
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Expanded(
                      child: Text(
                        'Penarikan akan diverifikasi oleh petugas',
                        style: TextStyle(fontSize: 12, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Expanded(
                      child: Text(
                        'Proses Maksimal 1x24 jam',
                        style: TextStyle(fontSize: 12, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Tampilan Tab Riwayat Penarikan
  Widget _buildRiwayatPenarikan() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Text(
          'Belum ada riwayat penarikan',
          style: TextStyle(color: Colors.black45),
        ),
      ),
    );
  }
}