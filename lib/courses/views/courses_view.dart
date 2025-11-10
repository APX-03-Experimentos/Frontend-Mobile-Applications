import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/courses/viewmodels/course_viewmodel.dart';
import '../../assignments/viewmodels/assignment_viewmodel.dart';
import '../../auth/services/token_service.dart';
import '../../auth/views/login_view.dart';
import '../../notifications/bloc/notifications_bloc.dart';
import '../model/course.dart';
import 'course_details_view.dart';
import 'course_statistics_view.dart';
import 'course_users_view.dart';

class CoursesView extends StatefulWidget {

  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  final _titleController = TextEditingController();
  final _joinCodeController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadCourses();

      // Cargar notificaciones (el WebSocket se conecta automáticamente en el BLoC)
      context.read<NotificationsBloc>().add(LoadAllNotificationsEvent());

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
        backgroundColor: isTeacher ? Colors.blueAccent : Colors.lightBlueAccent,
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

      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildBottomNavigationBar() {
    final vm = context.read<CourseViewModel>();
    final isTeacher = vm.isTeacher;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;

        // Calcular notificaciones no leídas
        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.read).length;
        }

        // Para estudiantes
        if (!isTeacher) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _onBottomNavItemTappedStudent(index),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Usuarios',
              ),
              BottomNavigationBarItem(
                icon: _buildNotificationIcon(unreadCount),
                label: 'Notificaciones',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                label: 'Cerrar Sesión',
              ),
            ],
          );
        }

        // Para profesores
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onBottomNavItemTapped(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Usuarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Cerrar Sesión',
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationIcon(int unreadCount) {
    return Stack(
      children: [
        const Icon(Icons.notifications),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _onBottomNavItemTappedStudent(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Usuarios
        _showCourseSelectionDialog();
        break;
      case 1: // Notificaciones
        _navigateToNotifications();
        break;
      case 2: // Cerrar Sesión (ahora es el índice 1 para estudiantes)
        _showLogoutConfirmation();
        break;
    }
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Usuarios
        _showCourseSelectionDialog();
        break;
      case 1: // Cerrar Sesión
        _showStatisticsDialog();
        break;
      case 2: // Estadísticas
        _showLogoutConfirmation();
        break;
    }
  }

  void _showCourseSelectionDialog() {
    final vm = context.read<CourseViewModel>();

    if (vm.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes cursos disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Curso'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.courses.length,
            itemBuilder: (context, index) {
              final course = vm.courses[index];
              return ListTile(
                leading: const Icon(Icons.school),
                title: Text(course.title),
                subtitle: Text('Código: ${course.key}'),
                onTap: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseUsersView(
                        course: course, // Pasamos el curso completo
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo de confirmación
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Limpiar SharedPreferences usando TokenService
      await TokenService.clearUserInfo();

      // ✅ SOLUCIÓN: Usar pushReplacement en lugar de pushNamedAndRemoveUntil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatisticsDialog() {
    final vm = context.read<CourseViewModel>();

    if (vm.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes cursos disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Curso para Estadísticas'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.courses.length,
            itemBuilder: (context, index) {
              final course = vm.courses[index];
              return ListTile(
                leading: const Icon(Icons.analytics),
                title: Text(course.title),
                subtitle: Text('Código: ${course.key}'),
                onTap: () {
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseStatisticsView(
                        course: course,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
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
                  isTeacher ? 'Mis Cursos' : 'Mis Cursos',
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
                color: isTeacher ? Colors.blue[50] : Colors.lightBlueAccent[90],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isTeacher ? Colors.blue : Colors.lightBlueAccent,
                ),
              ),
              child: Text(
                isTeacher ? 'Profesor' : 'Estudiante',
                style: TextStyle(
                  color: isTeacher ? Colors.blue[700] : Colors.lightBlueAccent[700],
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
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Imagen a la izquierda
            if (course.imageUrl.isNotEmpty)
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.school,
                          size: 30,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

            Expanded(
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 6),

                  // Información del curso
                  Row(
                    children: [
                      Icon(Icons.vpn_key, size: 14, color: Colors.grey[600]),
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

                  const SizedBox(height: 8),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showCourseDetails(course),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            foregroundColor: Colors.blueAccent,
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                          child: const Text('Ver Curso', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _copyJoinCode(course.key),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: const Text('Copiar Código', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  void _copyJoinCode(String joinCode) async {
    await Clipboard.setData(ClipboardData(text: joinCode)); // ✅ copia real al portapapeles

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado al portapapeles: $joinCode'),
        backgroundColor: Colors.green,
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