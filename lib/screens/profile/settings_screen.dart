import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primarySage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () {
            AppSettings.stop();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Pengaturan & Aksesibilitas',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. TAMPILAN (DARK MODE)
          const Text(
            'Tampilan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppSettings.themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.primarySage,
                  ),
                  title: const Text('Mode Gelap (Night Mode)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Mengurangi silau layar saat digunakan di malam hari', style: TextStyle(fontSize: 12)),
                  value: isDark,
                  activeTrackColor: AppColors.primarySage,
                  onChanged: (val) {
                    AppSettings.themeMode.value = val ? ThemeMode.dark : ThemeMode.light;
                    AppSettings.speak(val ? 'Mode gelap diaktifkan' : 'Mode terang diaktifkan');
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 2. AKSESIBILITAS UKURAN TEKS
          const Text(
            'Ukuran Teks',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<double>(
            valueListenable: AppSettings.textScale,
            builder: (context, scale, _) {
              String labelUkuran = 'Normal';
              if (scale <= 0.85) {
                labelUkuran = 'Kecil';
              } else if (scale >= 1.25) {
                labelUkuran = 'Ekstra Besar';
              } else if (scale > 1.0) {
                labelUkuran = 'Besar';
              }

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Skala Huruf Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySage.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$labelUkuran (${(scale * 100).toInt()}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: scale,
                        min: 0.85,
                        max: 1.30,
                        divisions: 3,
                        activeColor: AppColors.primarySage,
                        label: labelUkuran,
                        onChanged: (val) {
                          AppSettings.textScale.value = val;
                        },
                      ),
                      const Text(
                        'Contoh tampilan teks dengan ukuran yang dipilih saat ini.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // 3. AKSESIBILITAS SUARA (READ OUT LOUD)
          const Text(
            'Aksesibilitas Suara (Read Out Loud)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.isTtsEnabled,
            builder: (context, enabled, _) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.record_voice_over_rounded, color: AppColors.primarySage),
                      title: const Text('Pembaca Layar (Text-to-Speech)', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Membacakan informasi saldo dan status transaksi dengan suara', style: TextStyle(fontSize: 12)),
                      value: enabled,
                      activeTrackColor: AppColors.primarySage,
                      onChanged: (val) {
                        AppSettings.isTtsEnabled.value = val;
                        if (val) {
                          AppSettings.speakForce('Fitur pembaca layar SAJUANG aktif.');
                        } else {
                          AppSettings.stop();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppSettings.speakForce(
                              'Selamat datang di Bank Sampah SAJUANG. Sampah kecil, dampak besar.',
                            );
                          },
                          icon: const Icon(Icons.volume_up_rounded, color: AppColors.primarySage),
                          label: const Text(
                            'Tes Suara Sekarang',
                            style: TextStyle(color: AppColors.primarySage, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primarySage),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}