import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/courses/viewmodels/course_viewmodel.dart';
import '../../assignments/viewmodels/assignment_viewmodel.dart';
import '../model/course.dart';
import 'course_details_view.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _titleController = TextEditingController();
  final _joinCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseViewModel>();
    final size = MediaQuery.of(context).size;
    final isTeacher = vm.isTeacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Mis Cursos (Profesor)' : 'Mis Cursos (Estudiante)'),
        backgroundColor: isTeacher ? Colors.blueAccent : Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          // Botón para unirse a curso - SOLO para estudiantes
          if (!isTeacher)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () => _showJoinCourseDialog(vm),
              tooltip: 'Unirse a curso',
            ),
        ],
      ),
      body: _buildBody(vm, size, isTeacher),
      // Botón crear curso - SOLO para profesores
      floatingActionButton: isTeacher
          ? FloatingActionButton(
        onPressed: () => _showCreateCourseDialog(vm),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildBody(CourseViewModel vm, Size size, bool isTeacher) {
    if (vm.isLoading && vm.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estadísticas
          _buildHeader(vm, isTeacher),
          const SizedBox(height: 20),
          // Lista de cursos
          Expanded(
            child: _buildCoursesList(vm, size, isTeacher),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CourseViewModel vm, bool isTeacher) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTeacher ? 'Mis Cursos (Profesor)' : 'Mis Cursos (Estudiante)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vm.courses.length} cursos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            // Indicador de rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTeacher ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTeacher ? Colors.blue : Colors.green,
                ),
              ),
              child: Text(
                isTeacher ? 'Profesor' : 'Estudiante',
                style: TextStyle(
                  color: isTeacher ? Colors.blue[700] : Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (vm.error != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(CourseViewModel vm, Size size, bool isTeacher) {
    if (vm.courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isTeacher ? 'No tienes cursos creados' : 'No estás inscrito en ningún curso',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher ? 'Crea tu primer curso para comenzar' : 'Únete a un curso existente usando un código',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await vm.loadCourses();
      },
      child: ListView.builder(
        itemCount: vm.courses.length,
        itemBuilder: (context, index) {
          final course = vm.courses[index];
          return _buildCourseCard(course, vm, size, isTeacher);
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, CourseViewModel vm, Size size, bool isTeacher) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Menú de opciones - SOLO para profesores
                if (isTeacher)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => _handleCourseMenu(value, course, vm),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('Ver detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Información del curso
            Row(
              children: [
                Icon(Icons.vpn_key, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Código: ${course.key}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCourseDetails(course);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                    ),
                    child: const Text('Ver Curso'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _copyJoinCode(course.key);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('Copiar Código'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCourseDialog(CourseViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del curso',
                border: OutlineInputBorder(),
                hintText: 'Ej: Matemáticas Avanzadas',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _titleController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await vm.createCourse(_titleController.text.trim());
                _titleController.clear();

                if (vm.error == null && vm.course != null) {
                  _showSuccessDialog('Curso creado exitosamente');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text('Crear Curso'),
          ),
        ],
      ),
    );
  }

  void _showJoinCourseDialog(CourseViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unirse a Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _joinCodeController,
              decoration: const InputDecoration(
                labelText: 'Código de unión',
                border: OutlineInputBorder(),
                hintText: 'Ingresa el código del curso',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _joinCodeController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_joinCodeController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await vm.joinCourse(_joinCodeController.text.trim());
                _joinCodeController.clear();

                if (vm.error == null && vm.course != null) {
                  _showSuccessDialog('Te has unido al curso exitosamente');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  void _handleCourseMenu(String value, Course course, CourseViewModel vm) {
    switch (value) {
      case 'view':
        _showCourseDetails(course);
        break;
      case 'edit':
        _showEditCourseDialog(course, vm);
        break;
      case 'delete':
        _showDeleteConfirmation(course, vm);
        break;
    }
  }

  void _showCourseDetails(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsView(course: course),
      ),
    );
  }

  void _showEditCourseDialog(Course course, CourseViewModel vm) {
    final editController = TextEditingController(text: course.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Curso'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Nuevo título',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await vm.updateCourse(
                  editController.text.trim(),
                  course.imageUrl,
                  course.courseId,
                );

                if (vm.error == null) {
                  _showSuccessDialog('Curso actualizado exitosamente');
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Course course, CourseViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Curso'),
        content: Text('¿Estás seguro de que quieres eliminar el curso "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteCourse(course.courseId);

              if (vm.error == null) {
                _showSuccessDialog('Curso eliminado exitosamente');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyJoinCode(String joinCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: $joinCode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }
}