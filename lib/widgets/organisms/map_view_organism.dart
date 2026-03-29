import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

class _MapViewOrganismState extends State<MapViewOrganism> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant MapViewOrganism oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userLocation != null &&
        widget.userLocation != oldWidget.userLocation &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(widget.userLocation!),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Circle> _buildCircles() {
    return {
      Circle(
        circleId: const CircleId('office_radius'),
        center: widget.officeLocation,
        radius: widget.radiusInMeters,
        fillColor: widget.isWithinRadius
            ? AppTheme.primaryBlue.withOpacity(0.1)
            : AppTheme.statusRed.withOpacity(0.05),
        strokeColor: widget.isWithinRadius ? AppTheme.primaryBlue : AppTheme.statusRed,
        strokeWidth: 2,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('office'),
        position: widget.officeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Lokasi Kantor'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = widget.userLocation ?? widget.officeLocation;

    Widget mapContent = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 16.0,
      ),
      circles: _buildCircles(),
      markers: _buildMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
      },
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
