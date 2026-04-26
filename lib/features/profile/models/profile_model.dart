class ProfileModel {
  final String id;
  final String? name;
  final int? age;
  final String? baseCity;
  final String? bio;
  final String? avatarUrl;
  final List<String> vibes;
  final String? budget;
  final String? pace;
  final String? accommodation;
  final bool isSetupDone;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    this.name,
    this.age,
    this.baseCity,
    this.bio,
    this.avatarUrl,
    this.vibes = const [],
    this.budget,
    this.pace,
    this.accommodation,
    this.isSetupDone = false,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:            json['id'] as String,
      name:          json['name'] as String?,
      age:           json['age'] as int?,
      baseCity:      json['base_city'] as String?,
      bio:           json['bio'] as String?,
      avatarUrl:     json['avatar_url'] as String?,
      vibes:         List<String>.from(json['vibes'] ?? []),
      budget:        json['budget'] as String?,
      pace:          json['pace'] as String?,
      accommodation: json['accommodation'] as String?,
      isSetupDone:   json['is_setup_done'] as bool? ?? false,
      createdAt:     json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'name':          name,
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
    String? name, int? age, String? baseCity, String? bio,
    String? avatarUrl, List<String>? vibes, String? budget,
    String? pace, String? accommodation, bool? isSetupDone,
  }) {
    return ProfileModel(
      id:            id,
      name:          name          ?? this.name,
      age:           age           ?? this.age,
      baseCity:      baseCity      ?? this.baseCity,
      bio:           bio           ?? this.bio,
      avatarUrl:     avatarUrl     ?? this.avatarUrl,
      vibes:         vibes         ?? this.vibes,
      budget:        budget        ?? this.budget,
      pace:          pace          ?? this.pace,
      accommodation: accommodation ?? this.accommodation,
      isSetupDone:   isSetupDone   ?? this.isSetupDone,
      createdAt:     createdAt,
    );
  }
}