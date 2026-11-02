import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class EwalletScreen extends StatefulWidget {
  const EwalletScreen({super.key});

  @override
  State<EwalletScreen> createState() => _EwalletScreenState();
}

class _EwalletScreenState extends State<EwalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _nomorTujuanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _selectedProvider;
  bool _isLoading = false;
  String _saldoUser = 'Rp 0';
  bool _isLoadingSaldo = true;

  // Daftar Pilihan E-Wallet & Bank
  final List<String> _providerOptions = const [
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

  Future<void> _loadSaldoUser() async {
    try {
      final nasabah = await ApiService.getNasabahProfile();
      if (mounted && nasabah != null) {
        setState(() {
          final rawSaldo = nasabah.saldo;
          _saldoUser = rawSaldo is num ? 'Rp $rawSaldo' : rawSaldo.toString();
          _isLoadingSaldo = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingSaldo = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSaldo = false);
    }
  }

  void _kirimPengajuanEwallet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih aplikasi pembayaran / bank tujuan!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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

    final result = await ApiService.ajukanPenarikan(
      nominal: nominal,
      metodePenarikan: 'transfer',
      namaBankEwallet: _selectedProvider,
      nomorTujuan: '${_nomorTujuanController.text.trim()} a.n ${_namaPemilikController.text.trim()}',
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
        setState(() => _selectedProvider = null);
        _loadSaldoUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: AppColors.primarySage,
        elevation: 0,
        title: const Text(
          'Penarikan E-Wallet / Bank',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CARD SALDO TERSEDIA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Tersedia',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dapat ditarik kapan saja',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
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
                            _saldoUser,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. DROPDOWN PILIH APK / BANK (SAFE TYPE SYSTEM)
              const Text(
                'Pilih Aplikasi Pembayaran / Bank',
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
                    value: _selectedProvider,
                    hint: const Text('Pilih E-Wallet / Bank tujuan', style: TextStyle(fontSize: 14, color: Colors.black45)),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark),
                    items: _providerOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProvider = newValue;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. TEXTFIELD NOMOR REKENING / HP
              const Text(
                'Nomor Rekening / No HP E-Wallet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomorTujuanController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Nomor tujuan wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Contoh: 081234567890 / 1234567890',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 4. TEXTFIELD NAMA PEMILIK
              const Text(
                'Nama Pemilik Rekening / Akun',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaPemilikController,
                textCapitalization: TextCapitalization.words,
                validator: (val) => val == null || val.isEmpty ? 'Nama pemilik wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama sesuai akun E-Wallet / Bank',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5. TEXTFIELD NOMINAL PENARIKAN
              const Text(
                'Nominal Penarikan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Nominal penarikan wajib diisi' : null,
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

              // 6. TEXTFIELD CATATAN (OPSIONAL)
              const Text(
                'Catatan (opsional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _catatanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'contoh: Kirim ke akun DANA pribadi',
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

              // 7. TOMBOL KIRIM PENGAJUAN
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimPengajuanEwallet,
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
                          'Kirim Pengajuan Penarikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // INFO BOX VERIFIKASI
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
                            'Petugas akan memverifikasi dan menginstruksikan transfer saldo ke rekening/E-Wallet tujuan kamu.',
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
                            'Proses verifikasi & transfer maksimal 1x24 jam.',
                            style: TextStyle(fontSize: 12, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}