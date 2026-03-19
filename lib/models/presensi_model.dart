class PresensiModel {
  final String tanggal;
  final String? jamMasuk;
  final String? jamPulang;
  final String shift;
  final String lokasi;
  final String? statusJadwal;
  final bool isAdjusted;
  final String? adjustmentNote;
  final bool sudahAbsenMasuk;
  final bool sudahAbsenPulang;
  final String? statusMasuk;
  final String? statusPulang;
  final String? jadwalJamMasuk;
  final String? jadwalJamPulang;
  final String? kantorNama;
  final double? kantorLat;
  final double? kantorLon;
  final double? kantorRadius;

  PresensiModel({
    required this.tanggal,
    this.jamMasuk,
    this.jamPulang,
    required this.shift,
    required this.lokasi,
    this.statusJadwal,
    this.isAdjusted = false,
    this.adjustmentNote,
    this.sudahAbsenMasuk = false,
    this.sudahAbsenPulang = false,
    this.statusMasuk,
    this.statusPulang,
    this.jadwalJamMasuk,
    this.jadwalJamPulang,
    this.kantorNama,
    this.kantorLat,
    this.kantorLon,
    this.kantorRadius,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      tanggal: json['tanggal'],
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      shift: json['shift'],
      lokasi: json['lokasi'],
      statusJadwal: json['status_jadwal'],
      isAdjusted: json['is_adjusted'] ?? false,
      adjustmentNote: json['note'],
      sudahAbsenMasuk: json['sudah_absen_masuk'] ?? false,
      sudahAbsenPulang: json['sudah_absen_pulang'] ?? false,
      statusMasuk: json['status_masuk'],
      statusPulang: json['status_pulang'],
      jadwalJamMasuk: json['jadwal_jam_masuk'],
      jadwalJamPulang: json['jadwal_jam_pulang'],
      kantorNama: json['kantor_nama']?.toString(),
      kantorLat: (json['kantor_lat'] is num) ? (json['kantor_lat'] as num).toDouble() : null,
      kantorLon: (json['kantor_lon'] is num) ? (json['kantor_lon'] as num).toDouble() : null,
      kantorRadius: (json['kantor_radius'] is num) ? (json['kantor_radius'] as num).toDouble() : null,
    );
  }
}

class PresensiHistoryModel {
  final int? idPresensi;
  final String tanggal;
  final String? tanggalRaw;
  final String? jamMasuk;
  final String? jamPulang;
  final String totalJam;
  final String? shift;
  final String? statusMasuk;
  final String? statusPulang;
  final String? waktuTerlambat;
  final String? keteranganLuarRadius;
  final bool verifikasiWajah;
  final int? statusValidasi;
  final String? alasanPenolakan;

  PresensiHistoryModel({
    this.idPresensi,
    required this.tanggal,
    this.tanggalRaw,
    this.jamMasuk,
    this.jamPulang,
    required this.totalJam,
    this.shift,
    this.statusMasuk,
    this.statusPulang,
    this.waktuTerlambat,
    this.keteranganLuarRadius,
    this.verifikasiWajah = false,
    this.statusValidasi,
    this.alasanPenolakan,
  });

  factory PresensiHistoryModel.fromJson(Map<String, dynamic> json) {
    String hitungTotalJam = '-';
    if (json['jam_masuk'] != null && json['jam_pulang'] != null) {
      try {
        final masuk = DateTime.parse("2000-01-01 ${json['jam_masuk']}");
        final pulang = DateTime.parse("2000-01-01 ${json['jam_pulang']}");
        final selisih = pulang.difference(masuk);
        hitungTotalJam = '${selisih.inHours}j ${selisih.inMinutes.remainder(60)}m';
      } catch (e) {
      }
    }

    return PresensiHistoryModel(
      idPresensi: json['id_presensi'],
      tanggal: json['tanggal'] ?? '',
      tanggalRaw: json['tanggal_raw'],
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      totalJam: json['total_jam'] ?? hitungTotalJam,
      shift: json['shift'],
      statusMasuk: json['status_masuk'],
      statusPulang: json['status_pulang'],
      waktuTerlambat: json['waktu_terlambat'],
      keteranganLuarRadius: json['keterangan_luar_radius'],
      verifikasiWajah: json['verifikasi_wajah'] ?? false,
      statusValidasi: json['status_validasi'],
      alasanPenolakan: json['alasan_penolakan'],
    );
  }
}
