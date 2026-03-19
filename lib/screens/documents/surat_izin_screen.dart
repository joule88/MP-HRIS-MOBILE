import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../providers/surat_izin_provider.dart';
import '../../models/surat_izin_model.dart';
import '../../widgets/atoms/fade_in_up.dart';

class SuratIzinScreen extends StatefulWidget {
  const SuratIzinScreen({Key? key}) : super(key: key);

  @override
  State<SuratIzinScreen> createState() => _SuratIzinScreenState();
}

class _SuratIzinScreenState extends State<SuratIzinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuratIzinProvider>().fetchSurat();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'disetujui': return AppTheme.statusGreen;
      case 'ditolak': return AppTheme.statusRed;
      case 'menunggu_hrd': return AppTheme.primaryDark;
      default: return AppTheme.statusYellow;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'disetujui': return Icons.check_circle;
      case 'ditolak': return Icons.cancel;
      default: return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        title: Text("Surat Izin", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SuratIzinProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.listSurat.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.listSurat.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    "Belum ada surat izin",
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    "Surat izin akan muncul setelah Anda\nmengajukan izin dan membuat surat",
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSurat(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: provider.listSurat.length,
              itemBuilder: (context, index) {
                final surat = provider.listSurat[index];
                return FadeInUp(
                  delayMs: index * 50,
                  child: _buildSuratCard(surat),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuratCard(SuratIzinModel surat) {
    final color = _statusColor(surat.statusSurat);

    return GestureDetector(
      onTap: () => _showSuratDetail(surat),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  Icon(_statusIcon(surat.statusSurat), color: color, size: 24),
                  const SizedBox(width: AppTheme.spacingMd),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surat.nomorSurat,
                          style: AppTheme.labelLarge.copyWith(fontFamily: 'monospace', fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          surat.jenisIzin,
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      surat.statusLabel,
                      style: AppTheme.labelMedium.copyWith(color: color, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
              child: Row(
                children: [
                  _buildProgressDot("Pengaju", true, AppTheme.statusGreen),
                  _buildProgressLine(surat.approvals.any((a) => a.tahap == 1)),
                  _buildProgressDot(
                    "Manajer",
                    surat.approvals.any((a) => a.tahap == 1),
                    surat.approvals.any((a) => a.tahap == 1 && a.status == 'disetujui')
                        ? AppTheme.statusGreen
                        : surat.approvals.any((a) => a.tahap == 1 && a.status == 'ditolak')
                            ? AppTheme.statusRed
                            : AppTheme.textTertiary,
                  ),
                  _buildProgressLine(surat.approvals.any((a) => a.tahap == 2)),
                  _buildProgressDot(
                    "HRD",
                    surat.approvals.any((a) => a.tahap == 2),
                    surat.approvals.any((a) => a.tahap == 2 && a.status == 'disetujui')
                        ? AppTheme.statusGreen
                        : surat.approvals.any((a) => a.tahap == 2 && a.status == 'ditolak')
                            ? AppTheme.statusRed
                            : AppTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(String label, bool active, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: active ? color : const Color(0xFFE2E8F0), width: 2),
          ),
          child: active
              ? Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 10, color: active ? color : AppTheme.textTertiary)),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? AppTheme.statusGreen : const Color(0xFFE2E8F0),
      ),
    );
  }

  void _showSuratDetail(SuratIzinModel surat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<SuratIzinProvider>().fetchDetail(surat.id);
        });

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
            ),
            child: Consumer<SuratIzinProvider>(
              builder: (context, provider, _) {
                final detail = provider.selectedSurat;

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Detail Surat Izin", style: AppTheme.heading3),
                          if (detail != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _statusColor(detail.statusSurat).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                detail.statusLabel,
                                style: AppTheme.labelMedium.copyWith(
                                  color: _statusColor(detail.statusSurat),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (provider.isLoadingDetail)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (detail == null)
                      Expanded(
                        child: Center(
                          child: Text("Gagal memuat detail", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary)),
                        ),
                      )
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailSection("Informasi Surat", [
                                _buildDetailRow("No. Surat", detail.nomorSurat),
                                _buildDetailRow("Jenis Izin", detail.jenisIzin),
                                if (detail.tanggalMulai != null) _buildDetailRow("Tanggal Mulai", detail.tanggalMulai!),
                                if (detail.tanggalSelesai != null) _buildDetailRow("Tanggal Selesai", detail.tanggalSelesai!),
                                if (detail.alasan != null) _buildDetailRow("Alasan", detail.alasan!),
                              ]),

                              const SizedBox(height: AppTheme.spacingMd),

                              if (detail.isiSurat != null) ...[
                                _buildDetailSection("Isi Surat", []),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgCard,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    detail.isiSurat!,
                                    style: AppTheme.bodyMedium.copyWith(height: 1.6),
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingMd),
                              ],

                              _buildDetailSection("Tanda Tangan", []),
                              _buildSignatureArea("Yang Mengajukan", detail.pengajuNama ?? '-', detail.ttdPengaju),

                              ...detail.approvals.where((a) => a.tahap == 1).map((a) =>
                                _buildSignatureArea("Manajer", a.approverNama, a.ttdApprover,
                                  status: a.status, catatan: a.catatan),
                              ),

                              if (!detail.approvals.any((a) => a.tahap == 1))
                                _buildSignatureArea("Manajer", "Menunggu Approval", null, isPending: true),

                              ...detail.approvals.where((a) => a.tahap == 2).map((a) =>
                                _buildSignatureArea("HRD", a.approverNama, a.ttdApprover,
                                  status: a.status, catatan: a.catatan),
                              ),

                              if (!detail.approvals.any((a) => a.tahap == 2))
                                _buildSignatureArea("HRD", "Menunggu Approval", null, isPending: true),

                              const SizedBox(height: AppTheme.spacingXl),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.labelMedium.copyWith(
            color: AppTheme.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        if (children.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(children: children),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureArea(String label, String name, String? ttdUrl, {
    String? status,
    String? catatan,
    bool isPending = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isPending ? AppTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(color: AppTheme.textTertiary, letterSpacing: 0.3),
          ),
          const SizedBox(height: AppTheme.spacingSm),

          SizedBox(
            height: 80,
            child: ttdUrl != null
                ? CachedNetworkImage(
                    imageUrl: ttdUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => Icon(Icons.error_outline, color: AppTheme.textTertiary),
                  )
                : isPending
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_empty, color: AppTheme.textTertiary, size: 28),
                          const SizedBox(height: 4),
                          Text("Menunggu", style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary)),
                        ],
                      )
                    : status == 'ditolak'
                        ? Text("DITOLAK", style: AppTheme.labelLarge.copyWith(color: AppTheme.statusRed))
                        : const SizedBox.shrink(),
          ),

          const SizedBox(height: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.only(top: AppTheme.spacingSm),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Text(name, style: AppTheme.labelLarge.copyWith(fontSize: 13)),
          ),

          if (catatan != null && catatan.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Catatan: $catatan",
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
