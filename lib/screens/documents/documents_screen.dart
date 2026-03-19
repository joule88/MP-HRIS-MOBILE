import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/atoms/fade_in_up.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Dokumen", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryDark,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryDark,
          tabs: const [
            Tab(text: "Slip Gaji"),
            Tab(text: "Surat & Dokumen"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSlipGajiList(),
          _buildSuratList(),
        ],
      ),
    );
  }

  Widget _buildSlipGajiList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: 5,
      itemBuilder: (context, index) {
        return FadeInUp(
          delayMs: index * 50,
          child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppTheme.primaryDark),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Slip Gaji - Juli 2025", style: AppTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text("Diterbitkan 25 Jul 2025", style: AppTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.download_rounded, color: AppTheme.textSecondary),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildSuratList() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: AppTheme.spacingMd),
          Text("Belum ada dokumen", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
