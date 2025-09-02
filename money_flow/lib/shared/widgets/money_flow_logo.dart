import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MoneyFlowLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final Color? textColor;

  const MoneyFlowLogo({
    super.key,
    this.size,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 96;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo basado en el diseño original MoneyFlow
        SizedBox(
          width: logoSize,
          height: logoSize * 0.4, // Proporción más horizontal como el original
          child: CustomPaint(
            painter: MoneyFlowLogoPainter(),
            size: Size(logoSize, logoSize * 0.4),
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'MoneyFlow',
            style: TextStyle(
              fontSize: logoSize * 0.25,
              fontWeight: FontWeight.w900,
              color: textColor ?? AppColors.slate900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class MoneyFlowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Crear el gradiente exacto del SVG original
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF00D4FF), // #00D4FF - Cian
        const Color(0xFF007BFF), // #007BFF - Azul medio  
        const Color(0xFF001D6C), // #001D6C - Azul oscuro
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Escalar las coordenadas del SVG al tamaño del widget
    double scaleX = size.width / 727;
    double scaleY = size.height / 276;

    // Primera onda (shape-13) - convertida de las coordenadas del SVG
    final path1 = Path();
    path1.moveTo(695 * scaleX, 98.586 * scaleY);
    path1.cubicTo(
      672.310 * scaleX, 116.943 * scaleY,
      634.900 * scaleX, 136.417 * scaleY,
      604.142 * scaleX, 145.884 * scaleY,
    );
    path1.cubicTo(
      539.220 * scaleX, 165.867 * scaleY,
      470.308 * scaleX, 164.063 * scaleY,
      376.579 * scaleX, 139.926 * scaleY,
    );
    path1.cubicTo(
      290.060 * scaleX, 117.645 * scaleY,
      266.838 * scaleX, 112.538 * scaleY,
      231.500 * scaleX, 108.017 * scaleY,
    );
    path1.cubicTo(
      169.937 * scaleX, 100.141 * scaleY,
      111.390 * scaleX, 104.532 * scaleY,
      63.097 * scaleX, 120.649 * scaleY,
    );
    path1.cubicTo(
      48.773 * scaleX, 125.429 * scaleY,
      22.428 * scaleX, 136.761 * scaleY,
      23.393 * scaleX, 137.727 * scaleY,
    );
    path1.cubicTo(
      23.614 * scaleX, 137.947 * scaleY,
      27.553 * scaleX, 136.985 * scaleY,
      32.147 * scaleX, 135.589 * scaleY,
    );
    path1.cubicTo(
      68.978 * scaleX, 124.396 * scaleY,
      100.998 * scaleX, 120.472 * scaleY,
      149 * scaleX, 121.269 * scaleY,
    );
    path1.cubicTo(
      176.203 * scaleX, 121.722 * scaleY,
      184.678 * scaleX, 122.234 * scaleY,
      201 * scaleX, 124.413 * scaleY,
    );
    path1.cubicTo(
      242.809 * scaleX, 129.994 * scaleY,
      271.741 * scaleX, 136.597 * scaleY,
      352.500 * scaleX, 158.990 * scaleY,
    );
    path1.cubicTo(
      424.642 * scaleX, 178.994 * scaleY,
      459.265 * scaleX, 185 * scaleY,
      502.432 * scaleX, 185 * scaleY,
    );
    path1.cubicTo(
      549.101 * scaleX, 185 * scaleY,
      586.980 * scaleX, 176.795 * scaleY,
      623 * scaleX, 158.884 * scaleY,
    );
    path1.cubicTo(
      656.046 * scaleX, 142.452 * scaleY,
      673.952 * scaleX, 127.930 * scaleY,
      700.847 * scaleX, 95.750 * scaleY,
    );
    path1.cubicTo(
      703.426 * scaleX, 92.665 * scaleY,
      700.662 * scaleX, 94.005 * scaleY,
      695 * scaleX, 98.586 * scaleY,
    );

    // Segunda onda (shape-14)
    final path2 = Path();
    path2.moveTo(697.437 * scaleX, 119.091 * scaleY);
    path2.cubicTo(
      695.822 * scaleX, 120.792 * scaleY,
      690.225 * scaleX, 125.897 * scaleY,
      685 * scaleX, 130.436 * scaleY,
    );
    path2.cubicTo(
      645.987 * scaleX, 164.330 * scaleY,
      596.798 * scaleX, 187.217 * scaleY,
      546.211 * scaleX, 195.014 * scaleY,
    );
    path2.cubicTo(
      489.260 * scaleX, 203.791 * scaleY,
      436.822 * scaleX, 197.188 * scaleY,
      354.500 * scaleX, 170.872 * scaleY,
    );
    path2.cubicTo(
      304.800 * scaleX, 154.984 * scaleY,
      277.712 * scaleX, 147.395 * scaleY,
      247.777 * scaleX, 140.971 * scaleY,
    );
    path2.cubicTo(
      227.695 * scaleX, 136.662 * scaleY,
      200.682 * scaleX, 133.032 * scaleY,
      185.122 * scaleX, 132.552 * scaleY,
    );
    path2.cubicTo(
      177.630 * scaleX, 132.321 * scaleY,
      172.850 * scaleX, 132.344 * scaleY,
      174.500 * scaleX, 132.604 * scaleY,
    );
    path2.cubicTo(
      212.683 * scaleX, 138.601 * scaleY,
      255.741 * scaleX, 151.921 * scaleY,
      331 * scaleX, 181.015 * scaleY,
    );
    path2.cubicTo(
      399.552 * scaleX, 207.517 * scaleY,
      434.420 * scaleX, 217.122 * scaleY,
      476.400 * scaleX, 221.069 * scaleY,
    );
    path2.cubicTo(
      494.675 * scaleX, 222.787 * scaleY,
      531.124 * scaleX, 221.779 * scaleY,
      546.500 * scaleX, 219.131 * scaleY,
    );
    path2.cubicTo(
      613.733 * scaleX, 207.551 * scaleY,
      671.382 * scaleX, 170.727 * scaleY,
      698.954 * scaleX, 121.750 * scaleY,
    );
    path2.cubicTo(
      702.531 * scaleX, 115.395 * scaleY,
      701.938 * scaleX, 114.354 * scaleY,
      697.437 * scaleX, 119.091 * scaleY,
    );

    // Tercera onda (shape-15)
    final path3 = Path();
    path3.moveTo(77.500 * scaleX, 135.032 * scaleY);
    path3.cubicTo(
      72 * scaleX, 135.530 * scaleY,
      65.025 * scaleX, 136.314 * scaleY,
      62 * scaleX, 136.774 * scaleY,
    );
    path3.cubicTo(
      56.950 * scaleX, 137.541 * scaleY,
      57.605 * scaleX, 137.671 * scaleY,
      70 * scaleX, 138.355 * scaleY,
    );
    path3.cubicTo(
      136.750 * scaleX, 142.037 * scaleY,
      183.362 * scaleX, 155.524 * scaleY,
      302 * scaleX, 205.484 * scaleY,
    );
    path3.cubicTo(
      332.624 * scaleX, 218.381 * scaleY,
      346.346 * scaleX, 223.962 * scaleY,
      359 * scaleX, 228.666 * scaleY,
    );
    path3.cubicTo(
      411.154 * scaleX, 248.058 * scaleY,
      448.936 * scaleX, 256.298 * scaleY,
      492 * scaleX, 257.676 * scaleY,
    );
    path3.cubicTo(
      563.917 * scaleX, 259.976 * scaleY,
      629.430 * scaleX, 236.119 * scaleY,
      673.500 * scaleX, 191.580 * scaleY,
    );
    path3.cubicTo(
      683.181 * scaleX, 181.796 * scaleY,
      696.926 * scaleX, 164.580 * scaleY,
      695.878 * scaleX, 163.551 * scaleY,
    );
    path3.cubicTo(
      695.670 * scaleX, 163.348 * scaleY,
      692.125 * scaleX, 165.895 * scaleY,
      688 * scaleX, 169.212 * scaleY,
    );
    path3.cubicTo(
      671.365 * scaleX, 182.588 * scaleY,
      645.048 * scaleX, 198.629 * scaleY,
      625.283 * scaleX, 207.441 * scaleY,
    );
    path3.cubicTo(
      558.859 * scaleX, 237.053 * scaleY,
      491.333 * scaleX, 240.499 * scaleY,
      410.181 * scaleX, 218.418 * scaleY,
    );
    path3.cubicTo(
      386.614 * scaleX, 212.006 * scaleY,
      361.104 * scaleX, 203.157 * scaleY,
      324.500 * scaleX, 188.697 * scaleY,
    );
    path3.cubicTo(
      272.644 * scaleX, 168.212 * scaleY,
      253.939 * scaleX, 161.624 * scaleY,
      220.500 * scaleX, 152.067 * scaleY,
    );
    path3.cubicTo(
      193.025 * scaleX, 144.215 * scaleY,
      168.801 * scaleX, 139.293 * scaleY,
      144 * scaleX, 136.522 * scaleY,
    );
    path3.cubicTo(
      127.178 * scaleX, 134.643 * scaleY,
      90.798 * scaleX, 133.828 * scaleY,
      77.500 * scaleX, 135.032 * scaleY,
    );

    // Dibujar las tres ondas con el mismo gradiente
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
