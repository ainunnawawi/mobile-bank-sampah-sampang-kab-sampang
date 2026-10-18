import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/setoran_model.dart';

class DetailSetoranScreen extends StatelessWidget {
  final SetoranModel setoran;

  const DetailSetoranScreen({super.key, required this.setoran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Setoran',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Icon Ilustrasi Tempat Sampah
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFD3EAC8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  size: 50,
                  color: Color(0xFF388E3C),
                ),
              ),
              const SizedBox(height: 16),

              // Nomor Transaksi & Tanggal
              Text(
                setoran.nomorTransaksi,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                setoran.tglSetoran,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              // Badge Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  setoran.status.isEmpty ? 'Selesai' : setoran.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rincian Detail Baris
              _buildDetailRow('Jenis Sampah', 'Botol Plastik'), // Bisa disesuaikan jika API mengirim nama jenis
              _buildDetailRow('Berat', '${setoran.berat} kg'),
              _buildDetailRow('Harga kg', 'Rp ${setoran.hargaPerKg}'),
              _buildDetailRow('Total Nilai', 'Rp ${setoran.nilaiSetoran}'),
              _buildDetailRow('Petugas', 'Budi Santoso'),
              
              const SizedBox(height: 8),

              // Catatan Opsional
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catatan',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    setoran.keterangan == null || setoran.keterangan!.isEmpty ? '-' : setoran.keterangan!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}