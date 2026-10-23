import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/nasabah_model.dart';
import '../auth/login_screen.dart';
import '../penarikan/penarikan_screen.dart';
import '../setoran/setoran_screen.dart';
import '../ranking/ranking_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: FutureBuilder<NasabahModel?>(
        future: ApiService.getNasabahProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primarySage),
            );
          }

          final nasabah = snapshot.data;
          final namaNasabah = nasabah?.nama ?? 'Nasabah';
          final noTelp = nasabah?.noTelp ?? '-';

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER SAGE GREEN + FOTO AVATAR
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySage,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 26),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Expanded(
                                child: Text(
                                  'Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -45,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.primarySage.withOpacity(0.3),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 55),

                // 2. NAMA & NOMOR TELEPON REAL
                Text(
                  namaNasabah,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  noTelp,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. DAFTAR MENU PROFILE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Data diri',
                        onTap: () {},
                      ),
                      const SizedBox(height: 14),
                      _buildProfileMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ubah Password',
                        onTap: () {},
                      ),
                      const SizedBox(height: 14),
                      _buildProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Tentang Aplikasi',
                        onTap: () {},
                      ),
                      const SizedBox(height: 14),
                      _buildProfileMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Keluar',
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),

      // 4. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PenarikanScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SetoranScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RankingScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF0F6F1),
        selectedItemColor: AppColors.textDark,
        unselectedItemColor: Colors.black45,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description_rounded),
            label: 'Penarikan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pan_tool_outlined),
            activeIcon: Icon(Icons.pan_tool_rounded),
            label: 'Setoran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.military_tech_outlined),
            activeIcon: Icon(Icons.military_tech_rounded),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(icon, color: Colors.black54, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black87,
          size: 26,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun SAJUANG?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // 1. Tutup dialog konfirmasi terlebih dahulu
              Navigator.pop(dialogContext);

              // 2. Hapus token dari SecureStorage
              await ApiService.logout();

              // 3. Pindah langsung ke Halaman Login & Hapus semua riwayat halaman sebelumnya
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}