// course_users_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/auth/model/user.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/auth/viewmodels/auth_viewmodel.dart';
import 'package:learnhive_mobile/courses/model/course.dart';

import '../viewmodels/course_viewmodel.dart';

class CourseUsersView extends StatefulWidget {
  final Course course;

  const CourseUsersView({
    super.key,
    required this.course,
  });

  @override
  State<CourseUsersView> createState() => _CourseUsersViewState();
}

class _CourseUsersViewState extends State<CourseUsersView> {
  List<User> _students = [];
  User? _teacher;
  bool _isLoading = true;
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Verificar si es profesor
      _isTeacher = await TokenService.isTeacher();

      final authVm = context.read<AuthViewModel>();

      // Cargar información del profesor
      _teacher = await authVm.getUserById(widget.course.teacherId);

      // Cargar estudiantes del curso
      final users = await authVm.getUsersByCourseId(widget.course.courseId);

      // Filtrar solo estudiantes (excluir al profesor si está en la lista)
      _students = users.where((user) => user.role == 'ROLE_STUDENT').toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeStudent(int userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar alumno'),
        content: Text('¿Estás seguro de que quieres eliminar a $userName del curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implementar método para eliminar alumno del curso
        // await authVm.removeStudentFromCourse(widget.course.courseId, userId);

        // Por ahora, recargamos la lista
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName eliminado del curso'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar alumno: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_teacher == null) {
      return const Center(
        child: Text('Error al cargar información del curso'),
      );
    }

    return ListView(
      children: [
        // Sección del profesor
        _buildSectionHeader('Profesor'),
        _buildUserItem(_teacher!, isTeacher: true),

        // Sección de estudiantes
        if (_students.isNotEmpty) _buildSectionHeader('Alumnos (${_students.length})'),
        if (_students.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No hay alumnos inscritos en este curso',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ..._students.map((student) => _buildUserItem(student, isTeacher: false)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildUserItem(User user, {required bool isTeacher}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTeacher ? Colors.blueAccent : Colors.green,
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: isTeacher ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(isTeacher ? 'Profesor' : 'Alumno'),
        trailing: _isTeacher && !isTeacher
            ? IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar alumno'),
                content: Text('¿Estás seguro de que quieres eliminar a ${user.username} del curso?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              try {
                final courseVm = context.read<CourseViewModel>();
                await courseVm.kickStudentFromCourse(widget.course.courseId, user.id);

                setState(() {
                  _students.removeWhere((student) => student.id == user.id);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.username} eliminado del curso'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar alumno: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          tooltip: 'Eliminar del curso',
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios - ${widget.course.title}'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }
}