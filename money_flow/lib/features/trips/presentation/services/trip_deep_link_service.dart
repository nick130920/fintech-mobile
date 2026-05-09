import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/trip_invitation_provider.dart';
import '../screens/accept_invitation_screen.dart';
import '../screens/trip_detail_screen.dart';
import '../screens/trips_list_screen.dart';

/// Servicio que escucha deep links y abre la pantalla apropiada del módulo de viajes.
///
/// Esquemas soportados:
/// - moneyflow://invitations/{token}
/// - moneyflow://trips
/// - moneyflow://trips/{id}
/// - https://moneyflow.app/invitations/{token}
/// - https://moneyflow.app/trips/{id}
class TripDeepLinkService {
  TripDeepLinkService({
    required GlobalKey<NavigatorState> navigatorKey,
    required TripInvitationProvider invitationProvider,
    AppLinks? appLinks,
  })  : _navigatorKey = navigatorKey,
        _invitationProvider = invitationProvider,
        _appLinks = appLinks ?? AppLinks();

  final GlobalKey<NavigatorState> _navigatorKey;
  final TripInvitationProvider _invitationProvider;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _subscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (e) {
      debugPrint('TripDeepLinkService: error en getInitialLink -> $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        debugPrint('TripDeepLinkService: stream error -> $error');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  void _handleUri(Uri uri) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    // Para esquema custom (moneyflow://invitations/{token}), `invitations` viene
    // como host. Para HTTPS (https://moneyflow.app/invitations/{token}) viene
    // como primer segmento de path. Combinamos ambos casos.
    final segments = <String>[];
    if (uri.host.isNotEmpty) {
      segments.add(uri.host);
    }
    segments.addAll(uri.pathSegments.where((s) => s.isNotEmpty));
    if (segments.isEmpty) return;

    final first = segments.first.toLowerCase();
    if (first == 'invitations' && segments.length >= 2) {
      final token = segments[1];
      _invitationProvider.setPendingToken(token);
      navigator.push(
        MaterialPageRoute(
          builder: (_) => AcceptInvitationScreen(initialToken: token),
        ),
      );
      return;
    }

    if (first == 'trips') {
      if (segments.length == 1) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const TripsListScreen()),
        );
        return;
      }
      final tripId = int.tryParse(segments[1]);
      if (tripId != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => TripDetailScreen(tripId: tripId),
          ),
        );
      }
    }
  }
}
