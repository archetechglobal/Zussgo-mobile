// lib/features/profile/models/profile_model.dart

class ProfileModel {
  final String id;
  final String? name;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? baseCity;
  final String? gender;
  final String? dob;
  final List<String> vibes;
  final List<String> languages;
  final double rating;
  final int age;
  final double trustScore;
  final int tripCount;
  final int reviewCount;
  final bool isSetupDone;

  const ProfileModel({
    required this.id,
    this.name,
    this.username,
    this.avatarUrl,
    this.bio,
    this.baseCity,
    this.gender,
    this.dob,
    this.vibes = const [],
    this.languages = const [],
    this.rating = 0.0,
    this.age = 0,
    this.trustScore = 0.0,
    this.tripCount = 0,
    this.reviewCount = 0,
    this.isSetupDone = false,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> m) {
    return ProfileModel(
      id:          m['id'] as String,
      name:        m['name'] as String?,
      username:    m['username'] as String?,
      avatarUrl:   m['avatar_url'] as String?,
      bio:         m['bio'] as String?,
      baseCity:    m['base_city'] as String?,
      gender:      m['gender'] as String?,
      dob:         m['dob'] as String?,
      vibes:       List<String>.from(m['vibes'] ?? []),
      languages:   List<String>.from(m['languages'] ?? []),
      rating:      (m['rating'] as num?)?.toDouble() ?? 0.0,
      age:         (m['age'] as num?)?.toInt() ?? 0,
      trustScore:  (m['trust_score'] as num?)?.toDouble() ?? 0.0,
      tripCount:   (m['trip_count'] as num?)?.toInt() ?? 0,
      reviewCount: (m['review_count'] as num?)?.toInt() ?? 0,
      isSetupDone: m['is_setup_done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name':         name,
    'username':     username,
    'avatar_url':   avatarUrl,
    'bio':          bio,
    'base_city':    baseCity,
    'gender':       gender,
    'dob':          dob,
    'vibes':        vibes,
    'languages':    languages,
    'trust_score':  trustScore,
    'is_setup_done': isSetupDone,
  };

  ProfileModel copyWith({
    String? name, String? username, String? avatarUrl,
    String? bio, String? baseCity, String? gender, String? dob,
    List<String>? vibes, List<String>? languages,
    double? rating, int? age, double? trustScore,
    int? tripCount, int? reviewCount, bool? isSetupDone,
  }) => ProfileModel(
    id:          id,
    name:        name ?? this.name,
    username:    username ?? this.username,
    avatarUrl:   avatarUrl ?? this.avatarUrl,
    bio:         bio ?? this.bio,
    baseCity:    baseCity ?? this.baseCity,
    gender:      gender ?? this.gender,
    dob:         dob ?? this.dob,
    vibes:       vibes ?? this.vibes,
    languages:   languages ?? this.languages,
    rating:      rating ?? this.rating,
    age:         age ?? this.age,
    trustScore:  trustScore ?? this.trustScore,
    tripCount:   tripCount ?? this.tripCount,
    reviewCount: reviewCount ?? this.reviewCount,
    isSetupDone: isSetupDone ?? this.isSetupDone,
  );
}