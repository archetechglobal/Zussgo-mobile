// lib/shared/widgets/user_avatar.dart
//
// Avatar priority chain:
//  1. avatarUrl (uploaded photo stored in Supabase Storage)
//  2. googlePhotoUrl  (picture from Google user_metadata — auto-populated at sign-in)
//  3. Initials fallback (first letter of name, teal background)
//
// Usage:
//   UserAvatar(size: 74, avatarUrl: profile.avatarUrl)
//   UserAvatar(size: 40)   // reads from current auth session automatically

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAvatar extends StatelessWidget {
  /// Uploaded profile photo URL (from Supabase Storage). Highest priority.
  final String? avatarUrl;

  /// Override display name used for initials. Defaults to Supabase user metadata.
  final String? displayName;

  /// Side length of the square avatar. The widget is always a square.
  final double size;

  /// Corner radius. Defaults to size * 0.28 (slightly rounded square).
  final double? borderRadius;

  /// Optional border drawn around the avatar ring.
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.displayName,
    required this.size,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 0,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static const _teal  = Color(0xFF1EC9B8);
  static const _teal2 = Color(0xFF58DAD0);

  /// Resolve effective avatar URL: uploaded photo > Google photo from metadata
  static String? _resolvePhotoUrl(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) return avatarUrl;

    // Pull Google/social picture from Supabase auth user_metadata
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    if (meta == null) return null;

    final picture = meta['picture'] as String? ??
        meta['avatar_url'] as String? ??
        meta['photo_url'] as String?;
    return (picture != null && picture.isNotEmpty) ? picture : null;
  }

  /// Derive initials from name, falling back to Supabase metadata → email first char
  static String _resolveInitial(String? displayName) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName.trim()[0].toUpperCase();
    }
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final metaName = meta?['full_name'] as String? ?? meta?['name'] as String?;
    if (metaName != null && metaName.isNotEmpty) {
      return metaName.trim()[0].toUpperCase();
    }
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'Z';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _resolvePhotoUrl(avatarUrl);
    final initial  = _resolveInitial(displayName);
    final radius   = borderRadius ?? size * 0.28;

    Widget avatar;

    if (photoUrl != null) {
      avatar = Image.network(
        // Force higher-res Google photo if it's a Google URL
        _upgradeGooglePhotoSize(photoUrl, size.toInt()),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _InitialAvatar(
          initial: initial,
          size: size,
        ),
      );
    } else {
      avatar = _InitialAvatar(initial: initial, size: size);
    }

    Widget clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: avatar),
    );

    if (borderColor != null && borderWidth > 0) {
      clipped = Container(
        width: size + borderWidth * 2,
        height: size + borderWidth * 2,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor!, width: borderWidth),
          borderRadius: BorderRadius.circular(radius + borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(width: size, height: size, child: avatar),
        ),
      );
    }

    return clipped;
  }

  /// Google profile photos use a `=s96-c` suffix for 96px.
  /// We bump it to match the rendered size so it stays crisp.
  static String _upgradeGooglePhotoSize(String url, int px) {
    if (!url.contains('googleusercontent.com')) return url;
    // Remove existing size param and replace with desired size
    return url.replaceAllMapped(
      RegExp(r'=s\d+-c'),
      (_) => '=s${(px * 2).clamp(96, 512)}-c',
    );
  }
}

// ── Initials-only fallback ────────────────────────────────────────────────────

class _InitialAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const _InitialAvatar({required this.initial, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1EC9B8).withOpacity(.20),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: const Color(0xFF58DAD0),
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
            fontFamily: 'Satoshi',
          ),
        ),
      ),
    );
  }
}
