import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/attendance_provider.dart';

/// Work location option for check-in.
class _WorkLocation {
  final String name;
  final LatLng coordinates;
  final bool isWfh;

  const _WorkLocation({
    required this.name,
    required this.coordinates,
    required this.isWfh,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WorkLocation &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({super.key});

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  static final List<_WorkLocation> _locations = [
    const _WorkLocation(
      name: 'PT Magna Solusi Indonesia',
      coordinates: LatLng(-6.224137078680758, 106.84200412694256),
      isWfh: false,
    ),
    const _WorkLocation(
      name: 'PT Kino Indonesia',
      coordinates: LatLng(-6.228541682594998, 106.65827765749832),
      isWfh: false,
    ),
    const _WorkLocation(
      name: 'Saint John Bungur',
      coordinates: LatLng(-6.167152555345517, 106.84188002492792),
      isWfh: false,
    ),
  ];

  _WorkLocation? _selectedLocation;
  File? _photo;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      setState(() => _isLoadingLocation = false);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. '
              'Please enable it in settings.',
            ),
          ),
        );
      }
      setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
  }

  /// Haversine distance in meters.
  double _distanceInMeters(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLng = _toRadians(b.longitude - a.longitude);
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final h =
        sinDLat * sinDLat +
        cos(_toRadians(a.latitude)) *
            cos(_toRadians(b.latitude)) *
            sinDLng *
            sinDLng;
    return 2 * earthRadius * asin(sqrt(h));
  }

  double _toRadians(double deg) => deg * pi / 180;

  bool get _isWithinRadius {
    if (_selectedLocation == null || _currentPosition == null) {
      return false;
    }
    if (_selectedLocation!.isWfh) return true;
    final userLatLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    return _distanceInMeters(userLatLng, _selectedLocation!.coordinates) <= 50;
  }

  bool get _canSubmit =>
      _selectedLocation != null && _photo != null && _isWithinRadius;

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera access is required to take a photo '
              'for check-in. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null) {
      setState(() => _photo = File(image.path));
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Simulate brief processing
    await Future<void>.delayed(const Duration(milliseconds: 500));

    ref
        .read(attendanceProvider.notifier)
        .checkIn(workLocation: _selectedLocation!.name);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check-in successful!')));
      Navigator.pop(context);
    }
  }

  List<_WorkLocation> get _allLocations {
    return List<_WorkLocation>.from(_locations);
  }

  @override
  Widget build(BuildContext context) {
    final locations = _allLocations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Work Location ──────────────────
                Text('Work Location', style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                ...locations.map(
                  (loc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedLocation = loc);
                        _mapController.move(loc.coordinates, 16);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _selectedLocation == loc
                              ? AppColors.accentBlue.withValues(alpha: 0.1)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedLocation == loc
                                ? AppColors.accentBlue
                                : AppColors.divider,
                            width: _selectedLocation == loc ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              loc.isWfh
                                  ? Icons.home_rounded
                                  : Icons.location_on_rounded,
                              color: _selectedLocation == loc
                                  ? AppColors.accentBlue
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _selectedLocation == loc
                                      ? AppColors.accentBlue
                                      : AppColors.textPrimary,
                                  fontWeight: _selectedLocation == loc
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (_selectedLocation == loc)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Radius status ──────────────────
                if (_selectedLocation != null && !_selectedLocation!.isWfh) ...[
                  const SizedBox(height: 8),
                  _RadiusStatus(
                    isWithin: _isWithinRadius,
                    distance: _currentPosition != null
                        ? _distanceInMeters(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            _selectedLocation!.coordinates,
                          )
                        : null,
                  ),
                ],

                // ── Map ────────────────────────────
                const SizedBox(height: 20),
                Text('Location Map', style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 220,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _selectedLocation?.coordinates ??
                            (_currentPosition != null
                                ? LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  )
                                : const LatLng(
                                    -6.224137078680758,
                                    106.84200412694256,
                                  )),
                        initialZoom: 16,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/'
                              '{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.msi.hris',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_selectedLocation != null)
                              Marker(
                                point: _selectedLocation!.coordinates,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 40,
                                ),
                              ),
                            if (_currentPosition != null)
                              Marker(
                                point: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                width: 20,
                                height: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.info,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_selectedLocation != null &&
                            !_selectedLocation!.isWfh)
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: _selectedLocation!.coordinates,
                                radius: 50,
                                useRadiusInMeter: true,
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.15,
                                ),
                                borderColor: AppColors.accentBlue,
                                borderStrokeWidth: 1.5,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Photo ──────────────────────────
                const SizedBox(height: 20),
                Text('Take a Photo', style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                if (_photo != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _photo!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _photo = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: _isWithinRadius ? _takePhoto : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: _isWithinRadius ? 1.0 : 0.4,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.divider,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.accentBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isWithinRadius
                                  ? 'Tap to take a photo'
                                  : 'Be within radius to take a photo',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Submit Button ──────────────────
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.divider,
                      disabledForegroundColor: AppColors.textHint,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Submit Check In'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

// ── Radius Status Widget ────────────────────────────────

class _RadiusStatus extends StatelessWidget {
  const _RadiusStatus({required this.isWithin, this.distance});

  final bool isWithin;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    final distText = distance != null
        ? '(${distance!.toStringAsFixed(0)} m away)'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isWithin
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isWithin ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 18,
            color: isWithin ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isWithin
                  ? 'You are within 50m radius'
                  : 'You are outside 50m radius $distText',
              style: AppTextStyles.bodySmall.copyWith(
                color: isWithin ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
