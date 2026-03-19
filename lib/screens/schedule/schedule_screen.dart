import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/calendar_provider.dart';
import '../../models/schedule_model.dart';
import '../../widgets/organisms/schedule_shimmer.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      context.read<CalendarProvider>().fetchMonthlySchedule(now.month, now.year);
    });
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return AppTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Jadwal Kerja", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: () {
              context.read<CalendarProvider>().fetchMonthlySchedule(_focusedDay.month, _focusedDay.year);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Consumer<CalendarProvider>(
          builder: (context, provider, child) {
            
            if (provider.isLoading) {
              return const ScheduleShimmer();
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 50, color: AppTheme.statusRed.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      Text(
                        "Gagal memuat data",
                        style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => provider.fetchMonthlySchedule(_focusedDay.month, _focusedDay.year),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Coba Lagi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchMonthlySchedule(_focusedDay.month, _focusedDay.year),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                  Container(
                    margin: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: TableCalendar<ScheduleModel>(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: AppTheme.labelLarge.copyWith(fontSize: 16),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.primaryDark),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.primaryDark),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(color: AppTheme.primaryDark, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryDark, width: 2),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryDark, fontWeight: FontWeight.bold),
                        weekendTextStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.statusRed.withValues(alpha: 0.6)),
                        outsideDaysVisible: false,
                        markerDecoration: const BoxDecoration(color: AppTheme.primaryDark, shape: BoxShape.circle),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        weekendStyle: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppTheme.statusRed.withValues(alpha: 0.6)),
                      ),
            
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        provider.fetchMonthlySchedule(focusedDay.month, focusedDay.year);
                      },
            
                      eventLoader: (day) {
                        final dateKey = DateFormat('yyyy-MM-dd').format(day);
                        return provider.schedules.where((s) => s.tanggal == dateKey).toList();
                      },
            
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            final schedule = events.first; 
                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _parseColor(schedule.warnaKalender),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          final dateKey = DateFormat('yyyy-MM-dd').format(day);
                          final holidays = provider.schedules.where((s) => s.tanggal == dateKey && s.isHariLibur);
                          if (holidays.isNotEmpty) {
                            return Center(
                              child: Text(
                                '${day.day}',
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.statusRed, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
            
                  const SizedBox(height: AppTheme.spacingSm),
            
                  _buildDetailSection(provider),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );

          },
        ),
      ),
    );
  }

  Widget _buildDetailSection(CalendarProvider provider) {
    if (_selectedDay == null) return const SizedBox();

    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
    
    ScheduleModel? selectedSchedule;
    try {
      final found = provider.schedules.where((s) => s.tanggal == dateKey);
      if (found.isNotEmpty) selectedSchedule = found.first;
    } catch (e) {
      selectedSchedule = null;
    }

    if (selectedSchedule != null && selectedSchedule.isHariLibur) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppTheme.statusRed.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_selectedDay!),
                      style: AppTheme.labelLarge.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.statusRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      'Hari Libur',
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.statusRed, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: AppTheme.bgCard),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.statusRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, size: 32, color: AppTheme.statusRed.withValues(alpha: 0.6)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedSchedule.keteranganLibur ?? 'Hari Libur',
                            style: AppTheme.labelLarge.copyWith(color: AppTheme.statusRed),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tidak ada jadwal kerja pada hari ini',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedSchedule == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 40, color: AppTheme.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            Text("Tidak ada informasi jadwal", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary)),
          ],
        ),
      );
    }

    bool isCustom = selectedSchedule.statusPoin != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: isCustom
              ? [
                  BoxShadow(
                    color: AppTheme.statusOrange.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_selectedDay!),
                    style: AppTheme.labelLarge.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (isCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.statusOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      selectedSchedule.statusPoin!,
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.statusOrange, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
              ],
            ),
            Divider(height: 24, color: AppTheme.bgCard),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeInfo("Jam Masuk", selectedSchedule.jamMasuk, isCustom),
                Container(width: 1, height: 40, color: AppTheme.bgCard),
                _buildTimeInfo("Jam Pulang", selectedSchedule.jamPulang, isCustom),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(Icons.work_history_outlined, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Shift: ${selectedSchedule.shiftNama}", 
                            style: AppTheme.labelLarge.copyWith(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                        Text("Status Absen: ${selectedSchedule.statusPresensi ?? 'Belum Absen'}", 
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, bool highlight) {
    bool isModified = highlight && time.contains(":");
    
    return Column(
      children: [
        Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary)),
        const SizedBox(height: 6),
        Text(
          time,
          style: AppTheme.heading2.copyWith(
            fontSize: 22, 
            color: isModified ? AppTheme.statusOrange : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
