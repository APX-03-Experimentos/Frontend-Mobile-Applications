import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/assignments/model/assignment.dart';
import 'package:learnhive_mobile/core/l10n/app_localizations.dart';

import '../../assignments/viewmodels/assignment_viewmodel.dart';
import '../../assignments/viewmodels/submission_viewmodel.dart';
import '../../assignments/views/assignment_details_view.dart';
import '../../auth/services/token_service.dart';
import '../../core/providers/theme_provider.dart';
import '../../courses/model/course.dart';

class CourseDetailsView extends StatefulWidget {
  final Course course;

  const CourseDetailsView({super.key, required this.course});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserRole();
      _loadAssignments();
    });
  }

  Future<void> _loadUserRole() async {
    final isTeacher = await TokenService.isTeacher();
    setState(() {
      _isTeacher = isTeacher;
    });
  }

  Future<void> _loadAssignments() async {
    final viewModel = context.read<AssignmentViewModel>();
    await viewModel.getAssignmentsByCourseId(widget.course.courseId);
  }

  Future<void> _showCreateAssignmentDialog(AppLocalizations l10n) async {
    final viewModel = context.read<AssignmentViewModel>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final deadlineController = TextEditingController();

    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newAssignment),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: l10n.deadline,
                  border: const OutlineInputBorder(),
                  // COMENTADO: Icono del calendario
                  /*
                  suffixIcon: const Icon(Icons.calendar_today),
                  */
                ),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
                    );

                    if (pickedTime != null) {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      deadlineController.text =
                      '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} '
                          '${selectedDate!.hour.toString().padLeft(2, '0')}:'
                          '${selectedDate!.minute.toString().padLeft(2, '0')}';
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.clickToSelectDateTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.completeAllFields)),
                );
                return;
              }

              if (selectedDate!.isBefore(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.dateCannotBeInPast)),
                );
                return;
              }

              await viewModel.createAssignment(
                titleController.text,
                descriptionController.text,
                widget.course.courseId,
                selectedDate!,
                "https://placehold.co/600x400",
              );

              if (!mounted) return;

              await _loadAssignments();

              if (!mounted) return;

              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentViewModel>(
      builder: (context, viewModel, child) {
        final assignments = viewModel.assignments;
        final isLoading = viewModel.isLoading;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final l10n = AppLocalizations.of(context);

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.course.title),
                backgroundColor: _isTeacher ? Colors.blueAccent : Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                elevation: 4,
              ),

              floatingActionButton: _isTeacher
                  ? FloatingActionButton(
                onPressed: () => _showCreateAssignmentDialog(l10n),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                // COMENTADO: Icono del FAB
                /*
                child: const Icon(Icons.add),
                */
                child: Text(
                  "Agregar", // Asumiendo que existe esta traducción
                  style: const TextStyle(fontSize: 12),
                ),
              )
                  : null,

              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: _loadAssignments,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCourseInfo(widget.course, l10n),
                    const SizedBox(height: 24),
                    Text(
                      l10n.assignments,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    if (assignments.isEmpty)
                      Center(
                        child: Text(l10n.noAssignmentsForThisCourse),
                      )
                    else
                      ...assignments.map((a) => _buildAssignmentCard(a, l10n)).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCourseInfo(Course course, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                course.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    // COMENTADO: Icono de fallback
                    /*
                    child: const Icon(
                      Icons.school,
                      size: 50,
                      color: Colors.grey,
                    ),
                    */
                    child: Center(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // COMENTADO: Icono de la llave
                    /*
                    const Icon(Icons.vpn_key, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    */
                    Text(
                      "${l10n.code}: ${course.key}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        // COMENTADO: Leading con imagen/icono
        /*
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              assignment.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.assignment,
                  size: 20,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
        */
        title: Text(
          assignment.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (assignment.description?.isNotEmpty == true)
              Row(
                children: [
                  // COMENTADO: Icono de descripción
                  /*
                  const Icon(Icons.description, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  */
                  Expanded(
                    child: Text(
                      assignment.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        // COMENTADO: Icono de flecha
        /*
        trailing: const Icon(Icons.chevron_right),
        */
        trailing: Text(
          "Ver mas", // Asumiendo que existe esta traducción
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => SubmissionViewModel(),
                child: AssignmentDetailsPage(assignment: assignment),
              ),
            ),
          );
        },
      ),
    );
  }
}