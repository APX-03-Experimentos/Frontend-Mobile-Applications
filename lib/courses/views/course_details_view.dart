import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/assignments/model/assignment.dart';

import '../../assignments/viewmodels/assignment_viewmodel.dart';
import '../../assignments/viewmodels/submission_viewmodel.dart';
import '../../assignments/views/assignment_details_view.dart';
import '../../auth/services/token_service.dart';
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

  Future<void> _showCreateAssignmentDialog() async {
    final viewModel = context.read<AssignmentViewModel>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final deadlineController = TextEditingController();

    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Tarea"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(labelText: "Fecha límite (YYYY-MM-DD)"),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    deadlineController.text = pickedDate.toIso8601String().split('T').first;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Completa todos los campos")),
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
            child: const Text("Guardar"),
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

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.course.title),
            backgroundColor: _isTeacher ? Colors.blueAccent : Colors.green,
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          floatingActionButton: _isTeacher
              ? FloatingActionButton(
            onPressed: _showCreateAssignmentDialog,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          )
              : null,

          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _loadAssignments,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCourseInfo(widget.course),
                const SizedBox(height: 24),
                Text(
                  "Assignments",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (assignments.isEmpty)
                  const Center(
                    child: Text("No hay assignments para este curso."),
                  )
                else
                  ...assignments.map((a) => _buildAssignmentCard(a)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseInfo(Course course) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(course.imageUrl, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(assignment.title),
        subtitle: Text(assignment.description ?? ""),
        trailing: const Icon(Icons.chevron_right),
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
