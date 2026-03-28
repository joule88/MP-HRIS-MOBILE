class NotifikasiModel {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }
}
