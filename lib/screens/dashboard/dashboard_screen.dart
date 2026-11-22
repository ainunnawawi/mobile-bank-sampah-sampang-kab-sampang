import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_settings.dart';
import '../../utils/currency_formatter.dart';
import '../../services/api_service.dart';
import '../../models/nasabah_model.dart';
import '../../models/setoran_model.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../penarikan/penarikan_screen.dart';
import '../setoran/setoran_screen.dart';
import '../setoran/ajukan_setoran_screen.dart';
import '../ranking/ranking_screen.dart';
import '../saldo/saldo_mutasi_screen.dart';
import '../notification/notification_screen.dart';
import '../statistik/statistik_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late Future<NasabahModel?> _profileFuture;
  bool _isSendingVerif = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _profileFuture = ApiService.getNasabahProfile();
    });
  }


  Future<void> _kirimLinkVerifikasi() async {
    setState(() => _isSendingVerif = true);
    final result = await ApiService.kirimLinkVerifikasiDashboard();
    setState(() => _isSendingVerif = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Link verifikasi telah dikirim.'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NasabahModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final nasabah = snapshot.data;
        const bool bypassVerifSementara = true; // Ubah ke false setelah tim web deploy!
        final bool isUnverified = !bypassVerifSementara && !isLoading && nasabah != null && !nasabah.isVerified;
        // final bool isUnverified = !isLoading && nasabah != null && !nasabah.isVerified;

        return Stack(
          children: [
            // LAYER 1: HALAMAN DASHBOARD UTAMA
            AbsorbPointer(
              absorbing: isUnverified,
              child: Scaffold(
                backgroundColor: AppColors.backgroundPage,
                body: SafeArea(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primarySage),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _refreshData(),
                          child: _buildDashboardContent(nasabah),
                        ),
                ),
                bottomNavigationBar: _buildBottomNav(),
              ),
            ),

            // LAYER 2: BLUR OVERLAY & POP-UP VERIFIKASI JIKA EMAIL BELUM TERVERIFIKASI
            if (isUnverified)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(24.0),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primarySage.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                size: 48,
                                color: AppColors.primarySage,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Verifikasi Email Diperlukan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Halo ${nasabah.nama}, akun email Anda${nasabah.email != null ? ' (${nasabah.email})' : ''} belum terverifikasi. Silakan verifikasi email terlebih dahulu untuk mengakses seluruh fitur SAJUANG.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSendingVerif ? null : _kirimLinkVerifikasi,
                                icon: _isSendingVerif
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                label: Text(
                                  _isSendingVerif ? 'Mengirim...' : 'Kirim Link Verifikasi',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primarySage,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _refreshData,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primarySage),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Saya Sudah Verifikasi (Muat Ulang)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primarySage,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _handleLogout,
                              child: const Text(
                                'Keluar / Ganti Akun',
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardContent(NasabahModel? nasabah) {
    final namaNasabah = nasabah?.nama ?? 'Nasabah';
    final double rawSaldo = double.tryParse(nasabah?.saldo ?? '0') ?? 0;
    final saldoFormatted = 'Rp ${CurrencyUtils.formatRibuan(rawSaldo)}';
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hai, $namaNasabah',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Selamat datang di',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const Text(
            'Bank Sampah Sajuang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // CARD SALDO SAKU (Dengan Tombol Suara Aksesibilitas)
          GestureDetector(
            onTap: () {
              AppSettings.speak('Saldo saku Anda saat ini sebesar $saldoFormatted');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaldoMutasiScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Saldo Saku',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              AppSettings.speakForce(
                                'Saldo saku Anda saat ini sebesar $saldoFormatted',
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.volume_up_rounded,
                                size: 18,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        saldoFormatted,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      size: 32,
                      color: AppColors.primarySage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // MENU UTAMA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuIconButton(
                icon: Icons.recycling_rounded,
                label: 'Setor Sampah',
                bgColor: const Color(0xFFBBE5C8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AjukanSetoranScreen()),
                  );
                },
              ),
              _buildMenuIconButton(
                icon: Icons.payments_rounded,
                label: 'Tarik Saldo',
                bgColor: AppColors.accentYellow.withValues(alpha: 0.8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PenarikanScreen()),
                  );
                },
              ),
              _buildMenuIconButton(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat',
                bgColor: AppColors.primarySage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SaldoMutasiScreen()),
                  );
                },
              ),
              _buildMenuIconButton(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi',
                bgColor: const Color(0xFFF28B82),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 4. CARD STATISTIK (Real-time & Bisa Diklik ke Halaman Statistik)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatistikScreen()),
              );
            },
            child: FutureBuilder<List<SetoranModel>>(
              future: ApiService.getRiwayatSetoran(),
              builder: (context, setoranSnap) {
                final listSetoran = setoranSnap.data ?? [];
                final int jmlSetoran = listSetoran.length;
                final double jmlBerat = listSetoran.fold(
                  0.0,
                  (sum, e) => sum + (double.tryParse(e.berat) ?? 0.0),
                );
                final double jmlNilai = listSetoran.fold(
                  0.0,
                  (sum, e) => sum + (double.tryParse(e.nilaiSetoran) ?? 0.0),
                );

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF7EF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Statistik Kamu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppColors.textDark),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Total Setoran',
                            value: '$jmlSetoran kali',
                          ),
                          _buildStatItem(
                            icon: Icons.scale_outlined,
                            label: 'Total Sampah',
                            value: '${jmlBerat.toStringAsFixed(1).replaceAll('.', ',')}Kg',
                          ),
                          _buildStatItem(
                            icon: Icons.insights_rounded,
                            label: 'Total Nilai',
                            value: 'Rp ${CurrencyUtils.formatRibuan(jmlNilai)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // BANNER MOTIVASI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: AppColors.textDark),
                          children: [
                            TextSpan(text: 'Yuk jaga lingkungan\n'),
                            TextSpan(
                              text: 'Bersama ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            TextSpan(
                              text: 'SAJUANG',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'sampah kecil, dampak\nbesar!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F0D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    size: 48,
                    color: AppColors.primarySage,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) async {
        if (index == _currentIndex) return;

        setState(() => _currentIndex = index);

        if (index == 1) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const PenarikanScreen()));
        } else if (index == 2) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const SetoranScreen()));
        } else if (index == 3) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const RankingScreen()));
        } else if (index == 4) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        }

        if (mounted) {
          setState(() => _currentIndex = 0);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF0F6F1),
      selectedItemColor: AppColors.textDark,
      unselectedItemColor: Colors.black45,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description_rounded), label: 'Penarikan'),
        BottomNavigationBarItem(icon: Icon(Icons.pan_tool_outlined), activeIcon: Icon(Icons.pan_tool_rounded), label: 'Setoran'),
        BottomNavigationBarItem(icon: Icon(Icons.military_tech_outlined), activeIcon: Icon(Icons.military_tech_rounded), label: 'Ranking'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }

  Widget _buildMenuIconButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.textDark, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primarySage, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ],
    );
  }
}