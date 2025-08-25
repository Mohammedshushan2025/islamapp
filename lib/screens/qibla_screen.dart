import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:animate_do/animate_do.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FlutterQiblah.qiblahStream,
        builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("خطأ: لا يمكن تحديد الاتجاه. تأكد من تفعيل المستشعرات والموقع."));
          }

          final qiblahDirection = snapshot.data!;
          final angle = qiblahDirection.direction * (pi / 180) * -1;
          final qiblahAngle = qiblahDirection.qiblah * (pi / 180) * -1;

          return Center(
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "درجة القبلة: ${qiblahDirection.qiblah.toStringAsFixed(2)}°",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Transform.rotate(
                      angle: angle,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // جسم البوصلة المرسوم بالكود
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade300,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(5, 5),
                                )
                              ],
                            ),
                          ),
                          // إطار البوصلة
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 5,
                              ),
                            ),
                          ),
                          // مؤشر اتجاه القبلة (شكل الكعبة)
                          Transform.rotate(
                            angle: qiblahAngle - angle, // طرح زاوية الجهاز للحفاظ على اتجاه الكعبة ثابتًا
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.mosque_rounded, // أيقونة الكعبة
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                  shadows: [
                                    Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // إبرة البوصلة التي تشير للشمال
                          Transform.rotate(
                            angle: pi, // لجعل الرأس الأحمر يشير للشمال
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: _CompassNeedlePainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// كلاس مخصص لرسم إبرة البوصلة
class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // رسم الجزء الشمالي (الأحمر)
    final northPaint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 10)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(northPath, northPaint);

    // رسم الجزء الجنوبي (الرمادي)
    final southPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius - 10)
      ..lineTo(center.dx - 10, center.dy)
      ..lineTo(center.dx + 10, center.dy)
      ..close();
    canvas.drawPath(southPath, southPaint);

    // الدائرة في المنتصف
    final centerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}