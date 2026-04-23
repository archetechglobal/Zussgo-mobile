import 'package:flutter/material.dart';

class LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    canvas.scale(s, s);
    final p = Paint()
      ..color = const Color(0xFF58DAD0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()..moveTo(10, 13)..lineTo(32, 13)..lineTo(13, 35)..lineTo(36, 35),
      p,
    );
    canvas.drawCircle(
      const Offset(36, 13),
      5.5,
      Paint()..color = const Color(0xFFF7B84E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);
    canvas.drawPath(
      Path()
        ..moveTo(12, 22)
        ..cubicTo(12, 22, 4, 18, 4, 12)
        ..lineTo(4, 5)
        ..lineTo(12, 2)
        ..lineTo(20, 5)
        ..lineTo(20, 12)
        ..cubicTo(20, 18, 12, 22, 12, 22)
        ..close(),
      Paint()
        ..color = const Color(0xB358DAD0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);
    void seg(Color c, Path pt) =>
        canvas.drawPath(pt, Paint()..color = c..style = PaintingStyle.fill);

    seg(const Color(0xFF4285F4), Path()
      ..moveTo(22.56, 12.25)..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10)
      ..lineTo(12, 10)..lineTo(12, 14.26)..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)..close());

    seg(const Color(0xFF34A853), Path()
      ..moveTo(12, 23)..cubicTo(14.97, 23, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)..cubicTo(14.73, 18.23, 13.48, 18.63, 12, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)..lineTo(2.18, 14.1)
      ..lineTo(2.18, 16.94)..cubicTo(3.99, 20.53, 7.7, 23, 12, 23)..close());

    seg(const Color(0xFFFBBC05), Path()
      ..moveTo(5.84, 14.09)..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)..lineTo(5.84, 7.07)
      ..lineTo(2.18, 7.07)..cubicTo(1.43, 8.55, 1, 10.22, 1, 12)
      ..cubicTo(1, 13.78, 1.43, 15.45, 2.18, 16.93)..lineTo(5.84, 14.09)..close());

    seg(const Color(0xFFEA4335), Path()
      ..moveTo(12, 5.38)..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)..cubicTo(17.45, 2.09, 14.97, 1, 12, 1)
      ..cubicTo(7.7, 1, 3.99, 3.47, 2.18, 7.07)..lineTo(5.84, 9.91)
      ..cubicTo(6.71, 7.31, 9.14, 5.38, 12, 5.38)..close());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}