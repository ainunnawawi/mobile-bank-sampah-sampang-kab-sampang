import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import '../setoran/setoran_screen.dart';
import '../ranking/ranking_screen.dart';
import '../profile/profile_screen.dart';

class PenarikanScreen extends StatefulWidget {
  const PenarikanScreen({super.key});

  @override
  State<PenarikanScreen> createState() => _PenarikanScreenState();
}

class _PenarikanScreenState extends State<PenarikanScreen> {
  int _selectedTab = 0; // 0: Ajukan Penarikan, 1: Riwayat Penarikan
  String _selectedFilter = 'Semua';

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _nomorTujuanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _catatanController = TextEditingController();

  String _selectedMetode = 'Tunai'; // Default Tunai
  bool _isLoading = false;

  // Variable Simpan Saldo Real
  String _saldoTersedia = 'Rp 0';
  bool _isLoadingSaldo = true;

  // Option Metode Pembayaran / Transfer
  final List<String> _metodeOptions = const [
    'Tunai',
    'DANA',
    'Gopay',
    'OVO',
    'ShopeePay',
    'Bank BCA',
    'Bank BRI',
    'Bank BNI',
    'Bank Mandiri',
  ];

  @override
  void initState() {
    super.initState();
    _loadSaldoUser();
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _nomorTujuanController.dispose();
    _namaPemilikController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Ambil saldo real menggunakan getNasabahProfile()
  Future<void> _loadSaldoUser() async {
    try {
      final nasabah = await ApiService.getNasabahProfile();
      if (mounted && nasabah != null) {
        setState(() {
          final rawSaldo = nasabah.saldo;
          _saldoTersedia = rawSaldo is num ? 'Rp $rawSaldo' : rawSaldo.toString();
          _isLoadingSaldo = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingSaldo = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSaldo = false);
      }
    }
  }

  // Handling Pengajuan Unified (Tunai + Transfer E-Wallet / Bank)
  void _kirimPengajuan() async {
    if (!_formKey.currentState!.validate()) return;

    final nominal = double.tryParse(_nominalController.text.trim()) ?? 0;
    if (nominal < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal penarikan adalah Rp 10.000!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Kirim data penarikan ke ApiService
    final isTunai = _selectedMetode == 'Tunai';
    final result = await ApiService.ajukanPenarikan(
      nominal: nominal,
      metodePenarikan: isTunai ? 'tunai' : 'transfer',
      namaBankEwallet: isTunai ? null : _selectedMetode,
      nomorTujuan: isTunai
          ? null
          : '${_nomorTujuanController.text.trim()} a.n ${_namaPemilikController.text.trim()}',
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
        _nomorTujuanController.clear();
        _namaPemilikController.clear();
        _catatanController.clear();
        setState(() => _selectedMetode = 'Tunai');
        
        // 1. Refresh saldo dari backend yang dipotong
        _loadSaldoUser();
        
        // 2. Pindah otomatis ke tab Riwayat
        setState(() {
          _selectedTab = 1;
        });
      }
    }
  }

  // Tampilan Invoice / Struk Digital Modal BottomSheet
  void _showInvoiceDialog(BuildContext context, Map<String, dynamic> item) {
    final String status = item['status']?.toString() ?? 'Pending';
    final String tanggal = item['created_at'] ?? item['tgl'] ?? item['tanggal'] ?? '-';
    final String kode = item['kode_penarikan'] ?? item['kode'] ?? 'WID-${item['id'] ?? '-'}';
    final rawNominal = item['nominal'] ?? item['jumlah'] ?? 0;
    final String nominalStr = rawNominal is num ? 'Rp $rawNominal' : rawNominal.toString();
    final String metode = item['metode'] ?? item['nama_bank_ewallet'] ?? 'Tunai';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'disetujui':
        statusColor = Colors.green;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'STRUK / INVOICE PENARIKAN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                kode,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const Divider(height: 30),

              _buildInvoiceRow('Tipe Transaksi', 'Penarikan Saldo (Keluar)'),
              _buildInvoiceRow('Metode Penarikan', metode.toUpperCase()),
              _buildInvoiceRow('Waktu Transaksi', tanggal.toString()),
              _buildInvoiceRow('Status Verification', status.toUpperCase(), valueColor: statusColor),
              
              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Penarikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    '- $nominalStr',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySage,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Tutup Invoice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoiceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valueColor ?? AppColors.textDark)),
        ],
      ),
    );
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
                    color: AppColors.primarySage,
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

                // Card Saldo Melayang
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
                      children: [
                        const Text(
                          'Saldo Tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _isLoadingSaldo
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textDark,
                                ),
                              )
                            : Text(
                                _saldoTersedia,
                                style: const TextStyle(
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
            _selectedTab == 0 ? _buildFormPenarikanUnified() : _buildRiwayatPenarikan(),
          ],
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR (Navigasi Aktif)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Tab Penarikan Aktif
        onTap: (index) {
          if (index == 1) return; // Jika tab yang sama, abaikan

          if (index == 0) {
            Navigator.pop(context); // Kembali ke Beranda
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

  // Unified Form Penarikan (Tunai & E-Wallet / Bank Dalam 1 Form)
  Widget _buildFormPenarikanUnified() {
    final bool isEwalletOrBank = _selectedMetode != 'Tunai';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Pilih Metode Penarikan
            const Text(
              'Metode Penarikan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMetode,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark),
                  items: _metodeOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMetode = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Form Tambahan jika memilih E-Wallet / Bank
            if (isEwalletOrBank) ...[
              const Text(
                'Nomor Rekening / No HP E-Wallet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomorTujuanController,
                keyboardType: TextInputType.number,
                validator: (val) => isEwalletOrBank && (val == null || val.isEmpty) ? 'Nomor tujuan wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Contoh: 081234567890 / 1234567890',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Nama Pemilik Rekening / Akun',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaPemilikController,
                textCapitalization: TextCapitalization.words,
                validator: (val) => isEwalletOrBank && (val == null || val.isEmpty) ? 'Nama pemilik wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama sesuai akun E-Wallet / Bank',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nominal Penarikan
            const Text(
              'Nominal Penarikan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Nominal wajib diisi' : null,
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

            const SizedBox(height: 16),

            // Catatan
            const Text(
              'Catatan (opsional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
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

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
      ),
    );
  }

  // Tampilan Tab Riwayat Penarikan
  Widget _buildRiwayatPenarikan() {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFB8E0BA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Disetujui'),
                _buildFilterChip('Ditolak'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        FutureBuilder<List<dynamic>>(
          future: ApiService.getPenarikan(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primarySage),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text('Gagal mengambil data dari server', style: TextStyle(color: Colors.red)),
                ),
              );
            }

            final realData = snapshot.data ?? [];

            final filteredList = realData.where((item) {
              final status = item['status']?.toString() ?? '';
              if (_selectedFilter == 'Semua') return true;
              return status.toLowerCase() == _selectedFilter.toLowerCase();
            }).toList();

            if (filteredList.isEmpty) {
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];

                final tanggal = item['created_at'] ?? item['tgl'] ?? item['tanggal'] ?? '-';
                final kode = item['kode_penarikan'] ?? item['kode'] ?? 'WID-${item['id'] ?? '-'}';
                final rawNominal = item['nominal'] ?? item['jumlah'] ?? 0;
                final status = item['status'] ?? 'Pending';

                final jumlahStr = rawNominal is num ? 'Rp $rawNominal' : rawNominal.toString();

                return GestureDetector(
                  onTap: () => _showInvoiceDialog(context, item), // <--- KLIK ITEM BUAT LIHAT INVOICE STRUK
                  child: _buildPenarikanCard(
                    tanggal: tanggal.toString(),
                    kode: kode.toString(),
                    jumlah: jumlahStr,
                    status: status.toString(),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.textDark : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildPenarikanCard({
    required String tanggal,
    required String kode,
    required String jumlah,
    required String status,
  }) {
    Color statusBgColor;

    switch (status.toLowerCase()) {
      case 'disetujui':
        statusBgColor = const Color(0xFFAEE5C0);
        break;
      case 'ditolak':
        statusBgColor = const Color(0xFFF1B7A4);
        break;
      case 'pending':
      default:
        statusBgColor = const Color(0xFFEAD479);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tanggal, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 4),
              Text(kode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(jumlah, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}