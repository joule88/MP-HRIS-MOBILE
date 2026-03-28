import 'package:flutter/material.dart';
import '../../core/error_handler.dart';
import '../../core/theme.dart';
import '../../widgets/atoms/custom_avatar.dart';
import '../../widgets/organisms/change_password_dialog.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/face_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../widgets/organisms/profile_shimmer.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _deviceInfo = "Loading...";
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceProvider>().loadFaceStatus();
      context.read<AuthProvider>().refreshUser();
      _loadDeviceInfo();
      _loadAppVersion();
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = "${info.version}+${info.buildNumber}";
      });
    }
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceData = "Unknown Device";

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = "${iosInfo.name} ${iosInfo.systemName}";
      }
    } catch (e) {
      deviceData = "Unknown Device";
    }

    if (mounted) {
      setState(() {
        _deviceInfo = deviceData;
      });
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: Text("Konfirmasi Logout", style: AppTheme.heading3),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              "Keluar",
              style: AppTheme.labelLarge.copyWith(color: AppTheme.statusRed),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ErrorHandler.showInfo('$label berhasil disalin');
  }

  String _formatTanggalIndonesia(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        title: Text("Profil Karyawan", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<FaceProvider>().loadFaceStatus();
          await context.read<AuthProvider>().refreshUser();
        },
        child: user == null
            ? const SafeArea(child: ProfileShimmer())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowMd,
                        ),
                        child: Column(
                          children: [
                            CustomAvatar(
                              imageUrl: user.foto ?? "https://avatar.iran.liara.run/public/35",
                              size: 80,
                              name: user.namaLengkap,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Text(
                              user.namaLengkap,
                              style: AppTheme.heading2.copyWith(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${user.divisi} • ${user.jabatan}",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(user.statusAktif).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(user.statusAktif),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.statusAktif == 'Aktif' ? "Karyawan Aktif" : user.statusAktif,
                                    style: AppTheme.labelMedium.copyWith(
                                      color: _getStatusColor(user.statusAktif),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      Text(
                        "INFORMASI PRIBADI",
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowMd,
                        ),
                        child: Column(
                          children: [
                            _buildInfoItem(
                              icon: Icons.email_outlined,
                              label: "Email",
                              value: user.email,
                            ),
                            _buildInfoItem(
                              icon: Icons.phone_outlined,
                              label: "No. Telepon",
                              value: user.noTelp ?? "-",
                            ),
                            _buildInfoItemWithCopy(
                              icon: Icons.badge_outlined,
                              label: "ID Karyawan",
                              value: user.nik ?? "-",
                              onCopy: user.nik != null
                                  ? () => _copyToClipboard(user.nik!, "ID Karyawan")
                                  : null,
                            ),
                            _buildInfoItem(
                              icon: Icons.business_outlined,
                              label: "Divisi",
                              value: user.divisi,
                            ),
                            _buildInfoItem(
                              icon: Icons.work_outline,
                              label: "Jabatan",
                              value: user.jabatan,
                            ),
                            _buildInfoItem(
                              icon: Icons.storefront_outlined,
                              label: "Kantor",
                              value: user.kantor ?? "-",
                            ),
                            _buildInfoItem(
                              icon: Icons.location_on_outlined,
                              label: "Alamat",
                              value: user.alamat ?? "-",
                            ),
                            _buildInfoItem(
                              icon: Icons.calendar_today_outlined,
                              label: "Bergabung Sejak",
                              value: _formatTanggalIndonesia(user.tglBergabung),
                            ),
                            _buildInfoItem(
                              icon: Icons.event_available_outlined,
                              label: "Sisa Cuti",
                              value: "${user.sisaCuti} Hari",
                            ),
                            if (user.roles.isNotEmpty)
                              _buildRolesItem(
                                icon: Icons.verified_user_outlined,
                                label: "Peran",
                                roles: user.roles,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      Text(
                        "PENGATURAN AKUN",
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowMd,
                        ),
                        child: Column(
                          children: [
                            _buildActionItem(
                              icon: Icons.edit_outlined,
                              label: "Edit Profil",
                              onTap: () async {
                                final result = await Navigator.pushNamed(context, '/profile/edit');
                                if (result == true && mounted) {
                                  context.read<AuthProvider>().refreshUser();
                                }
                              },
                            ),
                            _buildActionItem(
                              icon: Icons.face,
                              label: "Registrasi Wajah",
                              onTap: () => Navigator.pushNamed(context, '/onboarding/face-enrollment'),
                               trailingText: context.watch<FaceProvider>().faceStatus2['is_registered'] == true
                                   ? "Terdaftar"
                                   : "Belum Terdaftar",
                               trailingColor: context.watch<FaceProvider>().faceStatus2['is_registered'] == true
                                   ? AppTheme.statusGreen
                                   : AppTheme.statusRed,
                             ),
                             if (context.watch<FaceProvider>().faceStatus2['is_registered'] == true)
                              _buildActionItem(
                                icon: Icons.face_retouching_natural,
                                label: "Test Pengenalan Wajah",
                                onTap: () => Navigator.pushNamed(context, '/profile/face-test'),
                              ),
                            _buildActionItem(
                              icon: Icons.lock_outline,
                              label: "Ubah Kata Sandi",
                              onTap: () => _handleChangePassword(context),
                            ),
                            _buildActionItem(
                              icon: Icons.draw_outlined,
                              label: "Tanda Tangan Digital",
                              onTap: () => Navigator.pushNamed(context, '/profile/signature'),
                            ),
                            _buildActionItem(
                              icon: Icons.description_outlined,
                              label: "Surat Izin",
                              onTap: () => Navigator.pushNamed(context, '/surat-izin'),
                            ),
                            _buildActionItem(
                              icon: Icons.settings_ethernet,
                              label: "Pengaturan Server",
                              onTap: () => Navigator.pushNamed(context, '/settings/api'),
                            ),
                            _buildActionItem(
                              icon: Icons.logout,
                              label: "Keluar",
                              onTap: () => _handleLogout(context),
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Perangkat: $_deviceInfo",
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "App Version $_appVersion",
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 24),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemWithCopy({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 24),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              color: AppTheme.textTertiary,
              onPressed: onCopy,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    String? trailingText,
    Color? trailingColor,
  }) {
    final iconColor = isDestructive ? AppTheme.statusRed : AppTheme.textSecondary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: 4,
      ),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: isDestructive ? AppTheme.statusRed : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
             Text(
              trailingText,
              style: AppTheme.labelMedium.copyWith(
                color: trailingColor ?? AppTheme.textSecondary,
              ),
            ),
          if (trailingText != null) const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRolesItem({
    required IconData icon,
    required String label,
    required List<RoleData> roles,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 24),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: roles.map((role) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role.namaRole,
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Aktif') {
      return AppTheme.statusGreen;
    } else if (status == 'Menunggu Verifikasi') {
      return AppTheme.statusYellow;
    } else {
      return AppTheme.statusRed;
    }
  }
}
