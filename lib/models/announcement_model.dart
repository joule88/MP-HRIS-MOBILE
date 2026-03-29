class AnnouncementModel {
  final int id;
  final String title;
  final String description;
  final String date;
  final String jabatan;
  final String namaPembuat;
  final String? avatarUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.jabatan,
    this.namaPembuat = 'Admin',
    this.avatarUrl,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['tanggal']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
      namaPembuat: json['nama_pembuat']?.toString() ?? 'Admin',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
