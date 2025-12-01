// course_statistics_view.dart
import 'package:flutter/material.dart';
import 'package:learnhive_mobile/courses/views/pie_chart_view.dart';
import 'package:learnhive_mobile/courses/views/radar_chart_view.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/courses/model/course.dart';
import 'package:learnhive_mobile/assignments/viewmodels/assignment_viewmodel.dart';
import '../../assignments/viewmodels/submission_viewmodel.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import 'bar_chart_view.dart';
import 'line_chart_view.dart';

class CourseStatisticsView extends StatefulWidget {
  final Course course;

  const CourseStatisticsView({
    super.key,
    required this.course,
  });

  @override
  State<CourseStatisticsView> createState() => _CourseStatisticsViewState();
}

class _CourseStatisticsViewState extends State<CourseStatisticsView> {
  late AssignmentViewModel _assignmentVm;
  late SubmissionViewModel _submissionVm;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    // ✅ ENVOLVER CON CONSUMER PARA LAS TRADUCCIONES
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final appLocalizations = AppLocalizations.of(context);

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = _calculateStatistics();

        return Scaffold(
          appBar: AppBar(
            title: Text('${appLocalizations.statistics} - ${widget.course.title}'), // ✅ TRADUCIDO
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatisticsCard(
                      appLocalizations.totalAssignments, // ✅ TRADUCIDO
                      stats['totalAssignments'].toString(),
                      Icons.assignment,
                      Colors.blue,
                    ),
                    _buildStatisticsCard(
                      appLocalizations.totalSubmissions, // ✅ TRADUCIDO
                      stats['totalSubmissions'].toString(),
                      Icons.summarize,
                      Colors.green,
                    ),
                    _buildStatisticsCard(
                      appLocalizations.graded, // ✅ TRADUCIDO
                      stats['gradedSubmissions'].toString(),
                      Icons.grade,
                      Colors.orange,
                    ),
                    _buildStatisticsCard(
                      appLocalizations.average, // ✅ TRADUCIDO
                      '${stats['averageScore'].toStringAsFixed(1)}/20',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildGradeDistribution(stats['gradeDistribution'], appLocalizations), // ✅ PASAR TRADUCCIONES
                const SizedBox(height: 20),
                _buildSubmissionsChart(stats['submissionsPerAssignment'], appLocalizations), // ✅ PASAR TRADUCCIONES

                const SizedBox(height: 20),
                Text(
                  appLocalizations.chooseChart, // ✅ TRADUCIDO "Elige un gráfico"
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildChartButton(
                      appLocalizations.pieChart, // ✅ TRADUCIDO
                      Icons.pie_chart,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PieChartView(
                            gradeDistribution: stats['gradeDistribution'],
                            courseTitle: widget.course.title,
                          ),
                        ),
                      ),
                    ),
                    _buildChartButton(
                      appLocalizations.barChart, // ✅ TRADUCIDO
                      Icons.bar_chart,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarChartView(
                            submissionsPerAssignment: stats['submissionsPerAssignment'],
                            courseTitle: widget.course.title,
                          ),
                        ),
                      ),
                    ),
                    _buildChartButton(
                      appLocalizations.lineChart, // ✅ TRADUCIDO
                      Icons.show_chart,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LineChartView(
                            assignments: _assignmentVm.assignments,
                            submissions: _submissionVm.submissions,
                            courseTitle: widget.course.title,
                          ),
                        ),
                      ),
                    ),
                    _buildChartButton(
                      appLocalizations.radarChart, // ✅ TRADUCIDO
                      Icons.multiline_chart,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RadarChartView(
                            submissions: _submissionVm.submissions,  // Todas las submissions
                            assignments: _assignmentVm.assignments,  // Todas las assignments
                            courseTitle: widget.course.title,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.purple),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _assignmentVm = context.read<AssignmentViewModel>();
      _submissionVm = context.read<SubmissionViewModel>();

      // Cargar assignments del curso
      await _assignmentVm.getAssignmentsByCourseId(widget.course.courseId);

      // Cargar submissions del curso
      await _submissionVm.getSubmissionsByCourseId(widget.course.courseId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calcular estadísticas
  Map<String, dynamic> _calculateStatistics() {
    final assignments = _assignmentVm.assignments;
    final submissions = _submissionVm.submissions;

    // Filtramos submissions calificados (con score > 0)
    final gradedSubmissions = submissions.where((s) => s.score > 0).toList();

    // Promedio general - CORREGIDO: Mostrar en escala 0-20
    final averageScore = gradedSubmissions.isEmpty ? 0.0 :
    gradedSubmissions.map((s) => s.score).reduce((a, b) => a + b) / gradedSubmissions.length;

    // Distribución de calificaciones - CORREGIDO: Sistema 0-20
    final gradeDistribution = {
      '17-20': gradedSubmissions.where((s) => s.score >= 17 && s.score <= 20).length, // ← Cambiado a <= 20
      '14-16': gradedSubmissions.where((s) => s.score >= 14 && s.score < 17).length,
      '0-13': gradedSubmissions.where((s) => s.score >= 0 && s.score < 14).length,
    };

    // Submissions por assignment
    final submissionsPerAssignment = <String, int>{};
    for (final assignment in assignments) {
      final count = submissions.where((s) => s.assignmentId == assignment.id).length;
      submissionsPerAssignment[assignment.title] = count;
    }

    return {
      'totalAssignments': assignments.length,
      'totalSubmissions': submissions.length,
      'gradedSubmissions': gradedSubmissions.length,
      'ungradedSubmissions': submissions.length - gradedSubmissions.length,
      'averageScore': averageScore,
      'gradeDistribution': gradeDistribution,
      'submissionsPerAssignment': submissionsPerAssignment,
    };
  }

  Widget _buildStatisticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistribution(Map<String, int> distribution, AppLocalizations appLocalizations) {
    final total = distribution.values.reduce((a, b) => a + b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.gradeDistribution, // ✅ TRADUCIDO
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_getGradeColor(entry.key)),
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

  Color _getGradeColor(String grade) {
    switch (grade) {
      case '17-20': return Colors.green;
      case '14-16': return Colors.orange;
      case '0-13': return Colors.deepOrange;
      default: return Colors.blue;
    }
  }

  Widget _buildSubmissionsChart(Map<String, int> submissionsPerAssignment, AppLocalizations appLocalizations) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.submissionsPerAssignment, // ✅ TRADUCIDO
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (submissionsPerAssignment.isEmpty)
              Center(
                child: Text(
                  appLocalizations.noSubmissions, // ✅ TRADUCIDO
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              ...submissionsPerAssignment.entries.map((entry) {
                final maxValue = submissionsPerAssignment.values.reduce((a, b) => a > b ? a : b);
                final progressValue = maxValue > 0 ? entry.value / maxValue : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progressValue, // ← Usar el valor calculado seguro
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${entry.value}'),
                          ],
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
}