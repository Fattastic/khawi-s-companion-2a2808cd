import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/features/matching/domain/matching_gateway.dart';
import 'package:khawi_flutter/features/smart_commute/domain/smart_commute_prefs.dart';
import 'package:khawi_flutter/state/providers.dart';

class SmartCommuteScreen extends ConsumerStatefulWidget {
  const SmartCommuteScreen({super.key});

  @override
  ConsumerState<SmartCommuteScreen> createState() => _SmartCommuteScreenState();
}

class _SmartCommuteScreenState extends ConsumerState<SmartCommuteScreen> {
  late final TextEditingController _originLat;
  late final TextEditingController _originLng;
  late final TextEditingController _destLat;
  late final TextEditingController _destLng;

  bool _womenOnly = false;
  int _maxResults = 10;
  bool _loading = false;
  String? _error;
  List<Match> _matches = const <Match>[];

  @override
  void initState() {
    super.initState();
    final defaults = defaultSmartCommutePrefs();
    _originLat =
        TextEditingController(text: defaults.originLat.toStringAsFixed(4));
    _originLng =
        TextEditingController(text: defaults.originLng.toStringAsFixed(4));
    _destLat = TextEditingController(text: defaults.destLat.toStringAsFixed(4));
    _destLng = TextEditingController(text: defaults.destLng.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _originLat.dispose();
    _originLng.dispose();
    _destLat.dispose();
    _destLng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGreen,
      appBar: AppBar(
        title: Text(isRtl ? 'التنقل الذكي' : 'Smart Commute'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildConfigCard(context, isRtl),
          const SizedBox(height: 16),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 8),
          _buildResults(context, isRtl),
        ],
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'إعدادات المطابقة' : 'Matching Preferences',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _coordinateField(
                      _originLat, isRtl ? 'انطلاق (خط العرض)' : 'Origin lat',),),
              const SizedBox(width: 10),
              Expanded(
                  child: _coordinateField(
                      _originLng, isRtl ? 'انطلاق (خط الطول)' : 'Origin lng',),),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _coordinateField(
                      _destLat, isRtl ? 'وجهة (خط العرض)' : 'Destination lat',),),
              const SizedBox(width: 10),
              Expanded(
                  child: _coordinateField(
                      _destLng, isRtl ? 'وجهة (خط الطول)' : 'Destination lng',),),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _womenOnly,
            contentPadding: EdgeInsets.zero,
            title: Text(isRtl ? 'رحلات نسائية فقط' : 'Women-only rides'),
            onChanged: (value) => setState(() => _womenOnly = value),
          ),
          const SizedBox(height: 4),
          Text(
            isRtl ? 'أقصى نتائج: $_maxResults' : 'Max results: $_maxResults',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _maxResults.toDouble(),
            min: 3,
            max: 20,
            divisions: 17,
            label: _maxResults.toString(),
            onChanged: (v) => setState(() => _maxResults = v.round()),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _runSmartMatch,
              icon: const Icon(Icons.auto_awesome),
              label: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isRtl ? 'تشغيل المطابقة الذكية' : 'Run Smart Match'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coordinateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool isRtl) {
    if (_matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Text(
          isRtl
              ? 'لا توجد نتائج بعد. شغّل المطابقة الذكية.'
              : 'No results yet. Run Smart Match.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: _matches
          .map(
            (match) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryGreen.withValues(alpha: 0.12),
                  child: Text(
                    match.score.toString(),
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  '${match.trip.originLabel ?? (isRtl ? 'انطلاق' : 'Origin')} → ${match.trip.destLabel ?? (isRtl ? 'وجهة' : 'Destination')}',
                ),
                subtitle: Text(
                  '${isRtl ? 'احتمال القبول' : 'Accept probability'}: ${(match.acceptProbability * 100).toStringAsFixed(0)}%\n${match.explanationTags.join(' • ')}',
                ),
                isThreeLine: true,
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> _runSmartMatch() async {
    final originLat = double.tryParse(_originLat.text.trim());
    final originLng = double.tryParse(_originLng.text.trim());
    final destLat = double.tryParse(_destLat.text.trim());
    final destLng = double.tryParse(_destLng.text.trim());

    if (originLat == null ||
        originLng == null ||
        destLat == null ||
        destLng == null) {
      setState(() => _error = 'Enter valid coordinates');
      return;
    }

    final prefs = SmartCommutePrefs(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      maxResults: _maxResults,
      womenOnly: _womenOnly,
      departureTime: DateTime.now().add(const Duration(minutes: 30)),
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final matches = await ref.read(matchingGatewayProvider).smartMatch(
            prefs.toMatchRequest(),
          );
      if (!mounted) return;
      setState(() => _matches = matches);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
