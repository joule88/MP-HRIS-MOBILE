class LemburModel {
  final String idLembur;
  final int idUser;
  final DateTime tanggalLembur;
  final String jamMulai;
  final String jamSelesai;
  final int durasiMenit;
  final String keterangan;
  final int idStatus;
  final String? statusLabel;
  final DateTime tanggalDiajukan;

  LemburModel({
    required this.idLembur,
    required this.idUser,
    required this.tanggalLembur,
    required this.jamMulai,
    required this.jamSelesai,
    required this.durasiMenit,
    required this.keterangan,
    required this.idStatus,
    this.statusLabel,
    required this.tanggalDiajukan,
  });

  factory LemburModel.fromJson(Map<String, dynamic> json) {
    return LemburModel(
      idLembur: json['id_lembur'].toString(),
      idUser: json['id_user'],
      tanggalLembur: DateTime.parse(json['tanggal_lembur']),
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      durasiMenit: json['durasi_menit'] is int ? json['durasi_menit'] : int.parse(json['durasi_menit'].toString()),
      keterangan: json['keterangan'] ?? '',
      idStatus: json['id_status'],
      statusLabel: _getStatusLabel(json['id_status']),
      tanggalDiajukan: DateTime.parse(json['tanggal_diajukan']),
    );
  }

  static String _getStatusLabel(int id) {
    switch (id) {
      case 1: return 'Pending';
      case 2: return 'Approved';
      case 3: return 'Rejected';
      default: return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lembur': idLembur,
      'id_user': idUser,
      'tanggal_lembur': tanggalLembur.toIso8601String(),
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'durasi_menit': durasiMenit,
      'keterangan': keterangan,
      'id_status': idStatus,
      'tanggal_diajukan': tanggalDiajukan.toIso8601String(),
    };
  }
}
