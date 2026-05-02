// // lib/features/explore/widgets/india_map_painter.dart
//
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import '../data/explore_data.dart';
//
// // ─── India map painter ────────────────────────────────────────────────────────
// // Draws: land fill + border, flow arcs with animated particles, pulsing nodes.
//
// class IndiaMapPainter extends CustomPainter {
//   final double animationValue;   // 0.0 → 1.0 repeating
//   final List<ExploreDestination> destinations;
//   final List<ExploreFlow> flows;
//   final int? highlightIndex;     // tapped destination index
//   final String activeCategory;
//
//   static const _bg      = Color(0xFF070E0F);
//   static const _land    = Color(0xFF0D1A1B);
//   static const _border  = Color(0xFF1EC9B8);
//   static const _teal    = Color(0xFF1EC9B8);
//
//   // Simplified India outline as relative points (x, y) in 0..1 space
//   static const _indiaOutline = <Offset>[
//     Offset(0.38, 0.04), Offset(0.42, 0.03), Offset(0.48, 0.05),
//     Offset(0.54, 0.06), Offset(0.60, 0.09), Offset(0.65, 0.14),
//     Offset(0.70, 0.18), Offset(0.75, 0.22), Offset(0.78, 0.28),
//     Offset(0.80, 0.34), Offset(0.82, 0.40), Offset(0.80, 0.46),
//     Offset(0.76, 0.50), Offset(0.78, 0.56), Offset(0.74, 0.60),
//     Offset(0.68, 0.64), Offset(0.62, 0.68), Offset(0.56, 0.72),
//     Offset(0.52, 0.76), Offset(0.50, 0.80), Offset(0.48, 0.84),
//     Offset(0.46, 0.88), Offset(0.44, 0.92), Offset(0.43, 0.88),
//     Offset(0.41, 0.84), Offset(0.40, 0.80), Offset(0.38, 0.76),
//     Offset(0.36, 0.72), Offset(0.33, 0.68), Offset(0.30, 0.64),
//     Offset(0.26, 0.60), Offset(0.22, 0.56), Offset(0.20, 0.50),
//     Offset(0.18, 0.44), Offset(0.18, 0.38), Offset(0.20, 0.32),
//     Offset(0.22, 0.26), Offset(0.26, 0.20), Offset(0.30, 0.14),
//     Offset(0.34, 0.09), Offset(0.38, 0.06),
//   ];
//
//   IndiaMapPainter({
//     required this.animationValue,
//     required this.destinations,
//     required this.flows,
//     this.highlightIndex,
//     required this.activeCategory,
//   }) : super(repaint: null);
//
//   Offset _pt(Offset rel, Size size) =>
//       Offset(rel.dx * size.width, rel.dy * size.height);
//
//   Offset _dest(int i, Size size) => Offset(
//     destinations[i].mapX * size.width,
//     destinations[i].mapY * size.height,
//   );
//
//   // Quadratic bezier midpoint — arcs curve upward-left
//   Offset _arcMid(Offset a, Offset b) {
//     final mx = (a.dx + b.dx) / 2;
//     final my = (a.dy + b.dy) / 2;
//     final dx = b.dx - a.dx;
//     final dy = b.dy - a.dy;
//     final perp = Offset(-dy, dx) * 0.25;
//     return Offset(mx + perp.dx, my + perp.dy - (dx.abs() * 0.15));
//   }
//
//   Offset _bezierPoint(Offset p0, Offset p1, Offset p2, double t) {
//     final mt = 1 - t;
//     return Offset(
//       mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
//       mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
//     );
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // ── 1. Land fill ─────────────────────────────────────────────────────────
//     final landPath = Path();
//     for (int i = 0; i < _indiaOutline.length; i++) {
//       final pt = _pt(_indiaOutline[i], size);
//       i == 0 ? landPath.moveTo(pt.dx, pt.dy) : landPath.lineTo(pt.dx, pt.dy);
//     }
//     landPath.close();
//
//     // Radial gradient fill: slightly lighter centre
//     final landGrad = RadialGradient(
//       center: const Alignment(0, -0.1),
//       radius: 0.8,
//       colors: [
//         const Color(0xFF122022),
//         const Color(0xFF0D1A1C),
//         const Color(0xFF091415),
//       ],
//     ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     canvas.drawPath(landPath, Paint()..shader = landGrad);
//
//     // Border glow
//     canvas.drawPath(
//       landPath,
//       Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.0
//         ..color = _border.withOpacity(.14),
//     );
//
//     // ── 2. Flow arcs + particles ──────────────────────────────────────────────
//     for (final flow in flows) {
//       if (flow.fromIndex >= destinations.length ||
//           flow.toIndex >= destinations.length) continue;
//
//       final from  = _dest(flow.fromIndex, size);
//       final to    = _dest(flow.toIndex, size);
//       final mid   = _arcMid(from, to);
//       final color = destinations[flow.toIndex].nodeColor;
//
//       // Draw faint arc line
//       final arcPath = Path()..moveTo(from.dx, from.dy);
//       arcPath.quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
//       canvas.drawPath(
//         arcPath,
//         Paint()
//           ..style       = PaintingStyle.stroke
//           ..strokeWidth = 0.8
//           ..color       = color.withOpacity(.07),
//       );
//
//       // Two staggered particles per arc
//       for (int p = 0; p < 2; p++) {
//         final t = (animationValue + p * 0.5 + flow.fromIndex * 0.13) % 1.0;
//         final pt = _bezierPoint(from, mid, to, t);
//         final r = parseInt(color.red);
//         final g = parseInt(color.green);
//         final b = parseInt(color.blue);
//         final opacity = math.sin(t * math.pi).clamp(0.0, 1.0) * 0.75;
//
//         // Glow halo
//         canvas.drawCircle(
//           pt,
//           3.5,
//           Paint()
//             ..color   = Color.fromRGBO(r, g, b, opacity * 0.35)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
//         );
//         // Core dot
//         canvas.drawCircle(
//           pt,
//           1.5,
//           Paint()..color = Color.fromRGBO(r, g, b, opacity),
//         );
//       }
//     }
//
//     // ── 3. Destination nodes ──────────────────────────────────────────────────
//     for (int i = 0; i < destinations.length; i++) {
//       final d = destinations[i];
//
//       // Skip origin-only cities when category filtered
//       if (activeCategory != 'All' &&
//           d.categories.isEmpty) continue;
//       if (activeCategory != 'All' &&
//           d.categories.isNotEmpty &&
//           !d.categories.contains(activeCategory.toLowerCase())) continue;
//
//       final pos     = _dest(i, size);
//       final color   = d.nodeColor;
//       final isOrigin = d.topTravelers.isEmpty;
//       final isHL    = i == highlightIndex;
//
//       final r = parseInt(color.red);
//       final g = parseInt(color.green);
//       final b = parseInt(color.blue);
//
//       // Pulse radius oscillation
//       final pulse = math.sin(animationValue * math.pi * 2 + i * 0.9) * 0.5 + 0.5;
//
//       if (!isOrigin) {
//         // Outer glow
//         final glowR = 6.0 + d.travelerCount * 0.15 + (isHL ? 4 : 0);
//         canvas.drawCircle(
//           pos,
//           glowR * 2.5,
//           Paint()
//             ..color      = Color.fromRGBO(r, g, b, 0.12)
//             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
//         );
//
//         // Pulse ring
//         canvas.drawCircle(
//           pos,
//           glowR + pulse * 4,
//           Paint()
//             ..style       = PaintingStyle.stroke
//             ..strokeWidth = 1.0
//             ..color       = Color.fromRGBO(r, g, b, 0.18 * pulse),
//         );
//
//         // Core dot
//         final coreR = 5.0 + d.travelerCount * 0.12 + (isHL ? 3 : 0);
//         canvas.drawCircle(
//           pos, coreR,
//           Paint()..color = Color.fromRGBO(r, g, b, 0.90),
//         );
//
//         // White centre
//         canvas.drawCircle(
//           pos, coreR * 0.35,
//           Paint()..color = Colors.white.withOpacity(.80),
//         );
//
//         // City label for major destinations
//         if (d.travelerCount >= 14 || isHL) {
//           final tp = TextPainter(
//             text: TextSpan(
//               text: d.name,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(isHL ? 1.0 : 0.75),
//                 fontSize: isHL ? 10 : 9,
//                 fontWeight: isHL ? FontWeight.w700 : FontWeight.w600,
//               ),
//             ),
//             textDirection: TextDirection.ltr,
//           )..layout();
//           tp.paint(canvas, pos.translate(-tp.width / 2, -(coreR + 14)));
//         }
//       } else {
//         // Origin city — smaller, subtler
//         canvas.drawCircle(
//           pos, 3.0,
//           Paint()..color = Color.fromRGBO(r, g, b, 0.45),
//         );
//         canvas.drawCircle(
//           pos, 1.2,
//           Paint()..color = Colors.white.withOpacity(.55),
//         );
//       }
//     }
//   }
//
//   // Helper — Color component as int
//   int parseInt(int v) => v;
//
//   @override
//   bool shouldRepaint(IndiaMapPainter old) =>
//       old.animationValue != animationValue ||
//           old.highlightIndex != highlightIndex ||
//           old.activeCategory != activeCategory;
// }