class DivisionModel {
  final int idDivisi;
  final String namaDivisi;

  DivisionModel({
    required this.idDivisi,
    required this.namaDivisi,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) {
    return DivisionModel(
      idDivisi: json['id_divisi'],
      namaDivisi: json['nama_divisi'],
    );
  }
}
