import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // KAABA COORDINATES
  // ============================================================

  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  // ============================================================
  // COMPASS STATE
  // ============================================================

  StreamSubscription<CompassEvent>? _compassSubscription;

  double? _heading;
  double? _qiblaBearing;
  double? _compassAccuracy;

  bool _hasCompassSensor = true;
  bool _isLoadingLocation = true;
  bool _isRefreshing = false;
  bool _isAligned = false;

  String _locationName = 'অবস্থান নির্ণয় করা হচ্ছে...';
  String _locationSubline = 'GPS অবস্থান অপেক্ষমাণ';

  String _sensorStatus = 'সেন্সর প্রস্তুত হচ্ছে';
  String _sensorStatusShort = 'প্রস্তুত';

  // ============================================================
  // SMOOTHING
  // ============================================================

  double? _smoothedHeading;

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _initialize();
  }

  Future<void> _initialize() async {
    _startCompass();
    await _loadLocation();
  }

  // ============================================================
  // COMPASS
  // ============================================================

  void _startCompass() {
    final events = FlutterCompass.events;

    if (events == null) {
      if (mounted) {
        setState(() {
          _hasCompassSensor = false;
          _sensorStatus = 'কম্পাস সেন্সর পাওয়া যায়নি';
          _sensorStatusShort = 'সেন্সর নেই';
        });
      }
      return;
    }

    _compassSubscription = events.listen(
      (CompassEvent event) {
        if (!mounted) return;

        final rawHeading = event.heading;
        final accuracy = event.accuracy;

        if (rawHeading == null) {
          setState(() {
            _hasCompassSensor = false;
            _sensorStatus = 'কম্পাস সেন্সর পাওয়া যাচ্ছে না';
            _sensorStatusShort = 'সেন্সর নেই';
          });
          return;
        }

        final normalizedHeading = _normalize(rawHeading);

        _smoothedHeading = _smoothAngle(
          _smoothedHeading,
          normalizedHeading,
          0.18,
        );

        final heading = _smoothedHeading ?? normalizedHeading;

        final qibla = _qiblaBearing;

        bool aligned = false;

        if (qibla != null) {
          final difference = _angularDifference(heading, qibla);
          aligned = difference <= 3.0;
        }

        setState(() {
          _heading = heading;
          _compassAccuracy = accuracy;
          _hasCompassSensor = true;
          _isAligned = aligned;

          if (accuracy == null) {
            _sensorStatus = 'কম্পাস সক্রিয়';
            _sensorStatusShort = 'সক্রিয়';
          } else if (accuracy >= 0 && accuracy <= 15) {
            _sensorStatus = 'উচ্চ নির্ভুলতা';
            _sensorStatusShort = 'উচ্চ';
          } else if (accuracy <= 35) {
            _sensorStatus = 'মাঝারি নির্ভুলতা';
            _sensorStatusShort = 'মাঝারি';
          } else {
            _sensorStatus = 'কম্পাস ক্যালিব্রেট করুন';
            _sensorStatusShort = 'ক্যালিব্রেট';
          }
        });
      },
      onError: (_) {
        if (!mounted) return;

        setState(() {
          _hasCompassSensor = false;
          _sensorStatus = 'কম্পাস সেন্সরে সমস্যা হয়েছে';
          _sensorStatusShort = 'ত্রুটি';
        });
      },
      cancelOnError: false,
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> _loadLocation({bool refresh = false}) async {
    if (refresh && mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationName = 'লোকেশন সার্ভিস বন্ধ';
          _locationSubline = 'Location চালু করে আবার চেষ্টা করুন';
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationName = 'লোকেশন অনুমতি প্রয়োজন';
          _locationSubline = 'Qibla direction নির্ণয়ের জন্য Location দিন';
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _isLoadingLocation = false;
          _locationName = 'লোকেশন অনুমতি বন্ধ';
          _locationSubline = 'Settings থেকে Location permission চালু করুন';
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final qibla = _calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );

      String locationName = 'বর্তমান অবস্থান';
      String locationSubline =
          '${position.latitude.toStringAsFixed(4)}°, '
          '${position.longitude.toStringAsFixed(4)}°';

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final parts = <String>[
            if ((place.locality ?? '').trim().isNotEmpty)
              place.locality!.trim(),
            if ((place.subAdministrativeArea ?? '').trim().isNotEmpty &&
                place.subAdministrativeArea!.trim() !=
                    (place.locality ?? '').trim())
              place.subAdministrativeArea!.trim(),
          ];

          if (parts.isNotEmpty) {
            locationName = parts.join(', ');
          } else if ((place.administrativeArea ?? '').trim().isNotEmpty) {
            locationName = place.administrativeArea!.trim();
          }

          final country = (place.country ?? '').trim();

          if (country.isNotEmpty) {
            locationSubline = country;
          } else {
            locationSubline =
                '${position.latitude.toStringAsFixed(4)}°, '
                '${position.longitude.toStringAsFixed(4)}°';
          }
        }
      } catch (_) {
        // Coordinates remain available even if reverse geocoding fails.
      }

      if (!mounted) return;

      setState(() {
        _qiblaBearing = qibla;
        _locationName = locationName;
        _locationSubline = locationSubline;
        _isLoadingLocation = false;
      });

      _updateAlignment();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _locationName = 'লোকেশন পাওয়া যায়নি';
        _locationSubline = 'আবার চেষ্টা করুন';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // ============================================================
  // QIBLA CALCULATION
  // Great-circle initial bearing to Kaaba.
  // ============================================================

  double _calculateQiblaBearing(double latitude, double longitude) {
    final phi1 = _degreesToRadians(latitude);
    final phi2 = _degreesToRadians(_kaabaLatitude);

    final deltaLambda = _degreesToRadians(_kaabaLongitude - longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);

    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);

    final bearing = _radiansToDegrees(theta);

    return _normalize(bearing);
  }

  // ============================================================
  // ANGLE HELPERS
  // ============================================================

  double _normalize(double value) {
    var result = value % 360;

    if (result < 0) {
      result += 360;
    }

    return result;
  }

  double _angularDifference(double a, double b) {
    final difference = (a - b).abs();

    return difference > 180 ? 360 - difference : difference;
  }

  double _smoothAngle(double? previous, double current, double factor) {
    if (previous == null) {
      return current;
    }

    final delta = ((current - previous + 540) % 360) - 180;

    return _normalize(previous + delta * factor);
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  // ============================================================
  // ALIGNMENT
  // ============================================================

  void _updateAlignment() {
    final heading = _heading;
    final qibla = _qiblaBearing;

    if (heading == null || qibla == null) {
      return;
    }

    final aligned = _angularDifference(heading, qibla) <= 3.0;

    if (aligned != _isAligned && mounted) {
      setState(() {
        _isAligned = aligned;
      });
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final background = theme.scaffoldBackgroundColor;

    final surface = theme.cardColor;

    final primary = AppColors.seaBlue;

    final textPrimary =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);

    final textSecondary =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68) ??
        (isDark ? Colors.white70 : Colors.black54);

    final heading = _heading ?? 0.0;

    final qibla = _qiblaBearing;

    final qiblaDifference =
        qibla == null ? null : _angularDifference(heading, qibla);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'কিবলা কম্পাস',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            tooltip: 'কম্পাস নির্দেশনা',
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary.withValues(alpha: 0.18)),
                color: primary.withValues(alpha: 0.07),
              ),
              child: Icon(Icons.info_outline_rounded, color: primary, size: 19),
            ),
            onPressed: () {
              _showCompassGuide(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadLocation(refresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: [
              _buildLocationCard(
                context: context,
                surface: surface,
                primary: primary,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: 14),

              _buildCompassCard(
                context: context,
                primary: primary,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                heading: heading,
                qibla: qibla,
                qiblaDifference: qiblaDifference,
              ),

              const SizedBox(height: 14),

              _buildStatusCard(
                context: context,
                primary: primary,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                qiblaDifference: qiblaDifference,
              ),

              const SizedBox(height: 14),

              _buildInstructionCard(
                context: context,
                primary: primary,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION CARD
  // ============================================================

  Widget _buildLocationCard({
    required BuildContext context,
    required Color surface,
    required Color primary,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.10),
            ),
            child: Icon(Icons.location_on_rounded, color: primary, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার বর্তমান অবস্থান',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationSubline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: _isRefreshing ? null : () => _loadLocation(refresh: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child:
                    _isRefreshing
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primary,
                          ),
                        )
                        : Icon(
                          Icons.my_location_rounded,
                          color: primary,
                          size: 19,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN COMPASS CARD
  // ============================================================

  Widget _buildCompassCard({
    required BuildContext context,
    required Color primary,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required double heading,
    required double? qibla,
    required double? qiblaDifference,
  }) {
    final size = MediaQuery.sizeOf(context);

    final compassSize = math.min(size.width - 24, 370.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // TOP FIXED QIBLA POINTER
          // ------------------------------------------------------
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulse = 0.82 + (_pulseController.value * 0.18);

                    return Opacity(
                      opacity: _isAligned ? pulse : 1,
                      child: child,
                    );
                  },
                  child: _buildQiblaTopMarker(primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // ------------------------------------------------------
          // ROTATING DIAL + FIXED CENTER
          // ------------------------------------------------------
          SizedBox(
            width: compassSize,
            height: compassSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ROTATING COMPASS DIAL
                Transform.rotate(
                  angle: -_degreesToRadians(heading),
                  child: CustomPaint(
                    size: Size(compassSize, compassSize),
                    painter: _PremiumCompassPainter(
                      primary: primary,
                      textColor: textPrimary,
                      secondaryColor: textSecondary,
                    ),
                  ),
                ),

                // FIXED CENTER QIBLA ARROW SHAFT
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FixedQiblaPointerPainter(color: primary),
                    ),
                  ),
                ),

                // FIXED CENTER KAABA BADGE
                _buildKaabaCenterBadge(primary: primary),

                // CENTER ALIGNMENT RING
                if (_isAligned)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _AlignmentGlowPainter(
                          color: primary,
                          progress: _pulseController.value,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------
          // LIVE HEADING
          // ------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_rounded, color: primary, size: 18),
              const SizedBox(width: 7),
              Text(
                'আপনার দিক',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '${heading.round()}°',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          if (qibla != null)
            Text(
              'উত্তর থেকে কিবলা ${qibla.toStringAsFixed(1)}°',
              style: TextStyle(
                color: primary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              'Qibla direction নির্ণয় করা হচ্ছে...',
              style: TextStyle(color: textSecondary, fontSize: 11.5),
            ),

          const SizedBox(height: 12),

          // ------------------------------------------------------
          // SENSOR STATUS
          // ------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  _hasCompassSensor
                      ? primary.withValues(alpha: 0.07)
                      : Colors.red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasCompassSensor ? primary : Colors.red,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _sensorStatus,
                  style: TextStyle(
                    color: _hasCompassSensor ? primary : Colors.red,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIXED TOP QIBLA MARKER
  // ============================================================

  Widget _buildQiblaTopMarker(Color primary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 30,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const CustomPaint(painter: _MiniKaabaPainter()),
        ),
        CustomPaint(
          size: const Size(18, 9),
          painter: _TrianglePointerPainter(color: AppColors.seaBlue),
        ),
      ],
    );
  }

  // ============================================================
  // CENTER KAABA BADGE
  // ============================================================

  Widget _buildKaabaCenterBadge({required Color primary}) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border: Border.all(color: primary.withValues(alpha: 0.20), width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primary.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.07),
            ),
          ),
          const SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(painter: _KaabaPainter()),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _buildStatusCard({
    required BuildContext context,
    required Color primary,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required double? qiblaDifference,
  }) {
    final isAligned = _isAligned;

    final difference = qiblaDifference?.toStringAsFixed(1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAligned ? primary.withValues(alpha: 0.08) : surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              isAligned
                  ? primary.withValues(alpha: 0.25)
                  : primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isAligned
                      ? primary.withValues(alpha: 0.16)
                      : primary.withValues(alpha: 0.08),
            ),
            child: Icon(
              isAligned ? Icons.check_rounded : Icons.navigation_rounded,
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAligned ? 'কিবলা সঠিকভাবে মিলেছে' : 'কিবলার দিকে ঘোরান',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isAligned
                      ? 'আপনার ফোন এখন কিবলার দিকে নির্দেশ করছে।'
                      : difference == null
                      ? 'আপনার অবস্থান নির্ণয় হলে নির্দেশনা দেখা যাবে।'
                      : 'কিবলা থেকে বর্তমান বিচ্যুতি $difference°',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSTRUCTION CARD
  // ============================================================

  Widget _buildInstructionCard({
    required BuildContext context,
    required Color primary,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.09)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.screen_rotation_alt_rounded,
              color: primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'কম্পাস ব্যবহারের নিয়ম',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ফোনটি সমতল রাখুন এবং ধীরে ধীরে ঘুরুন। '
                  'কম্পাসের দিকগুলো ঘুরবে, কিন্তু মাঝের '
                  'কিবলা নির্দেশক স্থির থাকবে।',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GUIDE DIALOG
  // ============================================================

  void _showCompassGuide(BuildContext context) {
    final primary = AppColors.seaBlue;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.10),
                      ),
                      child: Icon(Icons.explore_rounded, color: primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'কিবলা কম্পাস কীভাবে ব্যবহার করবেন',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _guideRow(
                  icon: Icons.crop_free_rounded,
                  title: 'ফোনটি সমতল রাখুন',
                  description:
                      'ফোনকে যতটা সম্ভব flat রাখুন এবং ধাতব/চুম্বকীয় জিনিস থেকে দূরে রাখুন।',
                  color: primary,
                ),
                _guideRow(
                  icon: Icons.screen_rotation_alt_rounded,
                  title: 'ধীরে ধীরে ঘুরুন',
                  description:
                      'ফোন ঘোরালে compass dial ঘুরবে। মাঝের Qibla marker স্থির থাকবে।',
                  color: primary,
                ),
                _guideRow(
                  icon: Icons.tune_rounded,
                  title: 'প্রয়োজনে ক্যালিব্রেট করুন',
                  description:
                      'Heading অস্থির হলে ফোনটিকে figure-eight motion-এ কয়েকবার নড়ান।',
                  color: primary,
                ),
                _guideRow(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'সবুজ/নীল alignment দেখুন',
                  description:
                      'কিবলার সাথে প্রায় ৩°-এর মধ্যে এলে NurVerse alignment status দেখাবে।',
                  color: primary,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _guideRow({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.68,
                    ),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
}

// ============================================================================
// PREMIUM COMPASS PAINTER
// ============================================================================

class _PremiumCompassPainter extends CustomPainter {
  final Color primary;
  final Color textColor;
  final Color secondaryColor;

  const _PremiumCompassPainter({
    required this.primary,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.shortestSide / 2;

    // ----------------------------------------------------------
    // OUTER SHADOW
    // ----------------------------------------------------------

    final shadowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black.withValues(alpha: 0.045)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(center.translate(0, 7), radius - 8, shadowPaint);

    // ----------------------------------------------------------
    // OUTER CIRCLE
    // ----------------------------------------------------------

    final outerFill =
        Paint()
          ..style = PaintingStyle.fill
          ..color = primary.withValues(alpha: 0.025);

    canvas.drawCircle(center, radius - 5, outerFill);

    final outerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = primary.withValues(alpha: 0.18);

    canvas.drawCircle(center, radius - 6, outerRing);

    // ----------------------------------------------------------
    // INNER RING
    // ----------------------------------------------------------

    final innerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = primary.withValues(alpha: 0.10);

    canvas.drawCircle(center, radius * 0.79, innerRing);

    // ----------------------------------------------------------
    // DEGREE TICKS
    // ----------------------------------------------------------

    for (int degree = 0; degree < 360; degree++) {
      final angle = _degToRad(degree.toDouble() - 90);

      final isMajor = degree % 30 == 0;
      final isMedium = degree % 10 == 0;

      final outer = radius - 12;

      final tickLength =
          isMajor
              ? 16.0
              : isMedium
              ? 10.0
              : 5.0;

      final tickWidth =
          isMajor
              ? 2.2
              : isMedium
              ? 1.3
              : 0.8;

      final inner = outer - tickLength;

      final start = Offset(
        center.dx + math.cos(angle) * inner,
        center.dy + math.sin(angle) * inner,
      );

      final end = Offset(
        center.dx + math.cos(angle) * outer,
        center.dy + math.sin(angle) * outer,
      );

      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = tickWidth
            ..strokeCap = StrokeCap.round
            ..color =
                degree == 0
                    ? Colors.redAccent
                    : primary.withValues(
                      alpha:
                          isMajor
                              ? 0.72
                              : isMedium
                              ? 0.48
                              : 0.22,
                    );

      canvas.drawLine(start, end, paint);
    }

    // ----------------------------------------------------------
    // DEGREE NUMBERS
    // ----------------------------------------------------------

    for (int degree = 0; degree < 360; degree += 30) {
      final angle = _degToRad(degree.toDouble() - 90);

      final labelRadius = radius - 37;

      final position = Offset(
        center.dx + math.cos(angle) * labelRadius,
        center.dy + math.sin(angle) * labelRadius,
      );

      final text = degree.toString();

      final style = TextStyle(
        color:
            degree == 0
                ? Colors.redAccent
                : secondaryColor.withValues(alpha: 0.78),
        fontSize: degree % 90 == 0 ? 11.5 : 9.5,
        fontWeight: degree % 90 == 0 ? FontWeight.w800 : FontWeight.w600,
      );

      _drawCenteredText(canvas, text, position, style);
    }

    // ----------------------------------------------------------
    // CARDINAL DIRECTIONS
    // ----------------------------------------------------------

    _drawDirectionLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: -90,
      label: 'উত্তর',
      color: Colors.redAccent,
      fontSize: 16,
      fontWeight: FontWeight.w900,
    );

    _drawDirectionLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: 0,
      label: 'পূর্ব',
      color: textColor.withValues(alpha: 0.76),
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

    _drawDirectionLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: 90,
      label: 'দক্ষিণ',
      color: textColor.withValues(alpha: 0.76),
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

    _drawDirectionLabel(
      canvas: canvas,
      center: center,
      radius: radius,
      angle: 180,
      label: 'পশ্চিম',
      color: textColor.withValues(alpha: 0.76),
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

    // ----------------------------------------------------------
    // COMPASS ROSE
    // ----------------------------------------------------------

    _drawCompassRose(canvas, center, radius * 0.43, primary);
  }

  void _drawDirectionLabel({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required String label,
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final radians = _degToRad(angle);

    final position = Offset(
      center.dx + math.cos(radians) * radius * 0.61,
      center.dy + math.sin(radians) * radius * 0.61,
    );

    _drawCenteredText(
      canvas,
      label,
      position,
      TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  void _drawCompassRose(
    Canvas canvas,
    Offset center,
    double radius,
    Color primary,
  ) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = primary.withValues(alpha: 0.08);

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;

      final p1 = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final p2 = Offset(
        center.dx - math.cos(angle) * radius,
        center.dy - math.sin(angle) * radius,
      );

      canvas.drawLine(p1, p2, paint);
    }

    final rosePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = primary.withValues(alpha: 0.025);

    final path = Path();

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;

      final outerRadius = i.isEven ? radius : radius * 0.48;

      final point = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    canvas.drawPath(path, rosePaint);
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  double _degToRad(double degrees) {
    return degrees * math.pi / 180;
  }

  @override
  bool shouldRepaint(covariant _PremiumCompassPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.textColor != textColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

// ============================================================================
// FIXED QIBLA POINTER
// ============================================================================

class _FixedQiblaPointerPainter extends CustomPainter {
  final Color color;

  const _FixedQiblaPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.shortestSide / 2;

    final shaftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.55);

    final shaftStart = Offset(center.dx, center.dy - 8);

    final shaftEnd = Offset(center.dx, center.dy - radius + 43);

    canvas.drawLine(shaftStart, shaftEnd, shaftPaint);

    // Fixed arrow head.
    final arrowPath =
        Path()
          ..moveTo(center.dx, center.dy - radius + 25)
          ..lineTo(center.dx - 11, center.dy - radius + 43)
          ..lineTo(center.dx + 11, center.dy - radius + 43)
          ..close();

    final arrowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _FixedQiblaPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ============================================================================
// ALIGNMENT GLOW
// ============================================================================

class _AlignmentGlowPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _AlignmentGlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.shortestSide / 2 - 10;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: 0.10 + progress * 0.12);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AlignmentGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ============================================================================
// TRIANGLE POINTER
// ============================================================================

class _TrianglePointerPainter extends CustomPainter {
  final Color color;

  const _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(size.width / 2, size.height)
          ..lineTo(0, 0)
          ..lineTo(size.width, 0)
          ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ============================================================================
// MINI KAABA
// ============================================================================

class _MiniKaabaPainter extends CustomPainter {
  const _MiniKaabaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 1),
      width: 21,
      height: 17,
    );

    final body =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      body,
    );

    final band =
        Paint()
          ..color = const Color(0xFFD8A83E)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top + 5, rect.width, 2.5),
      band,
    );

    final door =
        Paint()
          ..color = const Color(0xFFD8A83E)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(rect.center.dx - 3, rect.bottom - 7, 6, 7),
      door,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniKaabaPainter oldDelegate) {
    return false;
  }
}

// ============================================================================
// KAABA CENTER
// ============================================================================

class _KaabaPainter extends CustomPainter {
  const _KaabaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final width = size.width * 0.72;
    final height = size.height * 0.62;

    final left = center.dx - width / 2;
    final top = center.dy - height / 2;

    final frontRect = Rect.fromLTWH(left, top + 5, width, height);

    final frontPaint =
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(frontRect, const Radius.circular(3)),
      frontPaint,
    );

    final topPath =
        Path()
          ..moveTo(left, top + 5)
          ..lineTo(center.dx, top - 5)
          ..lineTo(left + width, top + 5)
          ..close();

    canvas.drawPath(
      topPath,
      Paint()
        ..color = const Color(0xFF242424)
        ..style = PaintingStyle.fill,
    );

    final bandPaint =
        Paint()
          ..color = const Color(0xFFD8A83E)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(left, top + height * 0.31, width, 4),
      bandPaint,
    );

    final doorWidth = width * 0.23;
    final doorHeight = height * 0.42;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - doorWidth / 2,
          top + height - doorHeight,
          doorWidth,
          doorHeight,
        ),
        const Radius.circular(1.5),
      ),
      Paint()
        ..color = const Color(0xFFD8A83E)
        ..style = PaintingStyle.fill,
    );

    final handlePaint =
        Paint()
          ..color = const Color(0xFFF3D27A)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx + doorWidth * 0.16, top + height - doorHeight * 0.52),
      1.2,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _KaabaPainter oldDelegate) {
    return false;
  }
}
