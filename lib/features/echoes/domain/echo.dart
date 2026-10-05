import 'package:latlong2/latlong.dart';

import 'echo_category.dart';

class Echo {
  const Echo({
    required this.id,
    required this.title,
    required this.category,
    required this.audioPath,
    required this.latitude,
    required this.longitude,
    required this.durationMs,
    required this.createdAt,
    this.plays = 0,
  });

  final String id;
  final String title;
  final EchoCategory category;
  final String audioPath;
  final double latitude;
  final double longitude;
  final int durationMs;
  final DateTime createdAt;
  final int plays;

  LatLng get position => LatLng(latitude, longitude);
  Duration get duration => Duration(milliseconds: durationMs);

  Echo copyWith({String? title, EchoCategory? category, int? plays}) => Echo(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        audioPath: audioPath,
        latitude: latitude,
        longitude: longitude,
        durationMs: durationMs,
        createdAt: createdAt,
        plays: plays ?? this.plays,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'audioPath': audioPath,
        'latitude': latitude,
        'longitude': longitude,
        'durationMs': durationMs,
        'createdAt': createdAt.toIso8601String(),
        'plays': plays,
      };

  factory Echo.fromJson(Map<String, dynamic> json) => Echo(
        id: json['id'] as String,
        title: json['title'] as String,
        category: EchoCategory.fromName(json['category'] as String?),
        audioPath: json['audioPath'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        durationMs: json['durationMs'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        plays: json['plays'] as int? ?? 0,
      );
}
