import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:salah_times/utils.dart';
import 'package:provider/provider.dart';

import '../models/prayer_day.dart';
import '../providers/prayer_provider.dart';
import '../widgets/prayer_card.dart';
import 'location_setup_screen.dart';

const _arabicDayName = {
  'Monday': 'Al-Ithnayn',
  'Tuesday': 'Ath-Thulatha',
  'Wednesday': "Al-Arbi'a",
  'Thursday': 'Al-Khamis',
  'Friday': "Al-Jumu'a",
  'Saturday': 'As-Sabt',
  'Sunday': 'Al-Ahad',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  static const int _initialPage = 10000;
  int _currentPage = _initialPage;
  // DateTime _selectedDate = DateTime.now();

  Timer? _ticker;
  String _nextPrayerName = '';
  Duration _timeToNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAdjacentMonths();
      _updateCountdown();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  void _updateCountdown() {
    final provider = context.read<PrayerProvider>();
    final today = DateTime.now();
    final prayerDay = provider.getPrayerDayForDate(today);
    if (prayerDay == null) return;

    final prayers = _getPrayerEntries(prayerDay)
        .where((e) => e.isPrayer)
        .toList();

    final nowSecs = today.hour * 3600 + today.minute * 60 + today.second;

    for (final p in prayers) {
      final pSecs = _toSeconds(p.time);
      if (pSecs > nowSecs) {
        setState(() {
          _nextPrayerName = p.name;
          _timeToNextPrayer = Duration(seconds: pSecs - nowSecs);
        });
        return;
      }
    }

    // Past Isha — next is Fajr tomorrow
    final fajrSecs = _toSeconds(prayers.first.time);
    setState(() {
      _nextPrayerName = prayers.first.name;
      _timeToNextPrayer = Duration(seconds: (86400 - nowSecs) + fajrSecs);
    });
  }

  int _toSeconds(String hhmm) {
    try {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 3600 + int.parse(p[1]) * 60;
    } catch (_) {
      return 0;
    }
  }

  // ── Page helpers ──────────────────────────────────────────────────────────

  DateTime _dateForPage(int page) {
    final offset = page - _initialPage;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + offset);
  }

  void _prefetchAdjacentMonths() {
    final provider = context.read<PrayerProvider>();
    final now = DateTime.now();
    for (final delta in [-1, 0, 1]) {
      final d = DateTime(now.year, now.month + delta);
      provider.fetchMonthIfNeeded(d.year, d.month);
    }
  }

  bool get _isOnToday => _currentPage == _initialPage;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final paddTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D1B2A)
          : const Color(0xFFF0F4FA),
      body: SafeArea(
        top: false,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
              // _selectedDate = _dateForPage(page);
            });
            context.read<PrayerProvider>().fetchMonthIfNeeded(
              _dateForPage(page).year,
              _dateForPage(page).month,
            );
          },
          itemBuilder: (_, page) =>
              _buildPage(provider, _dateForPage(page), isDark, paddTop),
        ),
      ),
      floatingActionButton: _isOnToday
          ? null
          : FloatingActionButton.small(
              onPressed: () => _pageController.animateToPage(
                _initialPage,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black87,
              tooltip: 'Go to today',
              child: const Icon(Icons.today_rounded),
            ),
    );
  }

  // ── Page ──────────────────────────────────────────────────────────────────

  Widget _buildPage(
    PrayerProvider provider,
    DateTime date,
    bool isDark,
    double topPad,
  ) {
    final prayerDay = provider.getPrayerDayForDate(date);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(provider, prayerDay, date, isDark, topPad),
        ),
        _buildContentSliver(provider, prayerDay, date, isDark),
        const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
      ],
    );
  }

  // ── Content sliver ────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildContentSliver(
    PrayerProvider provider,
    PrayerDay? prayerDay,
    DateTime date,
    bool isDark,
  ) {
    if (provider.isLoading && prayerDay == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF3A7BD5)),
          ),
        ),
      );
    }

    if (provider.error != null && prayerDay == null) {
      return SliverToBoxAdapter(child: _buildErrorView(provider, isDark));
    }

    if (prayerDay == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF3A7BD5)),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: _buildPrayerContent(prayerDay, date, isDark),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    PrayerProvider provider,
    PrayerDay? prayerDay,
    DateTime date,
    bool isDark,
    double topPad,
  ) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D1B2A), const Color(0xFF1B2A4A)]
              : [const Color(0xFF3A7BD5), const Color(0xFF5A9FE8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 45),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10 + topPad, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Action bar (icons only, slim) ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ThemeToggleButton(
                  themeMode: provider.themeMode,
                  onTap: provider.cycleTheme,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LocationSetupScreen(isEditing: true),
                    ),
                  ),
                  tooltip: 'Change location',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      'Refresh',
                      message: 'Refresh prayer time datas',
                      confirmText: 'Refresh',
                    );
                    if (confirm != true) return;
                    await provider.refreshCurrentMonth();
                  },
                  tooltip: 'Refresh',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            // ── City name (headline) ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  provider.cityLabel.isNotEmpty
                      ? provider.cityLabel
                      : 'Prayer Times',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Date navigator ────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(child: _buildDateBlock(prayerDay, date, isToday)),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            // ── Countdown (today only) ────────────────────────────────
            if (isToday && _nextPrayerName.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildCountdownBar(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Date block ────────────────────────────────────────────────────────────

  Widget _buildDateBlock(PrayerDay? prayerDay, DateTime date, bool isToday) {
    final engDay = DateFormat('EEEE').format(date);
    final arabicDay = _arabicDayName[engDay] ?? engDay;

    final hijriLine = prayerDay != null
        ? '${prayerDay.hijri.day} ${prayerDay.hijri.monthEn} '
              '${prayerDay.hijri.year} AH'
              '${prayerDay.hijri.monthAr.isNotEmpty ? '  •  ${prayerDay.hijri.monthAr}' : ''}'
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gregorian date — biggest element
        Text(
          DateFormat('d MMMM yyyy').format(date),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Day name | Arabic name + Today badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '$engDay  |  $arabicDay',
                style: TextStyle(
                  color: Colors.white.withAlpha(210),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 214, 79),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(168, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Hijri date
        if (hijriLine != null) ...[
          const SizedBox(height: 6),
          Text(
            hijriLine,
            style: TextStyle(
              color: Colors.white.withAlpha(170),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ── Countdown bar ─────────────────────────────────────────────────────────

  Widget _buildCountdownBar() {
    final h = _timeToNextPrayer.inHours;
    final m = _timeToNextPrayer.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final s = _timeToNextPrayer.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final countdown = h > 0 ? '${h}h ${m}m ${s}s' : '${m}m ${s}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white70, size: 17),
          const SizedBox(width: 8),
          Text(
            'Next: $_nextPrayerName',
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            countdown,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ── Error view ────────────────────────────────────────────────────────────

  Widget _buildErrorView(PrayerProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.wifi_off_rounded,
            size: 56,
            color: isDark
                ? Colors.white.withAlpha(77)
                : Colors.black.withAlpha(66),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load prayer times',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withAlpha(138)
                  : Colors.black.withAlpha(115),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withAlpha(97)
                  : Colors.black.withAlpha(97),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: provider.refreshCurrentMonth,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A7BD5),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Prayer content ────────────────────────────────────────────────────────

  Widget _buildPrayerContent(PrayerDay day, DateTime date, bool isDark) {
    final entries = _getPrayerEntries(day);
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    String? currentPrayer;
    String? nextPrayer;

    if (isToday) {
      final prayerOnly = entries.where((e) => e.isPrayer).toList();
      currentPrayer = _getCurrentPrayer(prayerOnly, now);
      nextPrayer = _getNextPrayer(prayerOnly, now);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          ...entries.map((e) {
            final isCurrent = isToday && e.isPrayer && e.name == currentPrayer;
            final isNext =
                isToday && e.isPrayer && e.name == nextPrayer && !isCurrent;
            return PrayerCard(
              name: e.name,
              time: e.time,
              icon: _iconFor(e.name),
              accentColor: _colorFor(e.name),
              isCurrent: isCurrent,
              isNext: isNext,
              isPrayer: e.isPrayer,
            );
          }),
          const SizedBox(height: 10),
          _buildExtraTimesCard(day, isDark),
        ],
      ),
    );
  }

  // ── Extra times ───────────────────────────────────────────────────────────

  Widget _buildExtraTimesCard(PrayerDay day, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 77 : 15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADDITIONAL TIMES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white38 : Colors.black38,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _extraRow('Imsak', day.timings.imsak, isDark),
          const Divider(height: 16),
          _extraRow('Midnight', day.timings.midnight, isDark),
        ],
      ),
    );
  }

  Widget _extraRow(String name, String time, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          _fmt(time),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<_PrayerEntry> _getPrayerEntries(PrayerDay day) => [
    _PrayerEntry('Fajr', day.timings.fajr, isPrayer: true),
    _PrayerEntry('Sunrise', day.timings.sunrise, isPrayer: false),
    _PrayerEntry('Dhuhr', day.timings.dhuhr, isPrayer: true),
    _PrayerEntry('Asr', day.timings.asr, isPrayer: true),
    _PrayerEntry('Maghrib', day.timings.maghrib, isPrayer: true),
    _PrayerEntry('Isha', day.timings.isha, isPrayer: true),
  ];

  int _toMinutes(String time) {
    try {
      final p = time.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    } catch (_) {
      return 0;
    }
  }

  String? _getCurrentPrayer(List<_PrayerEntry> prayers, TimeOfDay now) {
    final nowMin = now.hour * 60 + now.minute;
    String? current;
    int cpTime = -1;
    for (final p in prayers) {
      final cp = _toMinutes(p.time);
      if (cp <= nowMin) {
        cpTime = cp;
        current = p.name;
      }
    }
    if (cpTime < 0) return null;
    if (nowMin - cpTime > 120) return null;
    return current;
  }

  String? _getNextPrayer(List<_PrayerEntry> prayers, TimeOfDay now) {
    final nowMin = now.hour * 60 + now.minute;
    for (final p in prayers) {
      if (_toMinutes(p.time) > nowMin) return p.name;
    }
    return null;
  }

  String _fmt(String t) {
    if (t.isEmpty) return '--:--';
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1];
      final ampm = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $ampm';
    } catch (_) {
      return t;
    }
  }

  IconData _iconFor(String name) => switch (name) {
    'Fajr' => Icons.wb_twilight_rounded,
    'Sunrise' => Icons.wb_sunny_rounded,
    'Dhuhr' => Icons.light_mode_rounded,
    'Asr' => Icons.wb_cloudy_rounded,
    'Maghrib' => Icons.nights_stay_outlined,
    'Isha' => Icons.nightlight_round,
    _ => Icons.access_time,
  };

  Color _colorFor(String name) => switch (name) {
    'Fajr' => const Color(0xFF5C7AEA),
    'Sunrise' => const Color(0xFFF5A623),
    'Dhuhr' => const Color(0xFFE8A838),
    'Asr' => const Color(0xFF3DAA73),
    'Maghrib' => const Color(0xFFE06B44),
    'Isha' => const Color(0xFF7B5EA7),
    _ => const Color(0xFF3A7BD5),
  };
}

// ── Data class ────────────────────────────────────────────────────────────

class _PrayerEntry {
  final String name;
  final String time;
  final bool isPrayer;
  const _PrayerEntry(this.name, this.time, {required this.isPrayer});
}

// ── Theme toggle button ───────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onTap;
  const _ThemeToggleButton({required this.themeMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, tooltip) = switch (themeMode) {
      ThemeMode.system => (Icons.brightness_auto_rounded, 'System theme'),
      ThemeMode.light => (Icons.light_mode_rounded, 'Light theme'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'Dark theme'),
    };
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 22),
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }
}
