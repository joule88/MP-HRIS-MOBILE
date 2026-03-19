class PengajuanModel {
  final String id;
  final String jenis;
  final String tanggalPengajuan;
  final String tanggalMulai;
  final String tanggalSelesai;
  final int totalHari;
  final String keterangan;
  final String status;
  final String? approvedAt;
  final String? jamMulai;
  final String? jamSelesai;

  PengajuanModel({
    required this.id,
    required this.jenis,
    required this.tanggalPengajuan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.totalHari,
    required this.keterangan,
    required this.status,
    this.approvedAt,
    this.jamMulai,
    this.jamSelesai,
  });

  factory PengajuanModel.fromJson(Map<String, dynamic> json) {
    return PengajuanModel(
      id: json['id_izin'].toString(),
      jenis: json['jenis_izin'] != null
          ? json['jenis_izin']['nama_izin']
          : 'N/A',
      tanggalPengajuan: json['created_at'] != null
          ? json['created_at'].toString().split('T')[0]
          : '',
      tanggalMulai: json['tanggal_mulai'],
      tanggalSelesai: json['tanggal_selesai'],
      totalHari: _calculateDays(json['tanggal_mulai'], json['tanggal_selesai']),
      keterangan: json['alasan'] ?? '',
      status: _mapStatus(json['id_status']),
      approvedAt: json['approved_at'],
    );
  }

  factory PengajuanModel.fromLemburJson(Map<String, dynamic> json) {
    return PengajuanModel(
      id: json['id_lembur'].toString(),
      jenis: 'Lembur',
      tanggalPengajuan: json['created_at'] != null
          ? json['created_at'].toString().split('T')[0]
          : '',
      tanggalMulai: json['tanggal_lembur'] ?? '',
      tanggalSelesai: json['tanggal_lembur'] ?? '',
      totalHari: 1,
      keterangan: json['keterangan'] ?? '',
      status: _mapStatus(json['id_status']),
      approvedAt: json['approved_at'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
    );
  }

  static int _calculateDays(String? start, String? end) {
    if (start == null || end == null) return 0;
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return endDate.difference(startDate).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  static String _mapStatus(dynamic statusId) {
    if (statusId == null) return 'pending';
    final id = int.tryParse(statusId.toString());
    if (id == 1) return 'pending';
    if (id == 2) return 'approved';
    if (id == 3) return 'rejected';
    return 'pending';
  }
}
