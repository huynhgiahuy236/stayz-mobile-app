import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The vi tri: xem truoc dang ban do, bam vao mo Google Maps.
///
/// Flutter mobile khong nhung duoc iframe nhu web, nen day la anh xem truoc +
/// mo GG Maps khi bam. Neu khach san khong co toa do, mac dinh ve dia chi
/// IUH - 12 Nguyen Van Bao, Go Vap, TP.HCM.
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

  // Toa do mac dinh: Dai hoc Cong nghiep TP.HCM (IUH).
  static const double _iuhLat = 10.822154;
  static const double _iuhLng = 106.686409;
  static const String _iuhAddress = '12 Nguyễn Văn Bảo, Phường 1, Gò Vấp, TP.HCM';

  bool get _hasCoords => latitude != 0 || longitude != 0;

  double get _lat => _hasCoords ? latitude : _iuhLat;
  double get _lng => _hasCoords ? longitude : _iuhLng;
  String get _label => address.isNotEmpty ? address : _iuhAddress;

  Future<void> _openMaps(BuildContext context) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được Google Maps.')),
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
                // Xem truoc dang ban do (ve gia lap luoi duong pho + ghim).
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: _MapPreviewPainter()),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_rounded, size: 15, color: AppTheme.primary),
                              SizedBox(width: 5),
                              Text('Mở Google Maps', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w800)),
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

/// Ve luoi duong pho gia lap cho o xem truoc ban do.
class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EEF3));

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    final thin = Paint()
      ..color = const Color(0xFFD3DEE7)
      ..strokeWidth = 2;

    // Duong doc/ngang thua
    for (var x = size.width * 0.2; x < size.width; x += size.width * 0.28) {
      canvas.drawLine(Offset(x, 0), Offset(x + 12, size.height), road);
    }
    for (var y = size.height * 0.25; y < size.height; y += size.height * 0.3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 6), road);
    }
    for (var x = size.width * 0.1; x < size.width; x += size.width * 0.14) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, size.height), thin);
    }

    // Vai o "cong vien" xanh
    final park = Paint()..color = const Color(0xFFCDE6CF);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.55, size.height * 0.12, 60, 40), const Radius.circular(6)), park);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.6, 48, 34), const Radius.circular(6)), park);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
