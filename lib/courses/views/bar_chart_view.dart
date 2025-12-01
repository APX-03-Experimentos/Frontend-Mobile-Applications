// bar_chart_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/l10n/app_localizations.dart';

class BarChartView extends StatefulWidget {
  final Map<String, int> submissionsPerAssignment;
  final String courseTitle;

  const BarChartView({
    super.key,
    required this.submissionsPerAssignment,
    required this.courseTitle,
  });

  @override
  State<BarChartView> createState() => _BarChartViewState();
}

class _BarChartViewState extends State<BarChartView> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final entries = widget.submissionsPerAssignment.entries.toList();
    final maxY = entries.isEmpty ? 1.0 : entries.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.submissionsPerAssignment} - ${widget.courseTitle}'), // ✅ TRADUCIDO
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estadísticas resumen
            _buildStatsSummary(entries, appLocalizations),

            const SizedBox(height: 20),

            // Gráfico de barras
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + (maxY * 0.1), // Agregar 10% de margen
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final entry = entries[group.x.toInt()];
                        // Usar los métodos deliverySingular y deliveryPlural
                        final entregasText = entry.value == 1
                            ? appLocalizations.deliverySingular('1')
                            : appLocalizations.deliveryPlural(entry.value.toString());

                        return BarTooltipItem(
                          '${entry.key}\n$entregasText',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response?.spot != null) {
                        setState(() {
                          _touchedIndex = response!.spot!.touchedBarGroupIndex;
                        });
                      }
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: entries.length > 5 ? 60 : 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= entries.length) return const SizedBox();
                          final title = entries[index].key;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  _truncateText(title, 15),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _touchedIndex == index ? Colors.purple : Colors.grey,
                                    fontWeight: _touchedIndex == index ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 10 ? (maxY / 5) : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: entries.mapIndexed((i, entry) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          color: _touchedIndex == i
                              ? Colors.purpleAccent
                              : Colors.purple,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: Colors.grey[100],
                          ),
                        ),
                      ],
                      showingTooltipIndicators: _touchedIndex == i ? [0] : [],
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

  Widget _buildStatsSummary(List<MapEntry<String, int>> entries, AppLocalizations l10n) {
    if (entries.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: Text(l10n.noSubmissions)), // ✅ TRADUCIDO
        ),
      );
    }

    final totalSubmissions = entries.map((e) => e.value).reduce((a, b) => a + b);
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
              l10n.submissionsPerAssignment, // ✅ TRADUCIDO
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(l10n.totalSubmissions, '$totalSubmissions', Icons.summarize, Colors.blue, l10n),
                _buildStatItem(l10n.maxDeliveries, // ✅ Usando el getter
                    '${maxEntry.value}\n${_truncateText(maxEntry.key, 10)}',
                    Icons.arrow_upward, Colors.green, l10n),
                _buildStatItem(l10n.minDeliveries, // ✅ Usando el getter
                    '${minEntry.value}\n${_truncateText(minEntry.key, 10)}',
                    Icons.arrow_downward, Colors.orange, l10n),
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

  Widget _buildLegend(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.legend, // ✅ Usando el getter de legend
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(l10n.moreDeliveries, Colors.purple), // ✅ Usando el getter
                _buildLegendItem(l10n.selected, Colors.purpleAccent), // ✅ Usando el getter
                _buildLegendItem(l10n.average, Colors.grey[300]!), // ✅ Usando el getter existente de average
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var i = 0;
    for (final e in this) yield f(i++, e);
  }
}