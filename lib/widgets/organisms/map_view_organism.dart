import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';

class MapViewOrganism extends StatefulWidget {
  final LatLng officeLocation;
  final LatLng? userLocation;
  final double radiusInMeters;
  final bool isWithinRadius;
  final bool isFullscreen;

  const MapViewOrganism({
    Key? key,
    required this.officeLocation,
    this.userLocation,
    required this.radiusInMeters,
    this.isWithinRadius = false,
    this.isFullscreen = false,
  }) : super(key: key);

  @override
  State<MapViewOrganism> createState() => _MapViewOrganismState();
}

class _MapViewOrganismState extends State<MapViewOrganism> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mapContent = FlutterMap(
      options: MapOptions(
        initialCenter: widget.userLocation ?? widget.officeLocation,
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.mpg_mobile',
        ),
        CircleLayer(
          circles: [
            CircleMarker(
              point: widget.officeLocation,
              color: widget.isWithinRadius
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.statusRed.withOpacity(0.05),
              borderStrokeWidth: 2,
              borderColor: widget.isWithinRadius ? AppTheme.primaryBlue : AppTheme.statusRed,
              useRadiusInMeter: true,
              radius: widget.radiusInMeters,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (widget.userLocation != null)
              Marker(
                point: widget.userLocation!,
                width: 80,
                height: 80,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 30 + (_pulseController.value * 50),
                          height: 30 + (_pulseController.value * 50),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (widget.isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed)
                                .withOpacity(0.4 * (1.0 - _pulseController.value)),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isWithinRadius ? AppTheme.statusGreen : AppTheme.statusRed).withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );

    if (widget.isFullscreen) {
      return mapContent;
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: mapContent,
      ),
    );
  }
}
