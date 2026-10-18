import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late Future<List<dynamic>> _pencapaianFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _pencapaianFuture = ApiService.getPencapaian();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySage,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Pencapaian & Ranking',
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

            const SizedBox(height: 10),

            // 2. DAFTAR BADGE PENCAPAIAN
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: FutureBuilder<List<dynamic>>(
                  future: _pencapaianFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.textDark),
                      );
                    }

                    final listPencapaian = snapshot.data ?? [];

                    if (listPencapaian.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada data pencapaian',
                          style: TextStyle(color: Colors.black45),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: listPencapaian.length,
                      itemBuilder: (context, index) {
                        final item = listPencapaian[index];
                        final namaPencapaian = item['nama_pencapaian'] ?? 'Pencapaian';
                        final deskripsi = item['deskripsi'] ?? '-';
                        final target = item['target'] ?? 0;
                        final satuan = item['satuan_target'] ?? '';
                        final status = item['status'] ?? 'terkunci';

                        final isUnlocked = status.toString().toLowerCase() == 'tercapai';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? AppColors.accentYellow
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                                  color: isUnlocked ? AppColors.textDark : Colors.grey,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      namaPencapaian,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      deskripsi,
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Target: $target $satuan',
                                      style: const TextStyle(fontSize: 11, color: Colors.black38),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? const Color(0xFFC8E6C9)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isUnlocked ? 'TERCAPAI' : 'LOCKED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? const Color(0xFF2E7D32) : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Tab Ranking Aktif
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
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
}