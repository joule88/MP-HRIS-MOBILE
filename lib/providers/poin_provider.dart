import 'package:flutter/material.dart';
import '../repositories/poin_repository.dart';

class PoinProvider extends ChangeNotifier {
  final PoinRepository _repository;

  PoinProvider({PoinRepository? repository})
      : _repository = repository ?? PoinRepository();

  bool _isLoading = false;
  String? _errorMessage;
  
  int? _totalPoin;
  int? _expiringPoints;
  DateTime? _expiryDate;
  List<Map<String, dynamic>> _pointHistory = [];
  
  TimeOfDay? _shiftStart;
  TimeOfDay? _shiftEnd;
  String? _namaShift;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get totalPoin => _totalPoin;
  int? get expiringPoints => _expiringPoints;
  DateTime? get expiryDate => _expiryDate;
  List<Map<String, dynamic>> get pointHistory => _pointHistory;
  
  TimeOfDay? get shiftStart => _shiftStart;
  TimeOfDay? get shiftEnd => _shiftEnd;
  String? get namaShift => _namaShift;

  Future<void> loadExpiringPoints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getExpiringPoints();

      if (result['success']) {
        _totalPoin = result['data']['total_poin'] as int?;
        
        final expiring = result['data']['expiring_points'];
        if (expiring != null) {
          _expiringPoints = expiring['poin'] as int?;
          if (expiring['tanggal_kadaluarsa'] != null) {
            _expiryDate = DateTime.tryParse(expiring['tanggal_kadaluarsa']);
          }
        }
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPointHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPointHistory();

      if (result['success']) {
        _pointHistory = List<Map<String, dynamic>>.from(
          result['data']['history'] ?? []
        );
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkShiftSchedule(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    _shiftStart = null; 
    _shiftEnd = null;
    _namaShift = null;
    notifyListeners();

    try {
      String dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final result = await _repository.checkSchedule(dateStr);

      if (result['success']) {
        final data = result['data'];
        
        if (data['jam_mulai'] != null) {
          final parts = (data['jam_mulai'] as String).split(':');
          _shiftStart = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        
        if (data['jam_selesai'] != null) {
          final parts = (data['jam_selesai'] as String).split(':');
          _shiftEnd = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }

        _namaShift = data['nama_shift'];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> tukarPoin({
    required int jumlah,
    required String keterangan,
    required int idPengurangan,
    String? jamMasukCustom,
    String? jamPulangCustom,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.tukarPoin(
        jumlah: jumlah,
        keterangan: keterangan,
        idPengurangan: idPengurangan,
        jamMasukCustom: jamMasukCustom,
        jamPulangCustom: jamPulangCustom,
      );

      if (result['success']) {
        await Future.wait([
          loadExpiringPoints(),
          loadPointHistory(),
        ]);
        
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }

      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }
}
