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
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deadlineController,
                decoration: const InputDecoration(
                  labelText: "Fecha y hora límite",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  // Seleccionar fecha primero
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    // Luego seleccionar hora
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
                    );

                    if (pickedTime != null) {
                      // Combinar fecha y hora
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      // Formatear para mostrar
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
                "Haz clic para seleccionar fecha y hora",
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

              // Validar que la fecha no sea en el pasado
              if (selectedDate!.isBefore(DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("La fecha no puede ser en el pasado")),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del curso - MÁS GRANDE Y ENCIMA
          Container(
            height: 180, // Más grande
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
                    child: const Icon(
                      Icons.school,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          // Información del curso
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
                // Código del curso con icono
                Row(
                  children: [
                    const Icon(Icons.vpn_key, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Código: ${course.key}",
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

  Widget _buildAssignmentCard(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
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
                  Icons.assignment_outlined,
                  size: 20,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
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
                  const Icon(Icons.description, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
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
