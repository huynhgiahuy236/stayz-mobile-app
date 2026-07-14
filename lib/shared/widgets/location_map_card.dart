import 'dart:math' as math;

import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The vi tri: xem truoc dang ban do, bam vao mo Google Maps.
///
/// Flutter mobile khong nhung duoc iframe nhu web, nen day la anh ve tinh xem
/// truoc + mo Google Maps khi bam.
class LocationMapCard extends StatelessWidget {
  const LocationMapCard({
    required this.latitude,
    required this.longitude,
    required this.address,
    super.key,
  });

  final double latitude;
  final double longitude;
  final String address;

  bool get _hasCoords => latitude != 0 && longitude != 0;
  String get _label => address.trim().isNotEmpty
      ? address.trim()
      : tr('Chưa có địa chỉ xác thực', 'Verified address unavailable');

  String? get _satelliteTileUrl {
    if (!_hasCoords) return null;
    const zoom = 16;
    final scale = 1 << zoom;
    final x = ((longitude + 180) / 360 * scale).floor();
    final latitudeRadians = latitude * math.pi / 180;
    final y = ((1 -
                math.log(
                      math.tan(latitudeRadians) +
                          (1 / math.cos(latitudeRadians)),
                    ) /
                    math.pi) /
            2 *
            scale)
        .floor();
    return 'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'World_Imagery/MapServer/tile/$zoom/$y/$x';
  }

  Future<void> _openMaps(BuildContext context) async {
    final query = _hasCoords ? '$latitude,$longitude' : address.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Khách sạn chưa có vị trí xác thực.', 'The hotel has no verified location yet.'),
          ),
        ),
      );
      return;
    }
    final uri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': query},
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Không mở được Google Maps.', 'Could not open Google Maps.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMaps(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.line),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_satelliteTileUrl case final tileUrl?)
                        Image.network(
                          tileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const _MapUnavailable(),
                        )
                      else
                        const _MapUnavailable(),
                      Container(color: Colors.black.withValues(alpha: 0.08)),
                      const Center(
                        child: Icon(Icons.location_on_rounded, color: AppTheme.danger, size: 40),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_rounded, size: 15, color: AppTheme.primary),
                              const SizedBox(width: 5),
                              Text(tr('Mở Google Maps', 'Open Google Maps'), style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 18, color: AppTheme.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _label,
                          style: const TextStyle(color: AppTheme.ink, fontSize: 13, height: 1.4),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE8EEF3),
    alignment: Alignment.center,
    child: Text(
      tr('Chưa có ảnh vệ tinh', 'Satellite preview unavailable'),
      style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700),
    ),
  );
}
