import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  const SimulatorScreen({super.key});

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen>
    with SingleTickerProviderStateMixin {
  HabitModel? _selectedHabit;
  double _reductionPct = 50;
  double _rateOfReturn = 10;
  int _years = 10;
  late AnimationController _chartCtrl;
  late Animation<double> _chartAnim;
  int _equivalentIdx = 0;

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartAnim = CurvedAnimation(parent: _chartCtrl, curve: Curves.easeOut);
    _chartCtrl.forward();

    // Rotate equivalents
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      setState(() => _equivalentIdx = (_equivalentIdx + 1) % _equivalents.length);
      return true;
    });
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    super.dispose();
  }

  double get _monthlySaving {
    if (_selectedHabit == null) return 0;
    return _selectedHabit!.monthlyTotal * (_reductionPct / 100);
  }

  double get _futureValue {
    if (_monthlySaving <= 0) return 0;
    final r = _rateOfReturn / 100 / 12;
    final n = _years * 12;
    return _monthlySaving * ((pow(1 + r, n) - 1) / r) * (1 + r);
  }


  List<String> get _equivalents {
    final fv = _futureValue;
    return [
      '= ${(fv / 12000).toStringAsFixed(0)} months of rent',
      '= ${(fv / 280000).toStringAsFixed(1)} Royal Enfield Himalayans',
      '= ${(fv / 150000).toStringAsFixed(0)} Europe trips',
      '= ${(fv / 649).toStringAsFixed(0)} months of Netflix',
    ];
  }

  void _animateChart() {
    _chartCtrl.reset();
    _chartCtrl.forward();
  }

  void _shareCard() {
    final habitName = _selectedHabit?.name ?? 'my top habit';
    final amount = formatRupeesExact(_futureValue);
    Share.share(
      '🌱 MoodSpend Insight\n\n'
      'If I quit $habitName, I\'d have $amount in $_years years.\n\n'
      'Calculate yours → moodspend.app',
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    if (_selectedHabit == null && habits.isNotEmpty) {
      _selectedHabit = habits.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Future You Simulator', style: AppTextStyles.h3)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What if you changed one habit?', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('See the compounding power of one small change.',
                style: AppTextStyles.bodySecondary),

            const SizedBox(height: 20),

            // ── Habit Selector ────────────────────────────────────────────
            const SectionHeader(title: 'SELECT HABIT'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => AppChip(
                  label: habits[i].name,
                  selected: _selectedHabit?.id == habits[i].id,
                  onTap: () {
                    setState(() => _selectedHabit = habits[i]);
                    _animateChart();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Reduction Slider ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cut this habit by', style: AppTextStyles.h3),
                Text('${_reductionPct.round()}%',
                    style: AppTextStyles.h3.copyWith(color: AppColors.accentLime)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _selectedHabit != null
                  ? 'Skip ~${(_selectedHabit!.frequencyPerMonth * _reductionPct / 100).round()} times/month'
                  : '',
              style: AppTextStyles.caption,
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 4),
              child: Slider(
                value: _reductionPct,
                min: 10,
                max: 100,
                divisions: 9,
                onChanged: (v) {
                  setState(() => _reductionPct = v);
                  _animateChart();
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Investment Rate ────────────────────────────────────────────
            const SectionHeader(title: 'INVESTMENT RATE (SIP)'),
            const SizedBox(height: 10),
            Row(
              children: [8.0, 10.0, 12.0, 15.0].map((rate) {
                final selected = _rateOfReturn == rate;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _rateOfReturn = rate);
                      _animateChart();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentLime.withValues(alpha: 0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.accentLime : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text('${rate.round()}%',
                            style: AppTextStyles.h3.copyWith(
                              color: selected ? AppColors.accentLime : AppColors.textSecondary,
                              fontSize: 14,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Time Horizon ──────────────────────────────────────────────
            const SectionHeader(title: 'TIME HORIZON'),
            const SizedBox(height: 10),
            Row(
              children: [1, 3, 5, 10, 20].map((yr) {
                final selected = _years == yr;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _years = yr);
                      _animateChart();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentLime.withValues(alpha: 0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.accentLime : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text('${yr}yr',
                            style: AppTextStyles.h3.copyWith(
                              color: selected ? AppColors.accentLime : AppColors.textSecondary,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── The Big Number ────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text('You could have', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _chartAnim,
                    builder: (_, __) => Text(
                      formatRupeesExact(_futureValue * _chartAnim.value),
                      style: AppTextStyles.numberLarge.copyWith(fontSize: 36),
                    ),
                  ),
                  Text('in $_years ${_years == 1 ? "year" : "years"}',
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Rotating equivalent
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Center(
                key: ValueKey(_equivalentIdx),
                child: Text(
                  _equivalents.isNotEmpty ? _equivalents[_equivalentIdx % _equivalents.length] : '',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentLime),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Dual Line Chart ───────────────────────────────────────────
            AppCard(
              child: SizedBox(
                height: 200,
                child: AnimatedBuilder(
                  animation: _chartAnim,
                  builder: (_, __) => _DualLineChart(
                    years: _years,
                    monthlySaving: _monthlySaving,
                    rate: _rateOfReturn,
                    progress: _chartAnim.value,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Share Button ──────────────────────────────────────────────
            AppButton(
              label: '📤 Share this insight',
              outline: true,
              onTap: _shareCard,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DualLineChart extends StatelessWidget {
  final int years;
  final double monthlySaving;
  final double rate;
  final double progress;

  const _DualLineChart({
    required this.years,
    required this.monthlySaving,
    required this.rate,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final points = years * 12;
    final r = rate / 100 / 12;
    final showPoints = (points * progress).round().clamp(1, points);

    List<FlSpot> sipSpots = [];
    List<FlSpot> flatSpots = [];
    double sipVal = 0;
    for (int m = 0; m <= showPoints; m++) {
      sipVal = monthlySaving * ((pow(1 + r, m) - 1) / r) * (1 + r);
      final flatVal = monthlySaving * m.toDouble();
      if (m % max(1, (points / 20).round()) == 0 || m == showPoints) {
        sipSpots.add(FlSpot(m / 12.0, sipVal));
        flatSpots.add(FlSpot(m / 12.0, flatVal));
      }
    }

    final maxY = sipSpots.isNotEmpty ? sipSpots.last.y * 1.2 : 1.0;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: years.toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: years <= 5 ? 1 : (years / 4).roundToDouble(),
              getTitlesWidget: (v, _) => Text(
                '${v.round()}yr',
                style: AppTextStyles.micro.copyWith(fontSize: 9),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (v, _) => Text(
                formatRupees(v),
                style: AppTextStyles.micro.copyWith(fontSize: 9),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.border, strokeWidth: 0.5),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 1,
            color: AppColors.accentLime.withValues(alpha: 0.08),
          ),
        ],
        lineBarsData: [
          // SIP (compounding)
          LineChartBarData(
            spots: sipSpots,
            isCurved: true,
            color: AppColors.accentLime,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
          ),
          // Flat (no invest)
          LineChartBarData(
            spots: flatSpots,
            isCurved: false,
            color: AppColors.textMuted,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            dashArray: [6, 3],
          ),
        ],
      ),
    );
  }
}
