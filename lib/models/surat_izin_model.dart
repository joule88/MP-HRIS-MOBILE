class ApprovalModel {
  final int tahap;
  final String tahapLabel;
  final String status;
  final String approverNama;
  final String approverJabatan;
  final String? ttdApprover;
  final String? catatan;
  final String? createdAt;

  ApprovalModel({
    required this.tahap,
    required this.tahapLabel,
    required this.status,
    required this.approverNama,
    required this.approverJabatan,
    this.ttdApprover,
    this.catatan,
    this.createdAt,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      tahap: json['tahap'] is int ? json['tahap'] : int.tryParse(json['tahap']?.toString() ?? '0') ?? 0,
      tahapLabel: json['tahap_label']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      approverNama: json['approver_nama']?.toString() ?? 'N/A',
      approverJabatan: json['approver_jabatan']?.toString() ?? 'N/A',
      ttdApprover: json['ttd_approver']?.toString(),
      catatan: json['catatan']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class SuratIzinModel {
  final String id;
  final String nomorSurat;
  final String statusSurat;
  final String jenisIzin;
  final String? ttdPengaju;
  final List<ApprovalModel> approvals;
  final String? createdAt;

  final String? isiSurat;
  final String? pengajuNama;
  final String? pengajuNik;
  final String? pengajuJabatan;
  final String? pengajuDivisi;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? alasan;

  SuratIzinModel({
    required this.id,
    required this.nomorSurat,
    required this.statusSurat,
    required this.jenisIzin,
    this.ttdPengaju,
    required this.approvals,
    this.createdAt,
    this.isiSurat,
    this.pengajuNama,
    this.pengajuNik,
    this.pengajuJabatan,
    this.pengajuDivisi,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.alasan,
  });

  factory SuratIzinModel.fromJson(Map<String, dynamic> json) {
    List<ApprovalModel> approvalsList = [];
    if (json['approvals'] != null && json['approvals'] is List) {
      approvalsList = (json['approvals'] as List)
          .map((a) => ApprovalModel.fromJson(a))
          .toList();
    }

    return SuratIzinModel(
      id: json['id_surat']?.toString() ?? '',
      nomorSurat: json['nomor_surat']?.toString() ?? '',
      statusSurat: json['status_surat']?.toString() ?? '',
      jenisIzin: json['jenis_izin']?.toString() ?? 'N/A',
      ttdPengaju: json['ttd_pengaju']?.toString(),
      approvals: approvalsList,
      createdAt: json['created_at']?.toString(),
      isiSurat: json['isi_surat']?.toString(),
      pengajuNama: json['pengaju'] != null ? json['pengaju']['nama']?.toString() : null,
      pengajuNik: json['pengaju'] != null ? json['pengaju']['nik']?.toString() : null,
      pengajuJabatan: json['pengaju'] != null ? json['pengaju']['jabatan']?.toString() : null,
      pengajuDivisi: json['pengaju'] != null ? json['pengaju']['divisi']?.toString() : null,
      tanggalMulai: json['pengajuan'] != null ? json['pengajuan']['tanggal_mulai']?.toString() : null,
      tanggalSelesai: json['pengajuan'] != null ? json['pengajuan']['tanggal_selesai']?.toString() : null,
      alasan: json['pengajuan'] != null ? json['pengajuan']['alasan']?.toString() : null,
    );
  }

  String get statusLabel {
    switch (statusSurat) {
      case 'menunggu_manajer': return 'Menunggu Manajer';
      case 'menunggu_hrd': return 'Menunggu HRD';
      case 'disetujui': return 'Disetujui';
      case 'ditolak': return 'Ditolak';
      default: return statusSurat;
    }
  }

  bool get isApproved => statusSurat == 'disetujui';
  bool get isRejected => statusSurat == 'ditolak';
  bool get isPending => statusSurat.startsWith('menunggu');
}
