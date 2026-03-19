class TandaTanganModel {
  final String id;
  final String fileTtd;
  final bool isActive;
  final String? createdAt;

  TandaTanganModel({
    required this.id,
    required this.fileTtd,
    required this.isActive,
    this.createdAt,
  });

  factory TandaTanganModel.fromJson(Map<String, dynamic> json) {
    return TandaTanganModel(
      id: json['id_tanda_tangan']?.toString() ?? '',
      fileTtd: json['file_ttd']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at']?.toString(),
    );
  }
}
