import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/auth/model/user.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/auth/viewmodels/auth_viewmodel.dart';
import 'package:learnhive_mobile/courses/model/course.dart';
import 'package:learnhive_mobile/core/l10n/app_localizations.dart';
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
      _isTeacher = await TokenService.isTeacher();
      final authVm = context.read<AuthViewModel>();

      _teacher = await authVm.getUserById(widget.course.teacherId);
      final users = await authVm.getUsersByCourseId(widget.course.courseId);
      _students = users.where((user) => user.role == 'ROLE_STUDENT').toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.errorLoadingUsers}: $e'), // ✅ TRADUCIDO
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUserList() {
    final appLocalizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_teacher == null) {
      return Center(
        child: Text(appLocalizations.errorLoadingUsers), // ✅ TRADUCIDO
      );
    }

    return ListView(
      children: [
        // Sección del profesor
        _buildSectionHeader(appLocalizations.professor), // ✅ TRADUCIDO
        _buildUserItem(_teacher!, isTeacher: true),

        // Sección de estudiantes
        if (_students.isNotEmpty) _buildSectionHeader('${appLocalizations.students} (${_students.length})'), // ✅ TRADUCIDO
        if (_students.isEmpty)
          Padding( // ✅ CAMBIÉ const Padding por Padding
            padding: const EdgeInsets.all(16.0),
            child: Text( // ✅ CAMBIÉ const Text por Text
              appLocalizations.noStudentsEnrolled, // ✅ TRADUCIDO
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
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
    final appLocalizations = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        // COMENTADO: Avatar circular con ícono
        /*
        leading: CircleAvatar(
          backgroundColor: isTeacher ? Colors.blueAccent : Colors.green,
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        */
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: isTeacher ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(isTeacher ? appLocalizations.professor : appLocalizations.student), // ✅ TRADUCIDO
        trailing: _isTeacher && !isTeacher
            ? TextButton(
          // COMENTADO: Icono de eliminar
          /*
                child: Icon(Icons.group_remove_rounded, color: Colors.red),
                */
          child: Text(
            appLocalizations.removeStudent, // ✅ TRADUCIDO
            style: const TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(appLocalizations.removeStudent), // ✅ TRADUCIDO
                content: Text(appLocalizations.removeStudentConfirmation(user.username)), // ✅ TRADUCIDO
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(appLocalizations.cancel), // ✅ TRADUCIDO
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(appLocalizations.removeStudent), // ✅ TRADUCIDO
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
                    content: Text(appLocalizations.studentRemoved(user.username)), // ✅ TRADUCIDO
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                final appLocalizations = AppLocalizations.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${appLocalizations.removeStudent} error: $e'), // ✅ TRADUCIDO PARCIAL
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          // COMENTADO: Tooltip
          /*
                tooltip: appLocalizations.removeStudent, // ✅ TRADUCIDO
                */
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.users} - ${widget.course.title}'), // ✅ TRADUCIDO
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            // COMENTADO: Icono de refresh
            /*
            icon: const Icon(Icons.refresh),
            */
            child: Text(
              appLocalizations.refresh, // ✅ TRADUCIDO
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: _loadData,
            // COMENTADO: Tooltip
            /*
            tooltip: appLocalizations.refresh, // ✅ TRADUCIDO
            */
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }
}