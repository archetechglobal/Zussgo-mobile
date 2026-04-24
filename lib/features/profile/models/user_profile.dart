// lib/features/profile/models/user_profile.dart

class TravelLogEntry {
  final String destination;
  final String companions;
  final String emoji;
  const TravelLogEntry({
    required this.destination,
    required this.companions,
    required this.emoji,
  });
}

class TravelReview {
  final String reviewerInitial;
  final String reviewerName;
  final String tripLabel;
  final String text;
  const TravelReview({
    required this.reviewerInitial,
    required this.reviewerName,
    required this.tripLabel,
    required this.text,
  });
}

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String basedIn;
  final String avatarInitial;
  final String avatarColor;
  final double rating;
  final int tripCount;
  final int buddyCount;
  final String bio;
  final List<String> vibes;
  final String activeTripName;
  final String activeTripDates;
  final String activeTripLooking;
  final List<TravelLogEntry> travelLog;
  final List<TravelReview> reviews;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.basedIn,
    required this.avatarInitial,
    required this.avatarColor,
    required this.rating,
    required this.tripCount,
    required this.buddyCount,
    required this.bio,
    required this.vibes,
    required this.activeTripName,
    required this.activeTripDates,
    required this.activeTripLooking,
    required this.travelLog,
    required this.reviews,
  });
}

// ── Mock profiles ─────────────────────────────────────────────────────────────

const mockProfiles = [
  UserProfile(
    id: 'aryan',
    name: 'Aryan',
    age: 26,
    basedIn: 'Mumbai',
    avatarInitial: 'A',
    avatarColor: '0xFF58DAD0',
    rating: 4.9,
    tripCount: 8,
    buddyCount: 12,
    bio: 'Designer by day, avoiding reality by weekend. Always looking for the best local coffee, hidden dive spots, and decent techno.',
    vibes: ['☕ Cafe Hopper', '🌊 Beach Bum', '🎒 Backpacker'],
    activeTripName: 'Goa Beach Crew',
    activeTripDates: 'May 12 – 15',
    activeTripLooking: 'Looking for 1–2',
    travelLog: [
      TravelLogEntry(destination: 'Bali', companions: 'with Sarah +2', emoji: '🌴'),
      TravelLogEntry(destination: 'Manali Trek', companions: 'with Rahul', emoji: '🏔'),
      TravelLogEntry(destination: 'Dubai', companions: 'Solo', emoji: '🏙'),
      TravelLogEntry(destination: 'Spiti', companions: 'with 3 others', emoji: '❄️'),
    ],
    reviews: [
      TravelReview(
        reviewerInitial: 'S',
        reviewerName: 'Sarah M.',
        tripLabel: 'Bali • Oct 2025',
        text: 'Travelled with Aryan to Bali last year. Great navigator, always finds the best food spots. 10/10 travel buddy.',
      ),
      TravelReview(
        reviewerInitial: 'R',
        reviewerName: 'Rahul K.',
        tripLabel: 'Manali • Jan 2025',
        text: 'Super chill and well-organised. Made the whole trip stress-free. Would definitely travel again!',
      ),
    ],
  ),
  UserProfile(
    id: 'priya',
    name: 'Priya',
    age: 24,
    basedIn: 'Bangalore',
    avatarInitial: 'P',
    avatarColor: '0xFFB57BFF',
    rating: 4.7,
    tripCount: 5,
    buddyCount: 8,
    bio: 'Solo traveller turned group enthusiast. Mountains over beaches, always. Looking for people who wake up early for sunrises.',
    vibes: ['🏔 Mountain Lover', '📸 Photographer', '🧘 Mindful Traveller'],
    activeTripName: 'Spiti Valley Crew',
    activeTripDates: 'May 20 – 26',
    activeTripLooking: 'Looking for 2–3',
    travelLog: [
      TravelLogEntry(destination: 'Kedarkantha', companions: 'Solo', emoji: '🏔'),
      TravelLogEntry(destination: 'Coorg', companions: 'with friends', emoji: '🌿'),
      TravelLogEntry(destination: 'Hampi', companions: 'with Neha', emoji: '🏛'),
    ],
    reviews: [
      TravelReview(
        reviewerInitial: 'N',
        reviewerName: 'Neha R.',
        tripLabel: 'Hampi • Mar 2025',
        text: 'Priya is the most organised travel buddy I\'ve had. She had every detail covered. Highly recommend!',
      ),
    ],
  ),
];

UserProfile? getProfileById(String id) {
  try {
    return mockProfiles.firstWhere((p) => p.id == id);
  } catch (_) {
    return mockProfiles.first;
  }
}