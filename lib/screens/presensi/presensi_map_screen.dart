import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/error_handler.dart';
import '../../core/theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../repositories/face_repository.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/organisms/map_view_organism.dart';
import 'camera_capture_screen.dart';

class PresensiMapScreen extends StatefulWidget {
  final String type;

  const PresensiMapScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<PresensiMapScreen> createState() => _PresensiMapScreenState();
}

class _PresensiMapScreenState extends State<PresensiMapScreen> {
  static const LatLng _defaultLocation = LatLng(-8.184486, 113.668075);
  static const double _defaultRadius = 200;

  bool _isProcessing = false;
  String _processingStatus = '';

  LatLng get _officeLocation {
    final presensi = context.read<HomeProvider>().presensiToday;
    if (presensi?.kantorLat != null && presensi?.kantorLon != null) {
      return LatLng(presensi!.kantorLat!, presensi.kantorLon!);
    }
    return _defaultLocation;
  }

  double get _radius {
    final presensi = context.read<HomeProvider>().presensiToday;
    return presensi?.kantorRadius ?? _defaultRadius;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
    });
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isProcessing = true;
      _processingStatus = "Mengambil Lokasi...";
    });
    try {
      final provider = context.read<AttendanceProvider>();
      await provider.getCurrentPosition();
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.substring(11);
        }
        if (errorMessage == 'Layanan lokasi (GPS) tidak aktif. Mohon nyalakan GPS Anda.') {
          _showGpsDisabledDialog();
        } else {
          _showErrorSnackBar(errorMessage);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final user = homeProvider.user;

    final currentLocation = attendanceProvider.currentLocation ?? _officeLocation;

    final distance = attendanceProvider.currentLocation != null
        ? Geolocator.distanceBetween(
            currentLocation.latitude, currentLocation.longitude,
            _officeLocation.latitude, _officeLocation.longitude,
          )
        : double.infinity;

    final isWithinRadius = attendanceProvider.currentLocation != null && distance <= _radius;

    final now = DateTime.now();
    final dateStr = "${now.day} ${_getMonthName(now.month)} ${now.year}";

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.type == 'masuk' ? "Presensi Masuk" : "Presensi Pulang",
          style: AppTheme.heading3.copyWith(
            shadows: [const Shadow(color: Colors.white, blurRadius: 10)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 16),
          ),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapViewOrganism(
              officeLocation: _officeLocation,
              radiusInMeters: _radius,
              userLocation: currentLocation,
              isWithinRadius: isWithinRadius,
              isFullscreen: true,
            ),
          ),

          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + AppTheme.spacingMd,
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: (isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed).withOpacity(0.5),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Icon(
                          isWithinRadius ? Icons.check : Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 16
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isWithinRadius ? "Kamu Berada di Area Kantor!" : "Kamu Diluar Area Kantor!",
                              style: AppTheme.labelLarge.copyWith(color: AppTheme.textPrimary),
                            ),
                            Text(
                              isWithinRadius ? "Sekarang kamu bisa absensi" : "Wajib sertakan alasan presensi",
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.bgLight,
                    AppTheme.bgLight.withOpacity(0.95),
                    AppTheme.bgLight.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppTheme.spacingLg,
                    right: AppTheme.spacingLg,
                    bottom: AppTheme.spacingLg,
                    top: 60,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    image: user?.foto != null && user!.foto!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(user.foto!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: user?.foto == null || user!.foto!.isEmpty
                                      ? const Icon(Icons.person, size: 28, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user?.namaLengkap ?? 'Karyawan', style: AppTheme.heading3),
                                      const SizedBox(height: 2),
                                      Text(dateStr, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                                      const SizedBox(height: 4),
                                      Text(
                                        attendanceProvider.currentLocation != null
                                            ? "Jarak: ${distance.toStringAsFixed(0)}m dari kantor"
                                            : "Mencari lokasi...",
                                        style: AppTheme.bodySmall.copyWith(
                                          color: attendanceProvider.currentLocation == null ? AppTheme.textSecondary : (isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingMd),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF007AFF), Color(0xFF0056B3)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  )
                                ]
                              ),
                              child: Column(
                                children: [
                                  Text("Presensi Datang", style: AppTheme.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
                                  const SizedBox(height: 4),
                                  Text(
                                    (homeProvider.presensiToday?.jamMasuk?.isNotEmpty == true)
                                        ? homeProvider.presensiToday!.jamMasuk!
                                        : "08:00",
                                    style: AppTheme.heading2.copyWith(color: Colors.white, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                              child: Column(
                                children: [
                                  Text("Presensi Pulang", style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    (homeProvider.presensiToday?.jamPulang?.isNotEmpty == true && homeProvider.presensiToday!.jamPulang != '-')
                                        ? homeProvider.presensiToday!.jamPulang!
                                        : "17:00",
                                    style: AppTheme.heading2.copyWith(color: AppTheme.textPrimary, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          boxShadow: attendanceProvider.currentLocation != null
                              ? [
                                  BoxShadow(
                                    color: (isWithinRadius ? AppTheme.primaryBlue : AppTheme.statusRed).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: CustomButton(
                          text: attendanceProvider.isLoading || _isProcessing
                              ? "Memproses..."
                              : (attendanceProvider.currentLocation != null
                                  ? (isWithinRadius ? "Presensi Sekarang" : "Presensi Di Luar Radius")
                                  : "Menunggu Lokasi..."),
                          type: ButtonType.primary,
                          isFullWidth: true,
                          backgroundColor: attendanceProvider.currentLocation != null
                              ? (isWithinRadius ? AppTheme.primaryBlue : AppTheme.statusRed)
                              : Colors.grey,
                          onPressed: (attendanceProvider.isLoading || _isProcessing || attendanceProvider.currentLocation == null)
                              ? null
                              : () {
                                  _handlePresensi(context, isWithinRadius);
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isProcessing)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          Text(
                            _processingStatus,
                            style: AppTheme.heading3,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[month - 1];
  }

  void _handlePresensi(BuildContext context, bool isWithinRadius) {
    if (widget.type == 'pulang') {
      final homeProvider = context.read<HomeProvider>();
      final presensi = homeProvider.presensiToday;

      if (presensi?.jadwalJamPulang != null) {
        try {
          final now = DateTime.now();
          final parts = presensi!.jadwalJamPulang!.split(':');
          final scheduled = DateTime(
            now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]),
            parts.length > 2 ? int.parse(parts[2]) : 0
          );

          if (now.isBefore(scheduled)) {
            _showEarlyCheckoutDialog(context);
            return;
          }
        } catch (e) {
          print("Error parsing jadwalJamPulang: $e");
        }
      }
    }

    if (widget.type == 'masuk') {
      final homeProvider = context.read<HomeProvider>();
      final presensi = homeProvider.presensiToday;

      if (presensi?.jadwalJamMasuk != null) {
        try {
          final now = DateTime.now();
          final parts = presensi!.jadwalJamMasuk!.split(':');
          final scheduled = DateTime(
            now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]),
            parts.length > 2 ? int.parse(parts[2]) : 0
          );

          final batasToleransi = scheduled.add(const Duration(minutes: 10));

          if (now.isAfter(batasToleransi)) {
            _showLateCheckinDialog(context, isWithinRadius);
            return;
          }
        } catch (e) {
          print("Error parsing jadwalJamMasuk: $e");
        }
      }
    }

    if (!isWithinRadius) {
      _showOutsideRadiusDialog(context);
    } else {
      _startFaceRecognitionFlow(context);
    }
  }

  void _showOutsideRadiusDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXl),
              topRight: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppTheme.statusRed),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Presensi Luar Radius",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Anda berada di luar area kantor. Mohon sertakan alasan keberadaan Anda di luar area:",
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Contoh: Meeting di tempat klien",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  filled: true,
                  fillColor: AppTheme.bgInput,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: "Lanjutkan",
                    type: ButtonType.primary,
                    backgroundColor: AppTheme.statusRed,
                    isFullWidth: false,
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ErrorHandler.showWarning('Alasan wajib diisi!');
                        return;
                      }

                      context.read<AttendanceProvider>().setReasonOutsideRadius(reason);
                      Navigator.pop(context);
                      _startFaceRecognitionFlow(this.context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEarlyCheckoutDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXl),
              topRight: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusOrange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer_off_outlined, color: AppTheme.statusOrange),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Pulang Lebih Awal",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Anda melakukan absen pulang sebelum waktunya. Mohon sertakan alasannya:",
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Contoh: Ada keperluan mendesak",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  filled: true,
                  fillColor: AppTheme.bgInput,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: "Lanjutkan",
                    type: ButtonType.primary,
                    backgroundColor: AppTheme.statusOrange,
                    isFullWidth: false,
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ErrorHandler.showWarning('Alasan wajib diisi!');
                        return;
                      }

                      context.read<AttendanceProvider>().setReasonEarlyCheckout(reason);
                      Navigator.pop(context);

                      final attendanceProvider = context.read<AttendanceProvider>();
                      final distance = attendanceProvider.currentLocation != null
                          ? Geolocator.distanceBetween(
                              attendanceProvider.currentLocation!.latitude,
                              attendanceProvider.currentLocation!.longitude,
                              _officeLocation.latitude,
                              _officeLocation.longitude,
                            )
                          : double.infinity;

                      if (distance > _radius) {
                        _showOutsideRadiusDialog(this.context);
                      } else {
                        _startFaceRecognitionFlow(this.context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLateCheckinDialog(BuildContext context, bool isWithinRadius) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXl),
              topRight: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_filled, color: AppTheme.statusRed),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Presensi Terlambat",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Anda melakukan absen masuk melewati batas toleransi. Mohon sertakan alasan keterlambatan:",
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Contoh: Ban bocor di jalan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: BorderSide(color: AppTheme.textTertiary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  filled: true,
                  fillColor: AppTheme.bgInput,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal", style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: "Lanjutkan",
                    type: ButtonType.primary,
                    backgroundColor: AppTheme.statusRed,
                    isFullWidth: false,
                    onPressed: () {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        ErrorHandler.showWarning('Alasan terlambat wajib diisi!');
                        return;
                      }

                      context.read<AttendanceProvider>().setReasonLateCheckin(reason);
                      Navigator.pop(context);

                      if (!isWithinRadius) {
                        _showOutsideRadiusDialog(this.context);
                      } else {
                        _startFaceRecognitionFlow(this.context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startFaceRecognitionFlow(BuildContext context) async {
    final File? photoResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraCaptureScreen(),
      ),
    );

    if (photoResult == null || !mounted) return;

    setState(() {
      _isProcessing = true;
      _processingStatus = "Memverifikasi wajah...";
    });

    try {
      final faceResult = await FaceRepository().verifyFace(photoResult);

      final bool isVerified = faceResult['verified'] == true;
      final double? confidence = (faceResult['confidence'] is num)
          ? (faceResult['confidence'] as num).toDouble()
          : null;

      if (!isVerified) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });

        _showFaceFailedDialog(
          confidence: confidence,
          message: faceResult['message']?.toString() ?? "Wajah tidak cocok.",
        );
        return;
      }

      setState(() {
        _processingStatus = "Mengirim data presensi...";
      });

      final provider = context.read<AttendanceProvider>();
      final success = await provider.submitPresensi(widget.type, photoResult);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        HapticFeedback.heavyImpact();
        Navigator.pop(context, {
          'success': true,
          'message': widget.type == 'masuk'
              ? 'Absen masuk berhasil!'
              : 'Absen pulang berhasil!',
        });
      } else {
        _showErrorSnackBar("Gagal mengirim presensi. Silakan coba lagi.");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.substring(11);
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showFaceFailedDialog({double? confidence, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.face_retouching_off, color: AppTheme.statusRed, size: 28),
            const SizedBox(width: 8),
            Flexible(child: Text("Verifikasi Gagal", style: AppTheme.heading3, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: AppTheme.bodyMedium),
            if (confidence != null && confidence < 900) ...[
              const SizedBox(height: 12),
              Text(
                "Jarak LBPH: ${confidence.toStringAsFixed(1)}",
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              "Pastikan pencahayaan cukup dan wajah terlihat jelas.",
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          CustomButton(
            text: "Coba Lagi",
            type: ButtonType.primary,
            isFullWidth: false,
            onPressed: () {
              Navigator.pop(ctx);
              _startFaceRecognitionFlow(context);
            },
          ),
        ],
      ),
    );
  }

  void _showGpsDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_off_rounded, color: AppTheme.statusRed, size: 28),
            const SizedBox(width: 8),
            Text("GPS Tidak Aktif", style: AppTheme.heading3),
          ],
        ),
        content: Text(
          "Layanan lokasi (GPS) tidak aktif. Mohon nyalakan GPS Anda di Pengaturan agar dapat mengambil lokasi kantor.",
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Kembali ke menu presensi
            },
            child: const Text("Batal"),
          ),
          CustomButton(
            text: "Buka Pengaturan",
            type: ButtonType.primary,
            isFullWidth: false,
            onPressed: () async {
              Navigator.pop(ctx);
              await Geolocator.openLocationSettings();
              // Jika user menyalakan dan kembali ke app, fetch locator lagi bisa dipicu manual dgn pencet reload
            },
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ErrorHandler.showError(message);
  }
}
