class ShiftModel {
  final int idShift;
  final String namaShift;
  final String jamVideo;
  final String jamMulai;
  final String jamSelesai;

  ShiftModel({
    required this.idShift,
    required this.namaShift,
    required this.jamVideo,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      idShift: json['id_shift'],
      namaShift: json['nama_shift'],
      jamVideo: json['jam_masuk'] ?? '',
      jamMulai: json['jam_masuk'],
      jamSelesai: json['jam_pulang'],
    );
  }
}
