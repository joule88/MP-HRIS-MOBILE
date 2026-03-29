import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../providers/surat_izin_provider.dart';

class SuratIzinDetailSheet extends StatefulWidget {
  final String idSurat;

  const SuratIzinDetailSheet({super.key, required this.idSurat});

  @override
  State<SuratIzinDetailSheet> createState() => _SuratIzinDetailSheetState();
}

class _SuratIzinDetailSheetState extends State<SuratIzinDetailSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuratIzinProvider>().fetchDetail(widget.idSurat);
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


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
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
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text("Detail Surat Izin", style: AppTheme.heading3),
                      ),
                      if (detail != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusColor(detail.statusSurat).withValues(alpha: 0.1),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 48, color: AppTheme.textTertiary),
                          const SizedBox(height: 12),
                          Text(
                            "Gagal memuat detail surat",
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
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
