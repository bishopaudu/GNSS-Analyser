import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/satellite_info.dart';
import '../utils/app_theme.dart';

class SkyplotView extends StatefulWidget {
  final List<SatelliteInfo> satellites;
  final Function(SatelliteInfo)? onSatelliteTapped;

  const SkyplotView({super.key, required this.satellites, this.onSatelliteTapped});

  @override
  State<SkyplotView> createState() => _SkyplotViewState();
}

class _SkyplotViewState extends State<SkyplotView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 4 seconds per full radar sweep
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 400,
      ),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentPurple.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: 8,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GestureDetector(
          onTapUp: (TapUpDetails details) {
            if (widget.onSatelliteTapped == null) return;
            
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final size = renderBox.size;
            final center = Offset(size.width / 2, size.height / 2);
            final maxRadius = size.width / 2;
            final plotRadius = maxRadius - 16.0;

            for (var sat in widget.satellites) {
              double r = plotRadius * (1.0 - (sat.elevation / 90.0));
              if (r < 0) r = 0; 
              
              double angle = (sat.azimuth - 90) * (math.pi / 180.0);
              
              double x = center.dx + r * math.cos(angle);
              double y = center.dy + r * math.sin(angle);
              
              double distance = math.sqrt(math.pow(x - details.localPosition.dx, 2) + math.pow(y - details.localPosition.dy, 2));
              
              if (distance <= 24.0) {
                widget.onSatelliteTapped!(sat);
                break; // Stop after first match
              }
            }
          },
          child: CustomPaint(
            painter: _SkyplotPainter(
              satellites: widget.satellites,
              animation: _controller,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkyplotPainter extends CustomPainter {
  final List<SatelliteInfo> satellites;
  final Animation<double> animation;

  _SkyplotPainter({
    required this.satellites,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    _drawGrid(canvas, size, center, maxRadius);
    _drawSweep(canvas, center, maxRadius);
    _drawSatellites(canvas, center, maxRadius);
  }

  void _drawSweep(Canvas canvas, Offset center, double maxRadius) {
    // Current rotation angle
    double angle = animation.value * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Offset by -90 degrees so 0 points North like our azimuth
    canvas.rotate(angle - (math.pi / 2));

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          AppTheme.accentCyan.withOpacity(0.1),
          AppTheme.accentCyan.withOpacity(0.4),
        ],
        stops: const [0.0, 0.7, 1.0],
        startAngle: 0.0,
        endAngle: math.pi / 3, // ~60 degree cone
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: maxRadius))
      ..style = PaintingStyle.fill;

    // Draw the radar cone sweep (offset by -pi/3 so the bright edge is exactly at 'angle')
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: maxRadius),
      -math.pi / 3, 
      math.pi / 3,
      true,
      sweepPaint,
    );
    
    // Draw the leading bright scanner line
    final edgePaint = Paint()
      ..color = AppTheme.accentCyan.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset.zero, Offset(maxRadius, 0), edgePaint);

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size, Offset center, double maxRadius) {
    final gridLinePaint = Paint()
      ..color = AppTheme.accentPurple.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final thickLinePaint = Paint()
      ..color = AppTheme.accentPurple.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Concentric elevation rings: 0° (outer), 30°, 60°
    // 0 elevation is outer rim, 90 elevation is center
    canvas.drawCircle(center, maxRadius, thickLinePaint); // 0°
    canvas.drawCircle(center, maxRadius * 2 / 3, gridLinePaint); // 30°
    canvas.drawCircle(center, maxRadius * 1 / 3, gridLinePaint); // 60°
    
    // Crosshair cardinal lines
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), thickLinePaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), thickLinePaint);
    
    // Diagonal lines (45, 135, 225, 315)
    final p45 = maxRadius * math.cos(math.pi / 4);
    canvas.drawLine(Offset(center.dx - p45, center.dy - p45), Offset(center.dx + p45, center.dy + p45), gridLinePaint);
    canvas.drawLine(Offset(center.dx - p45, center.dy + p45), Offset(center.dx + p45, center.dy - p45), gridLinePaint);

    // Cardinal Text Labels (N, E, S, W)
    _drawText(canvas, "N", Offset(center.dx, 0), Alignment.bottomCenter);
    _drawText(canvas, "E", Offset(size.width, center.dy), Alignment.centerLeft);
    _drawText(canvas, "S", Offset(center.dx, size.height), Alignment.topCenter);
    _drawText(canvas, "W", Offset(0, center.dy), Alignment.centerRight);
  }

  void _drawText(Canvas canvas, String text, Offset position, Alignment alignment) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Adjust position based on alignment
    double dx = position.dx;
    double dy = position.dy;
    
    if (alignment == Alignment.bottomCenter) {
      dx -= textPainter.width / 2;
      dy -= textPainter.height + 4;
    } else if (alignment == Alignment.centerLeft) {
      dx += 4;
      dy -= textPainter.height / 2;
    } else if (alignment == Alignment.topCenter) {
      dx -= textPainter.width / 2;
      dy += 4;
    } else if (alignment == Alignment.centerRight) {
      dx -= textPainter.width + 4;
      dy -= textPainter.height / 2;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  void _drawSatellites(Canvas canvas, Offset center, double maxRadius) {
    // Subtract padding so satellites on the 0-elevation horizon don't clip outside the canvas
    final plotRadius = maxRadius - 16.0;

    for (var sat in satellites) {
      double r = plotRadius * (1.0 - (sat.elevation / 90.0));
      // Ensure it doesn't go below 0 if elevation > 90 happens
      if (r < 0) r = 0; 
      
      double angle = (sat.azimuth - 90) * (math.pi / 180.0);
      
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      
      final constellationColor = AppTheme.constellationColors[sat.constellation.label] ?? AppTheme.textMuted;
      
      // Significantly increase dot and glow sizes so they are impossible to miss!
      double pointSize = sat.usedInFix ? 8.0 : 6.0;
      double glowSize = sat.usedInFix ? (16.0 + (sat.snr / 2)) : 10.0;
      
      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = constellationColor;
        
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = constellationColor.withOpacity(sat.usedInFix ? 0.6 : 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      if (sat.snr > 0) {
        canvas.drawCircle(Offset(x, y), glowSize, glowPaint);
      }
      
      canvas.drawCircle(Offset(x, y), pointSize, dotPaint);

      if (sat.usedInFix) {
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 2.0;
        canvas.drawCircle(Offset(x, y), pointSize, borderPaint);
      }
      
      // Prefix the SVID with the constellation label to make it obvious (e.g. "GPS-8")
      final String satLabel = '${sat.constellation.label}-${sat.svid}';
      
      // Draw SVID Text brighter and larger
      final textPainter = TextPainter(
        text: TextSpan(
          text: satLabel,
          style: const TextStyle(
            color: Colors.white, // Pure white to ensure it stands out over the sweep
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Add a slight dark background to the text so it pops off the grid
      canvas.drawRect(
        Rect.fromLTWH(x + 8, y - textPainter.height / 2, textPainter.width + 4, textPainter.height),
        Paint()..color = const Color(0xFF0A1628).withOpacity(0.7),
      );
      textPainter.paint(canvas, Offset(x + 10, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(_SkyplotPainter oldDelegate) {
    return true; // We always want to repaint when lists update
  }
}
