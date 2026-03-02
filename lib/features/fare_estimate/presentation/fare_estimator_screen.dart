import 'package:flutter/material.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/fare_estimate/domain/fare_estimate.dart';

class FareEstimatorScreen extends StatefulWidget {
  const FareEstimatorScreen({super.key});

  @override
  State<FareEstimatorScreen> createState() => _FareEstimatorScreenState();
}

class _FareEstimatorScreenState extends State<FareEstimatorScreen> {
  final TextEditingController _distanceController =
      TextEditingController(text: '18');
  final TextEditingController _durationController =
      TextEditingController(text: '28');
  int _seatCount = 2;

  FareEstimate get _estimate {
    final distance = double.tryParse(_distanceController.text.trim()) ?? 0;
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    return calculateFareEstimate(
      distanceKm: distance,
      durationMinutes: duration,
      seatCount: _seatCount,
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final estimate = _estimate;

    String tr(String en, String ar) => isRtl ? ar : en;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(tr('Fare Estimator', 'حاسبة تقدير الأجرة')),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Trip Inputs', 'بيانات الرحلة'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _distanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: tr('Distance (km)', 'المسافة (كم)'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: tr('Duration (minutes)', 'المدة (دقائق)'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        tr('Passengers sharing ride', 'عدد الركاب المشاركين'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _seatCount > 1
                            ? () => setState(() => _seatCount--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_seatCount',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _seatCount < 6
                            ? () => setState(() => _seatCount++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Estimated Breakdown', 'تفاصيل التقدير'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _line(
                    context,
                    tr('Base fare', 'الأجرة الأساسية'),
                    estimate.baseFareSar,
                  ),
                  _line(
                    context,
                    tr('Distance cost', 'تكلفة المسافة'),
                    estimate.distanceFareSar,
                  ),
                  _line(
                    context,
                    tr('Time cost', 'تكلفة الوقت'),
                    estimate.timeFareSar,
                  ),
                  const Divider(height: 24),
                  _line(
                    context,
                    tr('Total fare', 'الأجرة الإجمالية'),
                    estimate.totalFareSar,
                    emphasized: true,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tr('Per passenger', 'لكل راكب')}: ${estimate.perPassengerFareSar.toStringAsFixed(2)} SAR',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    double value, {
    bool emphasized = false,
  }) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text('${value.toStringAsFixed(2)} SAR', style: style),
        ],
      ),
    );
  }
}
