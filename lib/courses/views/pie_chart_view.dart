// pie_chart_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/l10n/app_localizations.dart';

class PieChartView extends StatefulWidget {
  final Map<String, int> gradeDistribution;
  final String courseTitle;

  const PieChartView({
    super.key,
    required this.gradeDistribution,
    required this.courseTitle,
  });

  @override
  State<PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends State<PieChartView> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final total = widget.gradeDistribution.values.isEmpty
        ? 1
        : widget.gradeDistribution.values.reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.gradeDistributionChart} - ${widget.courseTitle}'), // ✅ TRADUCIDO
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estadísticas generales
            _buildStatsSummary(total, appLocalizations),

            const SizedBox(height: 20),

            // Gráfico de pastel
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback: (event, touchResponse) {
                      setState(() {
                        if (event is FlTapUpEvent && touchResponse != null) {
                          _touchedIndex = touchResponse.touchedSection!.touchedSectionIndex;
                        } else {
                          _touchedIndex = -1;
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: widget.gradeDistribution.entries.mapIndexed((index, entry) {
                    final isTouched = index == _touchedIndex;
                    final fontSize = isTouched ? 16.0 : 14.0;
                    final radius = isTouched ? 70.0 : 60.0;

                    final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
                    final color = _getColorForGrade(entry.key, appLocalizations);

                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: color,
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: isTouched ? [const Shadow(color: Colors.black, blurRadius: 2)] : [],
                      ),
                      badgeWidget: _buildBadge(entry.key, entry.value, appLocalizations),
                      badgePositionPercentageOffset: isTouched ? 1.4 : 1.2,
                    );
                  }).toList(),
                ),
              ),
            ),

            // Leyenda
            _buildLegend(appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(int total, AppLocalizations l10n) {
    final entries = widget.gradeDistribution.entries.toList();
    if (entries.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(l10n.noGradesToDisplay)), // ✅ TRADUCIDO
        ),
      );
    }

    final maxEntry = entries.reduce((a, b) => a.value > b.value ? a : b);
    final minEntry = entries.reduce((a, b) => a.value < b.value ? a : b);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.distributionSummary, // ✅ TRADUCIDO
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(l10n.total, '$total', Icons.summarize, Colors.blue, l10n),
                _buildStatItem(l10n.mostCommonRange, maxEntry.key, Icons.arrow_upward, Colors.green, l10n),
                _buildStatItem(l10n.leastCommonRange, minEntry.key, Icons.arrow_downward, Colors.orange, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBadge(String grade, int count, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getColorForGrade(grade, l10n),
        ),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.legend, // ✅ TRADUCIDO
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: widget.gradeDistribution.entries.map((entry) {
                final color = _getColorForGrade(entry.key, l10n);
                final percentage = widget.gradeDistribution.values.isEmpty
                    ? 0.0
                    : (entry.value / widget.gradeDistribution.values.reduce((a, b) => a + b) * 100);

                // Traducir el rango de calificaciones si es posible
                String translatedRange = _translateGradeRange(entry.key, l10n);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$translatedRange: ${entry.value}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForGrade(String grade, AppLocalizations l10n) {
    // Usar traducciones para los rangos
    if (grade == l10n.range1720 || grade == '17-20') return Colors.green;
    if (grade == l10n.range1416 || grade == '14-16') return Colors.orange;
    if (grade == l10n.range013 || grade == '0-13') return Colors.red;
    return Colors.blue;
  }

  String _translateGradeRange(String range, AppLocalizations l10n) {
    switch (range) {
      case '17-20':
        return l10n.range1720;
      case '14-16':
        return l10n.range1416;
      case '0-13':
        return l10n.range013;
      default:
        return range;
    }
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var i = 0;
    for (final e in this) yield f(i++, e);
  }
}