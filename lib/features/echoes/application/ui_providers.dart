import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Selected bottom-nav tab: 0 map, 1 echoes, 2 settings.
final homeTabProvider = NotifierProvider<_TabNotifier, int>(_TabNotifier.new);

class _TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void select(int index) => state = index;
}

/// One-shot request for the map to fly to a location.
final mapFocusProvider =
    NotifierProvider<_FocusNotifier, LatLng?>(_FocusNotifier.new);

class _FocusNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;
  void focus(LatLng point) => state = point;
  void clear() => state = null;
}
