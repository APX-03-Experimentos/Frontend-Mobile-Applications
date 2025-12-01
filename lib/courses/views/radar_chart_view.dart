// radar_chart_view.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../assignments/model/submission.dart';
import '../../assignments/model/assignment.dart';
import '../../core/l10n/app_localizations.dart';

class RadarChartView extends StatefulWidget {
  final List<Submission> submissions;
  final List<Assignment> assignments;
  final String courseTitle;

  const RadarChartView({
    super.key,
    required this.submissions,
    required this.assignments,
    required this.courseTitle,
  });

  @override
  State<RadarChartView> createState() => _RadarChartViewState();
}

class _RadarChartViewState extends State<RadarChartView> {
  int _selectedIndicator = 0;
  final List<String> _indicators = [];
  late Map<String, double> _calculatedIndicators;

  @override
  void initState() {
    super.initState();
    _initializeIndicators();
    _calculatedIndicators = _calculateIndicators();
  }

  void _initializeIndicators() {
    _indicators.clear();
    _indicators.addAll([
      'Delivery Rate',
      'Average Quality',
      'Completeness',
      'Consistency',
      'Participation',
      'Efficiency'
    ]);
  }

  // Calcular todos los indicadores basados en datos reales
  Map<String, double> _calculateIndicators() {
    final submissions = widget.submissions;
    final assignments = widget.assignments;

    final totalAssignments = assignments.length;
    final totalSubmissions = submissions.length;

    // Submissions calificados (score > 0)
    final gradedSubmissions = submissions.where((s) => s.score > 0).toList();
    final totalGraded = gradedSubmissions.length;

    // 1. Tasa de Entrega (submissions vs assignments)
    final deliveryRate = totalAssignments > 0
        ? (totalSubmissions / (totalAssignments * 5.0)) * 100
        : 0.0; // Suponiendo 5 estudiantes por asignación

    // 2. Calidad Promedio (score normalizado 0-100)
    final averageScore = totalGraded > 0
        ? gradedSubmissions.map((s) => s.score).reduce((a, b) => a + b) / totalGraded
        : 0.0;
    final normalizedScore = (averageScore / 20.0) * 100;

    // 3. Completitud (submissions con contenido completo)
    final completeSubmissions = submissions.where((s) =>
    s.content.isNotEmpty || s.imageUrl.isNotEmpty || s.fileUrls.isNotEmpty).length;
    final completenessRate = totalSubmissions > 0
        ? (completeSubmissions / totalSubmissions) * 100
        : 0.0;

    // 4. Consistencia (variación de scores)
    double consistency = 0.0;
    if (totalGraded > 1) {
      final scores = gradedSubmissions.map((s) => s.score.toDouble()).toList();
      final mean = scores.reduce((a, b) => a + b) / totalGraded;
      final variance = scores.map((score) => (score - mean) * (score - mean))
          .reduce((a, b) => a + b) / totalGraded;
      final stdDev = sqrt(variance);  // Usando sqrt de dart:math
      consistency = stdDev == 0 ? 100 : 100 - (stdDev * 10).clamp(0.0, 100.0);
    } else if (totalGraded == 1) {
      consistency = 100.0;
    }

    // 5. Participación (submissions únicos por assignment)
    final uniqueAssignments = submissions.map((s) => s.assignmentId).toSet().length;
    final participationRate = totalAssignments > 0
        ? (uniqueAssignments / totalAssignments) * 100
        : 0.0;

    // 6. Eficiencia (promedio de scores en submissions entregados a tiempo)
    final timelySubmissions = submissions.where((s) => _isSubmissionTimely(s)).toList();
    double efficiency = 0.0;
    if (timelySubmissions.isNotEmpty) {
      final timelyScores = timelySubmissions.where((s) => s.score > 0).map((s) => s.score).toList();
      if (timelyScores.isNotEmpty) {
        final avgTimelyScore = timelyScores.reduce((a, b) => a + b) / timelyScores.length;
        efficiency = (avgTimelyScore / 20.0) * 100;
      }
    }

    return {
      'Delivery Rate': deliveryRate.clamp(0.0, 100.0),
      'Average Quality': normalizedScore.clamp(0.0, 100.0),
      'Completeness': completenessRate.clamp(0.0, 100.0),
      'Consistency': consistency.clamp(0.0, 100.0),
      'Participation': participationRate.clamp(0.0, 100.0),
      'Efficiency': efficiency.clamp(0.0, 100.0),
    };
  }

  // Determinar si una entrega fue a tiempo
  bool _isSubmissionTimely(Submission submission) {
    // Buscar el assignment correspondiente
    final assignment = widget.assignments.firstWhere(
          (a) => a.id == submission.assignmentId,
      orElse: () => Assignment(
        id: 0,
        title: '',
        description: '',
        courseId: 0,
        imageUrl: '',
      ),
    );

    // Si no hay deadline, considerar como a tiempo
    if (assignment.deadline == null) return true;

    // Como no hay campo submittedAt, asumimos que todas son a tiempo
    // En una versión futura, podrías agregar submittedAt al modelo Submission
    return true;
  }

  // Calcular estadísticas generales
  Map<String, dynamic> _calculateGeneralStats() {
    final submissions = widget.submissions;
    final assignments = widget.assignments;

    final totalAssignments = assignments.length;
    final totalSubmissions = submissions.length;
    final gradedSubmissions = submissions.where((s) => s.score > 0).toList();
    final totalGraded = gradedSubmissions.length;

    final averageScore = totalGraded > 0
        ? gradedSubmissions.map((s) => s.score).reduce((a, b) => a + b) / totalGraded
        : 0.0;

    final uniqueStudents = submissions.map((s) => s.studentId).toSet().length;
    final uniqueAssignments = submissions.map((s) => s.assignmentId).toSet().length;

    return {
      'totalAssignments': totalAssignments,
      'totalSubmissions': totalSubmissions,
      'gradedSubmissions': totalGraded,
      'averageScore': averageScore,
      'uniqueStudents': uniqueStudents,
      'uniqueAssignments': uniqueAssignments,
      'submissionRate': totalAssignments > 0
          ? ((uniqueAssignments / totalAssignments) * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final generalStats = _calculateGeneralStats();

    // Preparar datos para el gráfico
    final radarEntries = _indicators.map((indicator) {
      return RadarEntry(
        value: _calculatedIndicators[indicator] ?? 0.0,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.statistics} - ${widget.courseTitle}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Agregado para evitar overflow
          child: Column(
            children: [
              // Estadísticas generales
              _buildGeneralStats(generalStats, appLocalizations),

              const SizedBox(height: 20),

              // Gráfico de radar
              Container(
                height: 300, // Altura fija para el gráfico
                padding: const EdgeInsets.all(16.0),
                child: RadarChart(
                  RadarChartData(
                    dataSets: [
                      RadarDataSet(
                        dataEntries: radarEntries,
                        fillColor: Colors.purple.withOpacity(0.2),
                        borderColor: Colors.purple,
                        borderWidth: 2,
                        entryRadius: 5,
                      ),
                    ],
                    radarShape: RadarShape.polygon,
                    radarBorderData: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                    gridBorderData: const BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    titlePositionPercentageOffset: 0.15,
                    titleTextStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    getTitle: (index, angle) {
                      return RadarChartTitle(
                          text: _getTranslatedIndicator(_indicators[index], appLocalizations),
                          angle: angle
                      );
                    },
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 500),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),

              // Indicadores detallados
              _buildIndicatorsDetail(appLocalizations),
            ],
          ),
        ),
      ),
    );
  }

  // Método para obtener las traducciones de los indicadores
  String _getTranslatedIndicator(String indicator, AppLocalizations l10n) {
    final Map<String, String> translations = {
      'Delivery Rate': l10n.deliveryRate,
      'Average Quality': l10n.averageQuality,
      'Completeness': l10n.completeness,
      'Consistency': l10n.consistency,
      'Participation': l10n.participation,
      'Efficiency': l10n.efficiency,
    };
    return translations[indicator] ?? indicator;
  }

  Widget _buildGeneralStats(Map<String, dynamic> stats, AppLocalizations l10n) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.courseSummary, // Traducido
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(l10n.totalAssignments, '${stats['totalAssignments']}', Colors.blue, l10n),
                _buildStatCard(l10n.totalSubmissions, '${stats['totalSubmissions']}', Colors.green, l10n),
                _buildStatCard(l10n.graded, '${stats['gradedSubmissions']}', Colors.orange, l10n),
                _buildStatCard(l10n.average, '${stats['averageScore'].toStringAsFixed(1)}', Colors.purple, l10n),
                _buildStatCard(l10n.student, '${stats['uniqueStudents']}', Colors.teal, l10n),
                _buildStatCard(l10n.submissionRate, '${stats['submissionRate']}%', Colors.red, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsDetail(AppLocalizations l10n) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceIndicators, // Traducido
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            ..._indicators.map((indicator) {
              final value = _calculatedIndicators[indicator] ?? 0.0;
              final color = _getColorForValue(value);
              final translatedIndicator = _getTranslatedIndicator(indicator, l10n);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translatedIndicator,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: value / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      child: Text(
                        '${value.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getColorForValue(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }
}