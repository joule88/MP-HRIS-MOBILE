class AnnouncementModel {
  final String title;
  final String description;
  final String date;
  final String jabatan;
  final String? avatarUrl;

  AnnouncementModel({
    required this.title,
    required this.description,
    required this.date,
    required this.jabatan,
    this.avatarUrl,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['tanggal']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
