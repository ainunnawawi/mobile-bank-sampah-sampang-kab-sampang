import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/setoran_model.dart';
import 'detail_setoran_screen.dart';

class SetoranScreen extends StatefulWidget {
  const SetoranScreen({super.key});

  @override
  State<SetoranScreen> createState() => _SetoranScreenState();
}

class _SetoranScreenState extends State<SetoranScreen> {
  int _selectedFilter = 0; // 0: Semua, 1: Sampah, 2: Masuk
  late Future<List<SetoranModel>> _setoranFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _setoranFuture = ApiService.getRiwayatSetoran();
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
                      'Riwayat Setoran',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing back button
                ],
              ),
            ),

            // 2. FILTER CHIPS (Semua, Sampah, Masuk)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 0),
                    _buildFilterChip('Sampah', 1),
                    _buildFilterChip('Masuk', 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. DAFTAR RIWAYAT SETORAN
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: FutureBuilder<List<SetoranModel>>(
                  future: _setoranFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.textDark),
                      );
                    }

                    final listSetoran = snapshot.data ?? [];

                    if (listSetoran.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada riwayat setoran',
                          style: TextStyle(color: Colors.black45),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: listSetoran.length,
                      itemBuilder: (context, index) {
                        final item = listSetoran[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailSetoranScreen(setoran: item),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.tglSetoran,
                                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.nomorTransaksi,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '+ Rp ${item.nilaiSetoran}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Botol Plastik - ${item.berat}kg',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                    Text(
                                      item.status.isEmpty ? 'Selesai' : item.status,
                                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

      // 4. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Tab Setoran Aktif
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

  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}