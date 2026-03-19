class JabatanModel {
  final int idJabatan;
  final String namaJabatan;

  JabatanModel({
    required this.idJabatan,
    required this.namaJabatan,
  });

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      idJabatan: json['id_jabatan'],
      namaJabatan: json['nama_jabatan'],
    );
  }
}
