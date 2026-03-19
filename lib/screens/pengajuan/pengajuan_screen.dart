import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/pengajuan_provider.dart';
import '../../widgets/molecules/menu_card.dart';
import '../../widgets/molecules/pengajuan_item_card.dart';
import '../../widgets/organisms/list_shimmer.dart';
import '../../widgets/organisms/pengajuan_detail_sheet.dart';
import '../../widgets/atoms/fade_in_up.dart';

class PengajuanScreen extends StatefulWidget {
  const PengajuanScreen({Key? key}) : super(key: key);

  @override
  State<PengajuanScreen> createState() => _PengajuanScreenState();
}

class _PengajuanScreenState extends State<PengajuanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        context.read<PengajuanProvider>().setTabIndex(_tabController.index);
      }
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().setTabIndex(1);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PengajuanProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Pengajuan", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchPengajuan();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: MenuCard(
                        title: "Cuti / Time Off",
                        subtitle: "Buat Pengajuan Cuti Tahunan",
                        icon: Icons.beach_access_rounded,
                        backgroundColor: AppTheme.badgeCutiBg,
                        iconColor: AppTheme.badgeCutiText,
                        onTap: () => Navigator.pushNamed(context, '/pengajuan/cuti'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 120,
                            child: MenuCard(
                              title: "Sakit",
                              subtitle: "Izin Sakit",
                              icon: Icons.local_hospital_rounded,
                              backgroundColor: AppTheme.badgeSakitBg,
                              iconColor: AppTheme.badgeSakitText,
                              onTap: () => Navigator.pushNamed(context, '/pengajuan/sakit'),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: SizedBox(
                            height: 120,
                            child: MenuCard(
                              title: "Izin",
                              subtitle: "Keperluan Lain",
                              icon: Icons.event_busy_rounded,
                              backgroundColor: AppTheme.badgeIzinBg,
                              iconColor: AppTheme.badgeIzinText,
                              onTap: () => Navigator.pushNamed(context, '/pengajuan/izin'),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Expanded(
                          child: SizedBox(
                            height: 120,
                            child: MenuCard(
                              title: "Lembur",
                              subtitle: "Overtime",
                              icon: Icons.timer_rounded,
                              backgroundColor: AppTheme.badgeLemburBg,
                              iconColor: AppTheme.badgeLemburText,
                              onTap: () => Navigator.pushNamed(context, '/pengajuan/lembur'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          context,
                          label: "Approved",
                          index: 0,
                          isSelected: _tabController.index == 0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTabButton(
                          context,
                          label: "Pending",
                          index: 1,
                          isSelected: _tabController.index == 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTabButton(
                          context,
                          label: "Rejected",
                          index: 2,
                          isSelected: _tabController.index == 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              provider.isLoading
                ? const SizedBox(
                    height: 300,
                    child: ListShimmer(itemCount: 4),
                  )
                : provider.listPengajuan.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 56, color: AppTheme.textTertiary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _tabController.index == 0
                                ? "Belum ada pengajuan disetujui"
                                : _tabController.index == 1
                                    ? "Belum ada pengajuan pending"
                                    : "Tidak ada pengajuan ditolak",
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Pengajuan yang sesuai akan muncul di sini",
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      itemCount: provider.listPengajuan.length,
                      itemBuilder: (context, index) {
                        final pengajuan = provider.listPengajuan[index];
                        return FadeInUp(
                          delayMs: index * 50,
                          child: PengajuanItemCard(
                            pengajuan: pengajuan,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                barrierColor: Colors.black.withValues(alpha: 0.1),
                                backgroundColor: Colors.transparent,
                                builder: (context) => PengajuanDetailSheet(pengajuan: pengajuan),
                              );
                            },
                          ),
                        );
                      },
                    ),
              SizedBox(height: kBottomNavigationBarHeight + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, {
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        context.read<PengajuanProvider>().setTabIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
