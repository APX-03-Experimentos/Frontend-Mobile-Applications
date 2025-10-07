// course_statistics_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/courses/model/course.dart';
import 'package:learnhive_mobile/assignments/viewmodels/assignment_viewmodel.dart';
import '../../assignments/viewmodels/submission_viewmodel.dart';

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

  Widget _buildGradeDistribution(Map<String, int> distribution) {
    final total = distribution.values.reduce((a, b) => a + b);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución de Calificaciones',
              style: TextStyle(
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

  Widget _buildSubmissionsChart(Map<String, int> submissionsPerAssignment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submissions por Assignment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (submissionsPerAssignment.isEmpty)
              const Center(
                child: Text(
                  'No hay submissions',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...submissionsPerAssignment.entries.map((entry) {
                // ✅ CORREGIDO: Manejar caso cuando no hay submissions o todos son 0
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _calculateStatistics();

    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas - ${widget.course.title}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Tarjetas de resumen
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatisticsCard(
                  'Total Assignments',
                  stats['totalAssignments'].toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatisticsCard(
                  'Total Submissions',
                  stats['totalSubmissions'].toString(),
                  Icons.file_copy,
                  Colors.green,
                ),
                _buildStatisticsCard(
                  'Calificados',
                  stats['gradedSubmissions'].toString(),
                  Icons.grade,
                  Colors.orange,
                ),
                _buildStatisticsCard(
                  'Promedio',
                  '${stats['averageScore'].toStringAsFixed(1)}/20', // ← Cambiado a /20
                  Icons.analytics,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Distribución de calificaciones
            _buildGradeDistribution(stats['gradeDistribution']),

            const SizedBox(height: 20),

            // Submissions por assignment
            _buildSubmissionsChart(stats['submissionsPerAssignment']),
          ],
        ),
      ),
    );
  }
}