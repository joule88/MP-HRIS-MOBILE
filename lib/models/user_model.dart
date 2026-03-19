import '../core/constants/api_url.dart';

class UserModel {
  final int id;
  final String namaLengkap;
  final String email;
  final String? foto;
  final String jabatan;
  final String divisi;
  final String? kantor;
  final String? nik;
  final String? noTelp;
  final String? alamat;
  final String? tglBergabung;
  final int sisaCuti;
  final String statusAktif;
  final List<RoleData> roles;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.foto,
    required this.jabatan,
    required this.divisi,
    this.kantor,
    this.nik,
    this.noTelp,
    this.alamat,
    this.tglBergabung,
    this.sisaCuti = 0,
    this.statusAktif = 'Aktif',
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? divisiName;
    String? jabatanName;
    String? kantorName;

    if (json['divisi'] != null) {
      divisiName = json['divisi'] is Map
          ? json['divisi']['nama_divisi']
          : json['divisi'].toString();
    }

    if (json['jabatan'] != null) {
      jabatanName = json['jabatan'] is Map
          ? json['jabatan']['nama_jabatan']
          : json['jabatan'].toString();
    }

    if (json['kantor'] != null) {
      kantorName = json['kantor'] is Map
          ? json['kantor']['nama_kantor']
          : json['kantor'].toString();
    }

    List<RoleData> roles = [];
    if (json['roles'] is List) {
      roles = (json['roles'] as List)
          .map((role) {
            if (role is Map) {
              return RoleData.fromJson(Map<String, dynamic>.from(role));
            }
            return RoleData.fromJson({});
          })
          .toList();
    }

    String? fotoUrl = json['foto_profil']?.toString() ?? json['foto']?.toString();
    if (fotoUrl != null && fotoUrl.isNotEmpty && !fotoUrl.startsWith('http')) {
      fotoUrl = '${ApiUrl.imageBaseUrl}/$fotoUrl';
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      foto: fotoUrl,
      jabatan: jabatanName ?? 'N/A',
      divisi: divisiName ?? 'N/A',
      kantor: kantorName,
      nik: json['nik']?.toString(),
      noTelp: json['no_telp']?.toString(),
      alamat: json['alamat']?.toString(),
      tglBergabung: json['tgl_bergabung']?.toString(),
      sisaCuti: json['sisa_cuti'] is int ? json['sisa_cuti'] : int.tryParse(json['sisa_cuti']?.toString() ?? '0') ?? 0,
      statusAktif: _mapStatusAktif(json['status_aktif']),
      roles: roles,
    );
  }

  static String _mapStatusAktif(dynamic value) {
    if (value == null) return 'Tidak Diketahui';

    String str = value.toString();

    switch (str) {
      case '1':
        return 'Aktif';
      case '0':
        return 'Menunggu Verifikasi';
      default:
        return str;
    }
  }
}

class RoleData {
  final int idRole;
  final String namaRole;

  RoleData({
    required this.idRole,
    required this.namaRole,
  });

  factory RoleData.fromJson(Map<String, dynamic> json) {
    return RoleData(
      idRole: json['id_role'] is int
          ? json['id_role']
          : int.tryParse(json['id_role']?.toString() ?? '0') ?? 0,
      namaRole: json['nama_role']?.toString() ?? '',
    );
  }
}
