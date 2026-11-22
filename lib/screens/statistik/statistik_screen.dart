import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../services/api_service.dart';
import '../../models/setoran_model.dart';
import '../penarikan/penarikan_screen.dart';
import '../setoran/setoran_screen.dart';
import '../ranking/ranking_screen.dart';
import '../profile/profile_screen.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  String _selectedPeriode = 'Bulanan'; // 'Mingguan', 'Bulanan', 'Tahunan'
  late Future<List<SetoranModel>> _setoranFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _setoranFuture = ApiService.getRiwayatSetoran();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistik',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<SetoranModel>>(
          future: _setoranFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final allSetoran = snapshot.data ?? [];
            final now = DateTime.now();

            // Filter transaksi yang selesai/valid sesuai periode
            final filtered = allSetoran.where((item) {
              final dt = DateTime.tryParse(item.tglSetoran) ?? now;
              if (_selectedPeriode == 'Mingguan') {
                return now.difference(dt).inDays <= 7 && now.difference(dt).inDays >= 0;
              } else if (_selectedPeriode == 'Bulanan') {
                return dt.month == now.month && dt.year == now.year;
              } else {
                return dt.year == now.year;
              }
            }).toList();

            final int totalSetoran = filtered.length;
            final double totalBerat = filtered.fold(
              0.0,
              (sum, e) => sum + (double.tryParse(e.berat) ?? 0),
            );
            final double totalNilai = filtered.fold(
              0.0,
              (sum, e) => sum + (double.tryParse(e.nilaiSetoran) ?? 0),
            );

            // Hitung 4 bar chart (Minggu 1 - Minggu 4)
            List<double> barValues = [0, 0, 0, 0];
            for (var item in filtered) {
              final dt = DateTime.tryParse(item.tglSetoran) ?? now;
              int weekIndex = ((dt.day - 1) ~/ 7).clamp(0, 3);
              barValues[weekIndex] += double.tryParse(item.berat) ?? 0;
            }
            final double maxBar = barValues.reduce((a, b) => a > b ? a : b);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // 1. FILTER PERIODE (Mingguan / Bulanan / Tahunan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Mingguan', 'Bulanan', 'Tahunan'].map((periode) {
                      final isSelected = _selectedPeriode == periode;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPeriode = periode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            periode,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: AppColors.textDark,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    _getPeriodeLabel(now),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. KARTU RINGKASAN
                  _buildSummaryCard(
                    icon: Icons.trending_up_rounded,
                    title: 'Total Setoran',
                    value: '$totalSetoran Kali',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.recycling_rounded,
                    title: 'Total Sampah',
                    value: '${totalBerat.toStringAsFixed(1).replaceAll('.', ',')} kg',
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Total Nilai',
                    value: 'Rp ${CurrencyUtils.formatRibuan(totalNilai)}',
                    valueColor: Colors.green.shade700,
                  ),

                  const SizedBox(height: 20),

                  // 3. GRAFIK BATANG MINGGU 1 - 4
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grafik Berat Sampah (Kg)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 175,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(4, (index) {
                              final val = barValues[index];
                              final double heightFactor = maxBar > 0 ? (val / maxBar) : 0.05;
                              final double barHeight = (130 * heightFactor).clamp(12.0, 130.0);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    val > 0 ? val.toStringAsFixed(1) : '0',
                                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 24,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B8A2A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Minggu ${index + 1}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Data diperbarui secara real-time dari transaksi yang telah selesai',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description_rounded), label: 'Penarikan'),
          BottomNavigationBarItem(icon: Icon(Icons.pan_tool_outlined), activeIcon: Icon(Icons.pan_tool_rounded), label: 'Setoran'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech_outlined), activeIcon: Icon(Icons.military_tech_rounded), label: 'Ranking'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  String _getPeriodeLabel(DateTime now) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (_selectedPeriode == 'Mingguan') return '7 Hari Terakhir';
    if (_selectedPeriode == 'Bulanan') return '${bulan[now.month - 1]} ${now.year}';
    return 'Tahun ${now.year}';
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = AppColors.textDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.green.shade700),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}