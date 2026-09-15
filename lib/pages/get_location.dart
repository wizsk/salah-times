import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salah_times/models/city.dart';
import 'package:salah_times/pages/salah_times_page.dart';
import 'package:salah_times/services/app_conf.dart';
import 'package:salah_times/services/city_service.dart';
import 'package:salah_times/utils/utils.dart';
import 'package:salah_times/widgets/dialouges.dart';

// enum _PickerMode { search, manual }

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, required this.isPopup});

  final bool isPopup;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();

    CityService.load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
  }

  bool _finished = false;
  void _onFinish() {
    // final msg = AppConf.locTry != null
    //     ? 'Location saved: ${AppConf.loc.city}'
    //     : 'Could not save Locaton';

    // ToastService.show(msg);

    if (!mounted) return;

    if (_finished) return;
    _finished = true;

    if (widget.isPopup) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalahTimesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Location'), centerTitle: false),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _CitySearchTab(onFinish: _onFinish),
          _GpsTab(onFinish: _onFinish),
          _ManualEntryTab(onFinish: _onFinish),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'GPS'),
          NavigationDestination(
            icon: Icon(Icons.edit_location_alt_rounded),
            label: 'Manual',
          ),
        ],
      ),
    );
  }
}

class _CitySearchTab extends StatefulWidget {
  const _CitySearchTab({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_CitySearchTab> createState() => _CitySearchTabState();
}

class _CitySearchTabState extends State<_CitySearchTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = TextEditingController();
  // Timer? _debounce;
  List<City> _results = [];
  bool _loading = false;
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) async {
    // _debounce?.cancel();
    setState(() => _query = query);

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    // _debounce = Timer(const Duration(milliseconds: 100), () async {
    final results = await CityService.search(query.trim());
    if (!mounted || query != _query) return;
    setState(() {
      _results = results;
      _loading = false;
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: maxContentWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: SearchBar(
                controller: _controller,
                onChanged: _onChanged,
                hintText: 'Search for a city…',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    ),
                ],
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  scheme.surfaceContainerHigh,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            Expanded(child: _buildBody(scheme, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme scheme, TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_query.trim().isEmpty) {
      return _EmptyState(
        icon: Icons.travel_explore_rounded,
        message: 'Start typing to find your city',
        scheme: scheme,
        textTheme: textTheme,
      );
    }

    if (_results.isEmpty) {
      return _EmptyState(
        icon: Icons.location_off_rounded,
        message: 'No cities found for "$_query"',
        scheme: scheme,
        textTheme: textTheme,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final city = _results[index];
        return _CityTile(
          city: city,
          onTap: () async {
            await AppConf.saveLoc(city.toPrayerLocation());
            widget.onFinish();
          },
        );
      },
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.location_city_rounded,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.cityAscii,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city.country,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Manual entry tab
// ─────────────────────────────────────────────────────────────

class _ManualEntryTab extends StatefulWidget {
  const _ManualEntryTab({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_ManualEntryTab> createState() => _ManualEntryTabState();
}

class _ManualEntryTabState extends State<_ManualEntryTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  Timer? _debounce;
  bool _resolving = false;
  String? _resolvedLabel;
  bool _resolvedIsNear = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _debounce?.cancel();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  String? _validateLat(String? value) {
    if (value == null || value.isEmpty) return null;

    final v = double.tryParse(value.trim());
    if (v == null) return 'Enter a valid number';
    if (v < -90 || v > 90) return 'Must be between -90 and 90';
    return null;
  }

  String? _validateLng(String? value) {
    if (value == null || value.isEmpty) return null;

    final v = double.tryParse(value.trim());
    if (v == null) return 'Enter a valid number';
    if (v < -180 || v > 180) return 'Must be between -180 and 180';
    return null;
  }

  void _onFieldChanged(String _) {
    setState(() => _resolvedLabel = null);
    _debounce?.cancel();

    if (!_formKey.currentState!.validate() ||
        _lngController.text.trim().isEmpty ||
        _latController.text.trim().isEmpty) {
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 200), _resolveNearest);
  }

  Future<void> _resolveNearest() async {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat == null || lng == null) return;

    setState(() => _resolving = true);

    final result = await CityService.nearestCity(lat, lng);
    if (!mounted) return;
    setState(() {
      _resolving = false;
      _resolvedLabel = result.label;
      _resolvedIsNear = result.isNear;
    });
  }

  void _confirm() async {
    if (!_formKey.currentState!.validate() ||
        _lngController.text.trim().isEmpty ||
        _latController.text.trim().isEmpty) {
      return;
    }

    final lat = double.parse(_latController.text.trim());
    final lng = double.parse(_lngController.text.trim());

    var p = PrayerLocation(lat, lng, '');
    final result = await CityService.nearestCity(p.lat, p.lng);
    p = p.copyWith(city: result.label);

    await AppConf.saveLoc(p);
    widget.onFinish();
  }

  InputDecoration _fieldDecoration(
    ColorScheme scheme, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: scheme.onSecondaryContainer.withAlpha(150)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: ConstrainedBox(
        constraints: maxContentWidth,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your coordinates and we\'ll match them to the nearest known city for accurate prayer times.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _latController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: _fieldDecoration(
                    scheme,
                    label: 'Latitude',
                    hint: 'e.g. 23.8103',
                  ),
                  validator: _validateLat,
                  onChanged: _onFieldChanged,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lngController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: _fieldDecoration(
                    scheme,
                    label: 'Longitude',
                    hint: 'e.g. 90.4125',
                  ),
                  validator: _validateLng,
                  onChanged: _onFieldChanged,
                ),
                const SizedBox(height: 16),
                if (_resolving || _resolvedLabel != null) ...[
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: _resolving
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Resolving…'),
                              ],
                            ),
                          )
                        : _resolvedLabel != null
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _resolvedIsNear
                                      ? Icons.check_circle_rounded
                                      : Icons.info_rounded,
                                  size: 20,
                                  color: scheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _resolvedIsNear
                                        ? 'Matched: $_resolvedLabel'
                                        : 'Closest match: $_resolvedLabel',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton(
                  onPressed: _resolvedLabel == null ? null : _confirm,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Use this location'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.scheme,
    required this.textTheme,
  });

  final IconData icon;
  final String message;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GpsTab extends StatefulWidget {
  const _GpsTab({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_GpsTab> createState() => _GpsTabState();
}

class _GpsTabState extends State<_GpsTab> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  bool _locating = false;
  String? _error;
  bool _cancelled = false;

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _detect() async {
    if (_locating) return;

    setState(() {
      _locating = true;
      _error = null;
      _cancelled = false;
    });

    try {
      final serviceEnabled = await _geolocatorPlatform
          .isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locating = false;
          _error =
              'Location services are disabled. Enable them in device settings';
        });
        _geolocatorPlatform.openLocationSettings();
        return;
      }

      LocationPermission perm = await _geolocatorPlatform.checkPermission();
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _locating = false;
          _error =
              'Permission permanently denied. Open app settings to allow it.';
        });

        if (!mounted) return;
        final res = await showConfirmDialog(
          context,
          'Permission Required',
          message: 'Location permission is permanently denied.\nOpen App Settings to grant access.',
          confirmText: 'Open',
          constraints: true,
        );

        if (res == true) {
          _geolocatorPlatform.openAppSettings();
        }
        return;
      }

      if (perm == LocationPermission.denied) {
        perm = await _geolocatorPlatform.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() {
            _locating = false;
            _error = 'Permission denied.';
          });
          return;
        }
      }

      final pos = await _geolocatorPlatform.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final lat = pos.latitude;
      final lng = pos.longitude;
      final city = await CityService.nearestCity(pos.latitude, pos.longitude);

      pd('got gps location: >>--------- $lat,$lng -- city: ${city.label}');

      if (_cancelled || !mounted) return;
      await AppConf.saveLoc(PrayerLocation(lat, lng, city.label));
      widget.onFinish();
    } catch (e, t) {
      setState(() {
        _locating = false;
        _error = 'Could not get location: $e';
      });

      pd(t.toString());
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final child = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.my_location_rounded, color: cs.primary, size: 38),
          ),
          const SizedBox(height: 20),
          Text(
            'Use GPS Location',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically detect your current location.\nApproximate location is supported.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.secondary, height: 1.5),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            // constraints: BoxConstraints(minWidth: 300),
            child: ElevatedButton.icon(
              onPressed: _detect,
              icon: _locating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onSecondary,
                      ),
                    )
                  : const Icon(Icons.gps_fixed_rounded),
              label: Text(
                _locating ? 'Getting location…' : 'Detect My Location',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Center(
      child: ConstrainedBox(constraints: maxContentWidth, child: child),
    );
  }
}
