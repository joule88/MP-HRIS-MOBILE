import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/atoms/fade_in_up.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Notifikasi", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: () => context.read<NotificationProvider>().fetchNotifications(),
          )
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Text(provider.errorMessage!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.statusRed)),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: AppTheme.textTertiary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada notifikasi",
                      style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Semua pengumuman terbaru akan muncul di sini.",
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingMd),
              itemBuilder: (context, index) {
                final item = provider.notifications[index];
                return FadeInUp(
                  delayMs: index * 50,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: AppTheme.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTheme.labelLarge,
                                  ),
                                  Text(
                                    item.date,
                                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppTheme.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              item.jabatan,
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
