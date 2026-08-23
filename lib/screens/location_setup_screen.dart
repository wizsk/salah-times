import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../providers/prayer_provider.dart';
import '../services/city_service.dart';

class LocationSetupScreen extends StatefulWidget {
  final bool isEditing;
  const LocationSetupScreen({super.key, this.isEditing = false});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1B2A), const Color(0xFF1B2A4A)]
                : [const Color(0xFF3A7BD5), const Color(0xFF5A9FE8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopSection(isDark),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0D1B2A)
                        : const Color(0xFFF0F4FA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildTabBar(isDark),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _CitySearchTab(isEditing: widget.isEditing),
                            _GpsTab(isEditing: widget.isEditing),
                            _ManualTab(isEditing: widget.isEditing),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
      child: Column(
        children: [
          // Back button row when editing
          if (widget.isEditing)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Go back',
              ),
            )
          else
            const SizedBox(height: 8),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isEditing ? 'Update Location' : 'Assalamu Alaikum',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isEditing
                ? 'Change your city or coordinates'
                : 'Set your location for accurate prayer times',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(191)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2D45) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF3A7BD5),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'City Search'),
            Tab(text: 'GPS'),
            Tab(text: 'Manual'),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 1: City Search
// ══════════════════════════════════════════════════════════════════════════════

class _CitySearchTab extends StatefulWidget {
  final bool isEditing;
  const _CitySearchTab({required this.isEditing});

  @override
  State<_CitySearchTab> createState() => _CitySearchTabState();
}

class _CitySearchTabState extends State<_CitySearchTab> {
  final _searchController = TextEditingController();
  List<City> _results = [];
  bool _searching = false;
  bool _saving = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _searching = true);
      final r = await CityService.search(q);
      if (mounted) {
        setState(() {
          _results = r;
          _searching = false;
        });
      }
    });
  }

  Future<void> _selectCity(City city) async {
    setState(() => _saving = true);
    // Use the city name as the explicit label so nearest-city lookup is skipped
    await context.read<PrayerProvider>().saveLocation(
      city.lat,
      city.lng,
      explicitLabel: city.city,
    );
    if (mounted) {
      if (widget.isEditing) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: !widget.isEditing,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search city name or country…',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF3A7BD5),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white38 : Colors.black38,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _results = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1E2D45) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF3A7BD5),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Results list
          Expanded(
            child: _saving
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3A7BD5)),
                  )
                : _searching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3A7BD5)),
                  )
                : _results.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (_, i) => _buildCityTile(_results[i], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityTile(City city, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D45) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3A7BD5).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFF3A7BD5),
              size: 20,
            ),
          ),
          title: Text(
            city.city,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            city.country,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          trailing: Text(
            '${city.lat.toStringAsFixed(2)}, ${city.lng.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          onTap: () => _selectCity(city),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 52,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'Type a city name to search',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Text(
        'No cities found for "${_searchController.text}"',
        style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 2: GPS
// ══════════════════════════════════════════════════════════════════════════════

class _GpsTab extends StatefulWidget {
  final bool isEditing;
  const _GpsTab({required this.isEditing});

  @override
  State<_GpsTab> createState() => _GpsTabState();
}

class _GpsTabState extends State<_GpsTab> {
  bool _locating = false;
  bool _saving = false;
  String? _error;
  String? _detectedCoords;
  bool _cancelled = false;

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _detect() async {
    setState(() {
      _locating = true;
      _error = null;
      _detectedCoords = null;
      _cancelled = false;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(
          () => _error =
              'Location services are disabled. Enable them in device settings.',
        );
        Geolocator.openLocationSettings();
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.deniedForever) {
        setState(
          () => _error =
              'Permission permanently denied. Open app settings to allow it.',
        );
        _showOpenSettings();
        return;
      }
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          setState(() => _error = 'Permission denied.');
          return;
        }
        if (perm == LocationPermission.deniedForever) {
          setState(
            () => _error = 'Permission permanently denied. Open app settings.',
          );
          _showOpenSettings();
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 20),
        ),
      );

      setState(() {
        _detectedCoords =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      });

      if (_cancelled) return;
      // Save — nearest city label is resolved automatically
      setState(() {
        _locating = false;
        _saving = true;
      });
      await context.read<PrayerProvider>().saveLocation(
        pos.latitude,
        pos.longitude,
      );
      if (mounted && !_cancelled && widget.isEditing)
        Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Could not get location: $e');
    } finally {
      if (mounted)
        setState(() {
          _locating = false;
          _saving = false;
        });
    }
  }

  void _showOpenSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is permanently denied.\nOpen App Settings to grant access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3A7BD5).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Color(0xFF3A7BD5),
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Use GPS Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically detect your current location.\nApproximate location is supported.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
          ),
          if (_detectedCoords != null) ...[
            const SizedBox(height: 16),
            Text(
              _detectedCoords!,
              style: const TextStyle(
                color: Color(0xFF3A7BD5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
            child: ElevatedButton.icon(
              onPressed: (_locating || _saving) ? null : _detect,
              icon: _locating || _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.gps_fixed_rounded),
              label: Text(
                _locating
                    ? 'Getting location…'
                    : _saving
                    ? 'Saving…'
                    : 'Detect My Location',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A7BD5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (_locating || _saving) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _cancelled = true;
                  _locating = false;
                  _saving = false;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ),
          ] else if (widget.isEditing) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Back',
                style: TextStyle(color: Colors.white.withAlpha(179)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tab 3: Manual
// ══════════════════════════════════════════════════════════════════════════════

class _ManualTab extends StatefulWidget {
  final bool isEditing;
  const _ManualTab({required this.isEditing});

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final p = context.read<PrayerProvider>();
      _latController.text = p.latitude?.toStringAsFixed(6) ?? '';
      _lonController.text = p.longitude?.toStringAsFixed(6) ?? '';
      _onLatLanChnage("editing");
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  String _locationName = "...";
  Future<void> _onLatLanChnage(String? _) async {
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());

    if (lat == null || lon == null) {
      setState(() {
        _locationName = "...";
      });
    } else {
      final city = await CityService.nearestCity(lat, lon);
      _locationName = "${city.city.city}";
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final lat = double.parse(_latController.text.trim());
    final lon = double.parse(_lonController.text.trim());
    // No explicit label — nearest city will be resolved automatically
    await context.read<PrayerProvider>().saveLocation(lat, lon);
    if (mounted && widget.isEditing) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.mosque_rounded,

                    color: isDark ? Colors.lightBlue : const Color(0xFF3A7BD5),
                  ),
                  SizedBox(width: 6),
                  Text(
                    _locationName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark
                          ? Colors.lightBlue
                          : const Color(0xFF3A7BD5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _latController,
              label: 'Latitude',
              hint: 'e.g. 23.810800',
              icon: Icons.north_rounded,
              isDark: isDark,
              onChange: _onLatLanChnage,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _lonController,
              label: 'Longitude',
              hint: 'e.g. 90.412500',
              icon: Icons.east_rounded,
              isDark: isDark,
              onChange: _onLatLanChnage,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _showCoordTip,
                icon: Icon(
                  Icons.info_outline,
                  size: 15,
                  color: isDark ? Colors.lightBlue : const Color(0xFF3A7BD5),
                ),
                label: Text(
                  'How to find my coordinates?',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.lightBlue : const Color(0xFF3A7BD5),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: const Color(0xFFD4AF37)
                      .withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black54,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'Update Location'
                            : 'Get Prayer Times',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Function(String?) onChange,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
        return null;
      },
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.lightBlue : const Color(0xFF3A7BD5),
          size: 20,
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        filled: true,
        fillColor: isDark ? Colors.white.withAlpha(18) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A7BD5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  void _showCoordTip() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Find Your Coordinates'),
        content: const Text(
          'Open Google Maps and long-press on your location.\n'
          'The coordinates appear at the top of the screen.\n\n'
          'Latitude: north/south (e.g. 23.81)\n'
          'Longitude: east/west (e.g. 90.41)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
