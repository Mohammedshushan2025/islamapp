import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamapp/models/adhkar_model.dart';
import 'package:islamapp/widgets/favorite_button.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DhikrViewScreen extends StatefulWidget {
  final AdhkarCategory category;

  const DhikrViewScreen({super.key, required this.category});

  @override
  _DhikrViewScreenState createState() => _DhikrViewScreenState();
}

class _DhikrViewScreenState extends State<DhikrViewScreen> {
  late PageController _pageController;
  late List<int> _currentCounters;
  late List<int> _initialCounters;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initialCounters = widget.category.array.map((d) => d.count).toList();
    _currentCounters = List.from(_initialCounters);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTasbihTap(int index) {
    // إعطاء إحساس بالضغط
    HapticFeedback.lightImpact();

    if (_currentCounters[index] > 0) {
      setState(() {
        _currentCounters[index]--;
      });
    }

    // عندما ينتهي العد، انتقل للصفحة التالية تلقائيًا
    if (_currentCounters[index] == 0) {
      if (index < widget.category.array.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        // يمكنك إظهار رسالة عند الانتهاء من كل الأذكار
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تقبل الله، لقد أتممت أذكارك.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.category),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.category.array.length,
        itemBuilder: (context, index) {
          final dhikr = widget.category.array[index];
          final initialCount = _initialCounters[index];
          final currentCount = _currentCounters[index];
          final percent =
          initialCount > 0 ? (initialCount - currentCount) / initialCount : 1.0;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- نص الذكر ---
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      dhikr.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, height: 1.8),
                    ),
                  ),
                ),
                // --- زر التسبيح التفاعلي ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: GestureDetector(
                    onTap: () => _onTasbihTap(index),
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 10.0,
                      percent: percent,
                      center: Text(
                        "$currentCount",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 50),
                      ),
                      progressColor: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                      animateFromLastPercent: true,
                      animation: true,
                    ),
                  ),
                ),
                // --- زر المفضلة ورقم الصفحة ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FavoriteButton(
                      identifier: 'dhikr_${widget.category.id}_${dhikr.id}',
                      content: dhikr.text,
                    ),
                    Text(
                      '${index + 1} / ${widget.category.array.length}',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}