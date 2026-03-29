import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/attendance_repository.dart';
import '../models/presensi_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository = AttendanceRepository();

  List<PresensiHistoryModel> historyList = [];
  bool isLoading = false;

  String currentLocationName = "Tegal Besar, Jember";
  LatLng? currentLocation;
  bool isWithinRadius = false;
  double distanceToOffice = 0.0;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String? reasonOutsideRadius;
  String? reasonEarlyCheckout;
  String? reasonLateCheckin;

  Future<bool> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    isLoading = true;
    notifyListeners();

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi (GPS) tidak aktif. Mohon nyalakan GPS Anda.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak aplikasinya.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      await updateLocation(position.latitude, position.longitude);

      isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      print('Error getting location: $e');
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    currentLocation = LatLng(lat, lng);

    try {
      final radiusCheck = await _repository.checkRadius(lat, lng);
      isWithinRadius = radiusCheck['is_within_radius'] ?? false;
      distanceToOffice = (radiusCheck['distance'] ?? 0.0).toDouble();
      notifyListeners();
    } catch (e) {
      print('Error checking radius: $e');
      isWithinRadius = false;
      notifyListeners();
    }
  }

  void setReasonOutsideRadius(String? reason) {
    reasonOutsideRadius = reason;
    notifyListeners();
  }

  void setReasonEarlyCheckout(String? reason) {
    reasonEarlyCheckout = reason;
    notifyListeners();
  }

  void setReasonLateCheckin(String? reason) {
    reasonLateCheckin = reason;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      historyList = await _repository.getHistory(
        month: selectedMonth,
        year: selectedYear,
      );
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setMonth(int month) {
    selectedMonth = month;
    notifyListeners();
    fetchHistory();
  }

  void setYear(int year) {
    selectedYear = year;
    notifyListeners();
    fetchHistory();
  }

  Future<bool> submitPresensi(String type, File photoFile) async {
    if (currentLocation == null) {
      print('Location not available');
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.submitPresensi(
        type,
        currentLocation!.latitude,
        currentLocation!.longitude,
        photoFile,
        keteranganLuarRadius: !isWithinRadius ? reasonOutsideRadius : null,
        keteranganPulang: type == 'pulang' ? reasonEarlyCheckout : null,
        alasanTelat: type == 'masuk' ? reasonLateCheckin : null,
      );

      if (success) {
        reasonOutsideRadius = null;
        reasonEarlyCheckout = null;
        reasonLateCheckin = null;
      }

      return success;
    } catch (e) {
      print('Error submitting attendance: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> resubmitPresensi(int idPresensi, String keterangan) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.resubmitPresensi(idPresensi, keterangan);
      if (success) {
        await fetchHistory();
      }
      return success;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    reasonOutsideRadius = null;
    reasonEarlyCheckout = null;
    reasonLateCheckin = null;
    notifyListeners();
  }
}
