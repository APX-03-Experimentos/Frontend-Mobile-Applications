// line_chart_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../assignments/model/assignment.dart';
import '../../assignments/model/submission.dart';
import '../../core/l10n/app_localizations.dart';

class LineChartView extends StatefulWidget {
  final List<Assignment> assignments;
  final List<Submission> submissions;
  final String courseTitle;

  const LineChartView({
    super.key,
    required this.assignments,
    required this.submissions,
    required this.courseTitle,
  });

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends State<LineChartView> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final points = _calculatePoints();
    final List<double> allScores = _getAllScores();
    final double averageScore = allScores.isNotEmpty
        ? allScores.reduce((a, b) => a + b) / allScores.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.gradeDistribution} - ${widget.courseTitle}'), // Usa gradeDistribution
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estadísticas generales
            _buildStatsSummary(averageScore, allScores, appLocalizations),

            const SizedBox(height: 20),

            // Gráfico de líneas
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 20,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final assignment = widget.assignments[spot.x.toInt()];
                          final submissions = widget.submissions
                              .where((s) => s.assignmentId == assignment.id && s.score > 0)
                              .toList();
                          final count = submissions.length;

                          return LineTooltipItem(
                            '${assignment.title}\n${appLocalizations.score}: ${spot.y.toStringAsFixed(1)}\n${appLocalizations.submissions}: $count', // TRADUCIDO
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (event, response) {
                      if (response?.lineBarSpots != null) {
                        setState(() {
                          _touchedIndex = response!.lineBarSpots!.first.x.toInt();
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
                        reservedSize: widget.assignments.length > 5 ? 60 : 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= widget.assignments.length) return const SizedBox();
                          final title = widget.assignments[index].title;
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
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: 4,
                    getDrawingHorizontalLine: (value) {
                      if (value == averageScore) {
                        return FlLine(
                          color: Colors.green,
                          strokeWidth: 2,
                          dashArray: [5, 5],
                        );
                      }
                      return FlLine(
                        color: Colors.grey[200],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      barWidth: 3,
                      color: Colors.purple,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: _touchedIndex == index ? 6 : 4,
                            color: Colors.purple,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                      ),
                      aboveBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Leyenda y controles
            _buildLegendControls(averageScore, appLocalizations),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _calculatePoints() {
    final points = <FlSpot>[];
    for (var i = 0; i < widget.assignments.length; i++) {
      final assignment = widget.assignments[i];
      final assignmentSubmissions = widget.submissions
          .where((s) => s.assignmentId == assignment.id && s.score > 0)
          .toList();
      final avgScore = assignmentSubmissions.isEmpty
          ? 0.0
          : assignmentSubmissions.map((s) => s.score).reduce((a, b) => a + b) / assignmentSubmissions.length;
      points.add(FlSpot(i.toDouble(), avgScore));
    }
    return points;
  }

  List<double> _getAllScores() {
    return widget.submissions
        .where((s) => s.score > 0)
        .map((s) => s.score.toDouble())
        .toList();
  }

  Widget _buildStatsSummary(double averageScore, List<double> allScores, AppLocalizations l10n) {
    final maxScore = allScores.isNotEmpty ? allScores.reduce((a, b) => a > b ? a : b) : 0.0;
    final minScore = allScores.isNotEmpty ? allScores.reduce((a, b) => a < b ? a : b) : 0.0;
    final totalGraded = allScores.length;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statistics, // Cambiado de 'Estadísticas generales'
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(l10n.average, averageScore.toStringAsFixed(1), Icons.trending_up, Colors.purple),
                _buildStatItem(l10n.maximum, maxScore.toStringAsFixed(1), Icons.arrow_upward, Colors.green), // Cambiado
                _buildStatItem(l10n.minimum, minScore.toStringAsFixed(1), Icons.arrow_downward, Colors.orange), // Cambiado
                _buildStatItem(l10n.graded, totalGraded.toString(), Icons.grade, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildLegendControls(double averageScore, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.information, // Usa el getter 'information'
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(l10n.mainLine, Colors.purple, Icons.show_chart), // Cambiado
                _buildInfoItem(l10n.average, Colors.green, Icons.horizontal_rule),
                _buildInfoItem(l10n.dataPoints, Colors.white, Icons.circle), // Cambiado
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${l10n.average} general: ${averageScore.toStringAsFixed(2)}/20',
                style: TextStyle(
                  fontSize: 12,
                  color: _getScoreColor(averageScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 16) return Colors.green;
    if (score >= 14) return Colors.orange;
    return Colors.red;
  }

  String _truncateText(String text, int maxLength) {
    return text.length <= maxLength ? text : '${text.substring(0, maxLength)}...';
  }
}