// lib/features/profile/models/profile_model.dart

class ProfileModel {
  final String id;
  final String? name;
  final String? phone;
  final int? age;
  final String? baseCity;
  final String? bio;
  final String? avatarUrl;
  final List<String> vibes;
  final String? budget;
  final String? pace;
  final String? accommodation;
  final double rating;
  final int tripCount;
  final int buddyCount;
  final bool isSetupDone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.id,
    this.name,
    this.phone,
    this.age,
    this.baseCity,
    this.bio,
    this.avatarUrl,
    this.vibes = const [],
    this.budget,
    this.pace,
    this.accommodation,
    this.rating = 0.0,
    this.tripCount = 0,
    this.buddyCount = 0,
    this.isSetupDone = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:            json['id'] as String,
      name:          json['name'] as String?,
      phone:         json['phone'] as String?,
      age:           json['age'] as int?,
      baseCity:      json['base_city'] as String?,
      bio:           json['bio'] as String?,
      avatarUrl:     json['avatar_url'] as String?,
      vibes:         List<String>.from(json['vibes'] ?? []),
      budget:        json['budget'] as String?,
      pace:          json['pace'] as String?,
      accommodation: json['accommodation'] as String?,
      rating:        (json['rating'] as num?)?.toDouble() ?? 0.0,
      tripCount:     (json['trip_count'] as num?)?.toInt() ?? 0,
      buddyCount:    (json['buddy_count'] as num?)?.toInt() ?? 0,
      isSetupDone:   json['is_setup_done'] as bool? ?? false,
      createdAt:     json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt:     json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Alias for [fromJson] — TripModel.fromMap calls this for joined creator data.
  factory ProfileModel.fromMap(Map<String, dynamic> m) => ProfileModel.fromJson(m);

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
    'phone':         phone,
    'age':           age,
    'base_city':     baseCity,
    'bio':           bio,
    'avatar_url':    avatarUrl,
    'vibes':         vibes,
    'budget':        budget,
    'pace':          pace,
    'accommodation': accommodation,
    'is_setup_done': isSetupDone,
  };

  ProfileModel copyWith({
    String? name,
    String? phone,
    int? age,
    String? baseCity,
    String? bio,
    String? avatarUrl,
    List<String>? vibes,
    String? budget,
    String? pace,
    String? accommodation,
    double? rating,
    int? tripCount,
    int? buddyCount,
    bool? isSetupDone,
  }) {
    return ProfileModel(
      id:            id,
      name:          name          ?? this.name,
      phone:         phone         ?? this.phone,
      age:           age           ?? this.age,
      baseCity:      baseCity      ?? this.baseCity,
      bio:           bio           ?? this.bio,
      avatarUrl:     avatarUrl     ?? this.avatarUrl,
      vibes:         vibes         ?? this.vibes,
      budget:        budget        ?? this.budget,
      pace:          pace          ?? this.pace,
      accommodation: accommodation ?? this.accommodation,
      rating:        rating        ?? this.rating,
      tripCount:     tripCount     ?? this.tripCount,
      buddyCount:    buddyCount    ?? this.buddyCount,
      isSetupDone:   isSetupDone   ?? this.isSetupDone,
      createdAt:     createdAt,
      updatedAt:     updatedAt,
    );
  }
}