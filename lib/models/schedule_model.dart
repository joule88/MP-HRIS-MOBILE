class ScheduleModel {
  final String tanggal;
  final String hari;
  final bool isHariKerja;
  final bool isHariLibur;
  final String? keteranganLibur;
  final String shiftNama;
  final String jamMasuk;
  final String jamPulang;
  final String? statusPoin;
  final String? statusPresensi;
  final String warnaKalender;

  ScheduleModel({
    required this.tanggal,
    required this.hari,
    this.isHariKerja = false,
    this.isHariLibur = false,
    this.keteranganLibur,
    this.shiftNama = '-',
    this.jamMasuk = '-',
    this.jamPulang = '-',
    this.statusPoin,
    this.statusPresensi,
    this.warnaKalender = '#E0E0E0',
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == true) return true;
      if (value == 1) return true;
      if (value == '1') return true;
      return false;
    }

    return ScheduleModel(
      tanggal: json['tanggal']?.toString() ?? '',
      hari: json['hari']?.toString() ?? '',
      isHariKerja: parseBool(json['is_hari_kerja']),
      isHariLibur: parseBool(json['is_hari_libur']),
      keteranganLibur: json['keterangan_libur']?.toString(),
      shiftNama: json['shift_nama']?.toString() ?? '-',
      jamMasuk: json['jam_masuk']?.toString() ?? json['jam_mulai']?.toString() ?? '-',
      jamPulang: json['jam_pulang']?.toString() ?? json['jam_selesai']?.toString() ?? '-',
      statusPoin: json['status_poin']?.toString(),
      statusPresensi: json['status_presensi']?.toString(),
      warnaKalender: json['warna_kalender']?.toString() ?? '#E0E0E0',
    );
  }
}
