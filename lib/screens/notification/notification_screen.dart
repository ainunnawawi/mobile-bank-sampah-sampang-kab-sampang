import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'Semua';

  // Data Notifikasi (Bisa diganti data API nantinya)
  final List<Map<String, String>> _notifications = [
    {
      'judul': 'Setoran Berhasil',
      'kode': 'set-20260901-0001',
      'waktu': '1 sep 2026 ➔ 11:20',
      'kategori': 'Setoran',
      'tipe_icon': 'setoran_sukses',
    },
    {
      'judul': 'Penarikan diajukan',
      'kode': 'WID-20260901-0001',
      'waktu': '1 sep 2026 ➔ 11:19',
      'kategori': 'Penarikan',
      'tipe_icon': 'penarikan_diajukan',
    },
    {
      'judul': 'penarikan disetujui',
      'kode': 'WID-20260901-0001',
      'waktu': '1 sep 2026 ➔ 11:19',
      'kategori': 'Penarikan',
      'tipe_icon': 'penarikan_disetujui',
    },
    {
      'judul': 'Event Harga Spesial',
      'kode': 'Hari kemerdekaan',
      'waktu': '17 agus 2026',
      'kategori': 'Event',
      'tipe_icon': 'event',
    },
    {
      'judul': 'Penarikan ditolak',
      'kode': 'WID-20260901-0001',
      'waktu': '1 sep 2026 ➔ 11:19',
      'kategori': 'Penarikan',
      'tipe_icon': 'penarikan_ditolak',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter list berdasarkan chip yang dipilih
    final filteredList = _notifications.where((item) {
      if (_selectedFilter == 'Semua') return true;
      return item['kategori'].toString().toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFC7E5C8), // Sage background header
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. HEADER (Tombol Back, Judul & Filter Chips)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Notifikasi',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balancing icon back
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips (Semua, Setoran, Penarikan, Event)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Setoran'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Penarikan'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Event'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. BODY / CONTAINER PUTIH DENGAN CORNER ROUNDED
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildNotificationCard(item);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Filter Chip (Tombol Hijau Tua)
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Card Item Notifikasi
  Widget _buildNotificationCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Custom Icon Berdasarkan Tipe Notifikasi
          _buildNotificationIcon(item['tipe_icon']),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['judul'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['kode'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['waktu'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Icon Sesuai Gambar Mockup
  Widget _buildNotificationIcon(String tipe) {
    switch (tipe) {
      case 'setoran_sukses':
        return Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF8BC34A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 24),
        );

      case 'penarikan_diajukan':
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.handshake_outlined, color: Colors.brown, size: 22),
        );

      case 'penarikan_disetujui':
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_outlined, color: Colors.lightBlue, size: 22),
        );

      case 'event':
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.card_giftcard_rounded, color: Colors.red, size: 22),
        );

      case 'penarikan_ditolak':
      default:
        return Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 24),
        );
    }
  }
}