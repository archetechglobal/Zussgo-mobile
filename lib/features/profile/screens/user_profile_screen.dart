import 'package:flutter/material.dart';

class TravelLogEntry {
  final String emoji;
  final String destination;
  final String companions;

  const TravelLogEntry({
    required this.emoji,
    required this.destination,
    required this.companions,
  });
}

class TravelReview {
  final String initial;
  final String name;
  final String tripLabel;
  final String text;

  const TravelReview({
    required this.initial,
    required this.name,
    required this.tripLabel,
    required this.text,
  });
}

class UserProfileData {
  final String name;
  final int age;
  final String basedIn;
  final String avatarInitial;
  final Color avatarColor;
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
  final List<String> gallery;

  const UserProfileData({
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
    required this.gallery,
  });
}

final _mockProfiles = <String, UserProfileData>{
  'meera': UserProfileData(
    name: 'Meera',
    age: 24,
    basedIn: 'Pune',
    avatarInitial: 'M',
    avatarColor: const Color(0xFF58DAD0),
    rating: 4.9,
    tripCount: 8,
    buddyCount: 12,
    bio:
    'Adventure seeker by default. Mountains, high altitudes, and terrible wifi — that\'s the dream. Always looking for a solid trek partner.',
    vibes: const ['🏔 Adventure', '🎒 Backpacker', '🌄 Sunrise Chaser'],
    activeTripName: 'Spiti Valley Crew',
    activeTripDates: 'May 10–18',
    activeTripLooking: 'Looking for 1–2',
    travelLog: const [
      TravelLogEntry(
        emoji: '🏔',
        destination: 'Leh Ladakh',
        companions: 'with Arjun +2',
      ),
      TravelLogEntry(
        emoji: '🌴',
        destination: 'Andaman',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🏛',
        destination: 'Hampi',
        companions: 'with Sara',
      ),
      TravelLogEntry(
        emoji: '❄️',
        destination: 'Kasol',
        companions: 'with 3 others',
      ),
    ],
    reviews: const [
      TravelReview(
        initial: 'A',
        name: 'Arjun K.',
        tripLabel: 'Leh • Aug 2025',
        text:
        'Meera is an incredible travel buddy. Planned every detail, kept spirits high even at 17,000 ft.',
      ),
      TravelReview(
        initial: 'S',
        name: 'Sara M.',
        tripLabel: 'Hampi • Feb 2025',
        text:
        'Super organised and so much fun. Never a dull moment. Highly recommend travelling with Meera.',
      ),
    ],
    gallery: const ['Summit', 'Camp', 'Sunrise'],
  ),
  'kabir': UserProfileData(
    name: 'Kabir',
    age: 26,
    basedIn: 'Mumbai',
    avatarInitial: 'K',
    avatarColor: const Color(0xFFF7B84E),
    rating: 4.7,
    tripCount: 11,
    buddyCount: 15,
    bio:
    'Festival-first traveler. Music, chaos, food trails, beach nights — that is my kind of plan.',
    vibes: const ['🎉 Festival', '🎵 Live Music', '🌃 Night Owl'],
    activeTripName: 'Goa Festival Crew',
    activeTripDates: 'May 12–15',
    activeTripLooking: 'Looking for 2',
    travelLog: const [
      TravelLogEntry(
        emoji: '🎪',
        destination: 'Goa',
        companions: 'with 4 others',
      ),
      TravelLogEntry(
        emoji: '🏖',
        destination: 'Alibaug',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🎸',
        destination: 'Pune',
        companions: 'with friends',
      ),
    ],
    reviews: const [
      TravelReview(
        initial: 'R',
        name: 'Rhea P.',
        tripLabel: 'Goa • Dec 2025',
        text: 'Kabir keeps the vibe alive. Perfect if you want a high-energy trip.',
      ),
    ],
    gallery: const ['Beach', 'Concert', 'Night'],
  ),
  'anika': UserProfileData(
    name: 'Anika',
    age: 23,
    basedIn: 'Delhi',
    avatarInitial: 'A',
    avatarColor: const Color(0xFFB57BFF),
    rating: 4.7,
    tripCount: 6,
    buddyCount: 9,
    bio:
    'History nerd who turned it into travel goals. Heritage sites, local bazaars, and street food — that\'s my kind of trip.',
    vibes: const ['🏛 Culture', '📸 Photographer', '☕ Cafe Hopper'],
    activeTripName: 'Jaipur Heritage Crew',
    activeTripDates: 'May 14–17',
    activeTripLooking: 'Looking for 1',
    travelLog: const [
      TravelLogEntry(
        emoji: '🏯',
        destination: 'Jaisalmer',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🕌',
        destination: 'Agra',
        companions: 'with Neha',
      ),
      TravelLogEntry(
        emoji: '🌊',
        destination: 'Pondicherry',
        companions: 'with 2 others',
      ),
    ],
    reviews: const [
      TravelReview(
        initial: 'N',
        name: 'Neha R.',
        tripLabel: 'Agra • Jan 2025',
        text:
        'Anika knows every hidden gem in every city. Best travel guide I\'ve ever had.',
      ),
    ],
    gallery: const ['Fort', 'Cafe', 'Market'],
  ),
  'dev': UserProfileData(
    name: 'Dev',
    age: 25,
    basedIn: 'Bangalore',
    avatarInitial: 'D',
    avatarColor: const Color(0xFF58DAD0),
    rating: 4.5,
    tripCount: 9,
    buddyCount: 10,
    bio:
    'Trekking, camping, and cold mornings. I like a trip with challenge, views, and good people.',
    vibes: const ['🥾 Trekking', '🏕 Camping', '🌄 Sunrise Chaser'],
    activeTripName: 'Coorg Trails',
    activeTripDates: 'May 18–21',
    activeTripLooking: 'Looking for 1',
    travelLog: const [
      TravelLogEntry(
        emoji: '🥾',
        destination: 'Kodai',
        companions: 'with 2 others',
      ),
      TravelLogEntry(
        emoji: '🏕',
        destination: 'Coorg',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🌿',
        destination: 'Munnar',
        companions: 'with Priya',
      ),
    ],
    reviews: const [],
    gallery: const ['Trail', 'Tent', 'Peak'],
  ),
  'priya': UserProfileData(
    name: 'Priya',
    age: 22,
    basedIn: 'Chennai',
    avatarInitial: 'P',
    avatarColor: const Color(0xFFFFB3C1),
    rating: 4.8,
    tripCount: 5,
    buddyCount: 7,
    bio:
    'Beaches, hammocks and zero agenda. I travel slow. If you\'re rushing, we\'re not a match.',
    vibes: const ['🌊 Beach', '🧘 Mindful', '🌅 Sunset Hunter'],
    activeTripName: 'Kerala Backwaters',
    activeTripDates: 'May 20–25',
    activeTripLooking: 'Looking for 2',
    travelLog: const [
      TravelLogEntry(
        emoji: '🌴',
        destination: 'Goa',
        companions: 'with Dev +1',
      ),
      TravelLogEntry(
        emoji: '🏝',
        destination: 'Varkala',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🌿',
        destination: 'Coorg',
        companions: 'with friends',
      ),
    ],
    reviews: const [],
    gallery: const ['Sea', 'Boat', 'Sunset'],
  ),
  'rohan': UserProfileData(
    name: 'Rohan',
    age: 27,
    basedIn: 'Hyderabad',
    avatarInitial: 'R',
    avatarColor: const Color(0xFFF7B84E),
    rating: 4.4,
    tripCount: 7,
    buddyCount: 11,
    bio:
    'Road trips, music, and spontaneous plans. If there is a late-night drive involved, I\'m in.',
    vibes: const ['🎸 Party', '🚗 Roadtrip', '🌃 Nightlife'],
    activeTripName: 'Pune–Goa Road Trip',
    activeTripDates: 'May 22–26',
    activeTripLooking: 'Looking for 2',
    travelLog: const [
      TravelLogEntry(
        emoji: '🎸',
        destination: 'Goa',
        companions: 'with crew',
      ),
      TravelLogEntry(
        emoji: '🏙',
        destination: 'Pune',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🌊',
        destination: 'Mahabaleshwar',
        companions: 'with 3 others',
      ),
    ],
    reviews: const [],
    gallery: const ['Drive', 'City', 'Party'],
  ),
  'sara': UserProfileData(
    name: 'Sara',
    age: 24,
    basedIn: 'Jaipur',
    avatarInitial: 'S',
    avatarColor: const Color(0xFFB57BFF),
    rating: 4.9,
    tripCount: 10,
    buddyCount: 16,
    bio:
    'Forts, bazaars and photography. I like beautiful places, slower travel, and thoughtful company.',
    vibes: const ['🏛 Culture', '📸 Photography', '🛍 Bazaar Hopper'],
    activeTripName: 'Udaipur Lake Trip',
    activeTripDates: 'May 15–18',
    activeTripLooking: 'Looking for 1',
    travelLog: const [
      TravelLogEntry(
        emoji: '🏯',
        destination: 'Jodhpur',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🌅',
        destination: 'Udaipur',
        companions: 'with Anika',
      ),
      TravelLogEntry(
        emoji: '🏛',
        destination: 'Pushkar',
        companions: 'with 2 others',
      ),
    ],
    reviews: const [],
    gallery: const ['Lake', 'Palace', 'Photo'],
  ),
  'arjun': UserProfileData(
    name: 'Arjun',
    age: 28,
    basedIn: 'Kolkata',
    avatarInitial: 'A',
    avatarColor: const Color(0xFFF7B84E),
    rating: 4.6,
    tripCount: 13,
    buddyCount: 20,
    bio:
    'Documentary photographer chasing stories across India. I like slow mornings and meaningful trips.',
    vibes: const ['📸 Photo', '🎬 Storytelling', '🌍 Explorer'],
    activeTripName: 'Northeast India Series',
    activeTripDates: 'May 28 – Jun 5',
    activeTripLooking: 'Looking for 1–2',
    travelLog: const [
      TravelLogEntry(
        emoji: '📸',
        destination: 'Meghalaya',
        companions: 'Solo',
      ),
      TravelLogEntry(
        emoji: '🏔',
        destination: 'Sikkim',
        companions: 'with Meera',
      ),
      TravelLogEntry(
        emoji: '🌿',
        destination: 'Assam',
        companions: 'with 2 others',
      ),
    ],
    reviews: const [],
    gallery: const ['Clouds', 'Lens', 'Hills'],
  ),
};

UserProfileData fallbackProfile(String name) => UserProfileData(
  name: name,
  age: 24,
  basedIn: 'India',
  avatarInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
  avatarColor: const Color(0xFF58DAD0),
  rating: 4.8,
  tripCount: 6,
  buddyCount: 10,
  bio: 'Travel enthusiast always looking for the next adventure and great company.',
  vibes: const ['🌍 Explorer', '🎒 Backpacker'],
  activeTripName: 'Upcoming Trip',
  activeTripDates: 'Coming soon',
  activeTripLooking: 'Looking for buddies',
  travelLog: const [
    TravelLogEntry(
      emoji: '✈️',
      destination: 'Past trip',
      companions: 'Solo',
    ),
  ],
  reviews: const [],
  gallery: const ['Trip'],
);

UserProfileData profileDataFromName(String rawName) {
  final key = rawName.toLowerCase().trim();
  return _mockProfiles[key] ??
      _mockProfiles[key.split(' ').first] ??
      fallbackProfile(rawName.split(' ').first);
}