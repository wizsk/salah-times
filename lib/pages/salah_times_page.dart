import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salah_times/models/prayer_day.dart';
import 'package:salah_times/models/prayer_time.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/services/prayer.dart';
import 'package:salah_times/theme/app_theme.dart';
import 'package:salah_times/utils/open_location_change_page.dart';
import 'package:salah_times/utils/theme_selector.dart';
import 'package:salah_times/utils/utils.dart';
import 'package:salah_times/widgets/aux_time_row.dart';
import 'package:salah_times/widgets/dialouges.dart';
import 'package:salah_times/widgets/prayer_hero_card.dart';
import 'package:salah_times/widgets/prayer_list_card.dart';
import 'package:salah_times/widgets/prayer_modifers.dart';
import 'package:salah_times/widgets/settings.dart';

const int cooloff = 15;

const maxContentWidth = BoxConstraints(maxWidth: 640);
const int _animatePageMin = 20;

class SalahTimesPage extends StatefulWidget {
  const SalahTimesPage({super.key});

  @override
  State<SalahTimesPage> createState() => _SalahTimesPageState();
}

class _SalahTimesPageState extends State<SalahTimesPage>
    with WidgetsBindingObserver {
  // bool _inited = false;

  Timer? _timer;
  static const String _cityNameLoading = 'LOADING...';

  String _cityName = _cityNameLoading;

  // late List<PrayerDay> _paryerTimes;

  static int _salahTimesPageId = 0;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _initialPageIdx);

    if (kDebugMode) {
      pd('_salahTimesPageId -- #$_salahTimesPageId');
      _salahTimesPageId++;
    }

    __init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();

    try {
      _timer?.cancel();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  // int _hour = 21;
  DateTime _now() {
    final t = DateTime.now(); //.copyWith(hour: _hour);
    return t;
  }

  Future<void> __init() async {
    try {
      await AppConf.load();
      if (!AppConf.hasLoc) {
        if (mounted) showLocationProvidorScreen(context, false);
        return;
      }

      _cityName = AppConf.loc.city;
      if (mounted) {
        setState(() {});
      }

      final now = DateUtils.dateOnly(_now());
      PDS.getData(now.month, now.year, () {
        _rebuild();

        if (now.day >= 20) {
          Timer(const Duration(seconds: 4), () {
            Prayer.fetchNextMonthIfNeeded(now.year, now.month);
          });
        }
      }, _onErr);

      _timer ??= Timer.periodic(const Duration(seconds: cooloff), (_) {
        _rebuild();
      });
    } catch (err) {
      _onErr(err.toString());
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _onErr(String err) async {
    if (!mounted) return;
    final res = await showConfirmDialog(
      context,
      'Error',
      constraints: true,
      message:
          'Something went terribly wrong\n'
          'You can try changing location, that might fix the issue\n'
          'Error: $err',
      confirmText: 'Change',
      cancelText: 'Exit',
    );

    if (res == true && mounted) {
      showLocationProvidorScreen(context, false);
      return;
    }
    if (!kDebugMode) SystemNavigator.pop();
  }

  Future<void> _settings(BuildContext context) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: maxContentWidth,
      builder: (context) {
        return SingleChildScrollView(
          padding: scrollPaddingBottmSheet(context),
          child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Navigation
              const ThemeSwicher(),

              /// Main actions
              SettingsSectionSurface(
                children: [
                  ReaderSelectionTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    subtitle: 'Current: ${AppConf.locTry?.city ?? '...'}',
                    value: 'location',
                  ),
                  ReaderSelectionTile(
                    icon: Icons.calculate_outlined,
                    title: 'Calculation Method',
                    subtitle: 'Using: ${AppConf.method.name}',
                    value: 'method',
                  ),
                  ReaderSelectionTile(
                    icon: Icons.school_outlined,
                    title: 'Calculation School',
                    subtitle: 'Using: ${AppConf.school.name}',
                    value: 'school',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted) return;
    switch (result) {
      case 'location':
        final pre = AppConf.loc.copyWith();
        await showLocationProvidorScreen(context);

        if (pre != AppConf.loc && mounted) {
          setState(() {
            PDS.clear();
            _cityName = AppConf.loc.city;
          });
        }
        break;

      case 'method':
        await showPrayerMethodPicker(context);
        if (mounted) setState(() {});
        break;

      case 'school':
        await showPrayerSchoolPicker(context);
        if (mounted) setState(() {});
        break;
    }
  }

  bool get _showingToday => _pageIdx == _initialPageIdx;

  static const int _initialPageIdx = 1200;
  int _pageIdx = _initialPageIdx;

  DateTime _dateForPage(int page) {
    final offset = page - _initialPageIdx;
    final now = DateUtils.dateOnly(_now());
    return DateTime(now.year, now.month, now.day + offset);
  }

  @override
  Widget build(BuildContext context) {
    // final body = _singleColumn(context);

    final cs = Theme.of(context).colorScheme;

    final pb = PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _pageIdx = page;
        });
      },
      itemBuilder: (context, page) =>
          _singleColumn(context, _dateForPage(page), page == _initialPageIdx),
    );

    final stack = Stack(
      children: [
        pb,

        Align(
          alignment: AlignmentGeometry.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.25),
                    blurRadius: 18,
                    // offset: const Offset(0, 8),
                  ),
                ],
              ),
              // clipBehavior: Clip.antiAlias,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      _pageAnimateTo(_pageIdx - 1);
                    },
                  ),
                  if (!_showingToday)
                    IconButton(
                      icon: Icon(Icons.home),
                      onPressed: () {
                        final diff = (_initialPageIdx - _pageIdx).abs();
                        if (diff > _animatePageMin) {
                          _pageController.jumpToPage(_initialPageIdx);
                        } else {
                          _pageAnimateTo(_initialPageIdx);
                        }
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.calendar_month),
                      onPressed: () async {
                        final today = DateUtils.dateOnly(_now());

                        const daysFB = _initialPageIdx;
                        final date = await showDatePicker(
                          context: context,
                          initialDate: today,
                          firstDate: today.subtract(Duration(days: daysFB)),
                          // lastDate: today.add(Duration(days: daysFB)),
                          lastDate: DateTime(9999, 12, 31),
                        );

                        if (date == null) return;
                        var days = DateUtils.dateOnly(date)
                            .difference(today)
                            .inDays;

                        // if (days > 0) days++;
                        days = _initialPageIdx + days;

                        final diff = (_pageIdx - days).abs();

                        if (diff > _animatePageMin) {
                          _pageController.jumpToPage(days);
                        } else {
                          _pageAnimateTo(days);
                        }
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {
                      _pageAnimateTo(_pageIdx + 1);
                    },
                  ),
                  //
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(child: stack),
    );
  }

  void _pageAnimateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _locationDate(PrayerDay? p, DateTime now) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // final hijri = HijriDateService.fromGregorian(now);

    final englishDate =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    var arabicDate = '';
    if (p != null) {
      arabicDate = p.hijri.day.isEmpty || p.hijri.monthEn.isEmpty
          ? ''
          : '${_weekdayAr(now.weekday)}،  ${p.hijri.day} ${p.hijri.monthEn} ${p.hijri.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 26, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _cityName,
                  style: textTheme.headlineMedium?.copyWith(
                    fontFamily: AppTheme.displayFont,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _settings(context),
                tooltip: 'Settings',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  englishDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (arabicDate.isNotEmpty)
                  Text(
                    arabicDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
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

  static const _weekdaysAr = [
    'Al-Ithnayn',
    'Ath-Thulatha',
    "Al-Arbi'a",
    'Al-Khamis',
    "Al-Jumu'a",
    'As-Sabt',
    'Al-Ahad',
  ];

  String _weekdayAr(int d) => _weekdaysAr[d - 1];

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // static const _months = [
  //   'Jan',
  //   'Feb',
  //   'Mar',
  //   'Apr',
  //   'May',
  //   'Jun',
  //   'Jul',
  //   'Aug',
  //   'Sep',
  //   'Oct',
  //   'Nov',
  //   'Dec',
  // ];

  String _weekday(int d) => _weekdays[d - 1];
  String _month(int m) => _months[m - 1];

  Widget _singleColumn(BuildContext context, DateTime t, bool today) {
    NextPrayerInfo? info;
    PrayerDay? prayer;

    List<Widget> whenInited;

    final d = !AppConf.hasLoc
        ? PDS.emtpy
        : PDS.getData(t.month, t.year, _rebuild, _onErr);

    if (d.hasVal) {
      prayer = d.prayers![t.day - 1];
      info = today ? computeNextPrayer(prayer, _now()) : null;

      whenInited = [
        if (info != null && info.next != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PrayerHeroCard(info: info),
          ),
          const SizedBox(height: 22),
        ], //else
        // const SizedBox(height: 8),
        // _sectionLabel("Salah times"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PrayerListCard(
            prayer: prayer,
            next: info?.next?.p,
            curr: info?.curr?.p,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AuxTimeRow(items: prayer),
        ),
      ];
    } else {
      whenInited = const [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 18,
                  children: [
                    CircularProgressIndicator(),
                    Text(
                      'Loading...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: AppTheme.displayFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ];
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _topBar(),
        const SizedBox(height: 18),
        _locationDate(prayer, t),
        ...whenInited,
      ],
    );

    final child = Center(
      child: ConstrainedBox(constraints: maxContentWidth, child: content),
    );

    if (d.noVal) {
      return child;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 168),
      child: child,
    );
  }
}
