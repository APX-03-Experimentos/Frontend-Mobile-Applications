import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnhive_mobile/core/widgets/theme_switch_button.dart';
import 'package:provider/provider.dart';
import 'package:learnhive_mobile/courses/viewmodels/course_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../assignments/viewmodels/assignment_viewmodel.dart';
import '../../auth/services/token_service.dart';
import '../../auth/views/login_view.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/settings_view.dart';
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
      context.read<NotificationsBloc>().add(LoadAllNotificationsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseViewModel>();
    final size = MediaQuery.of(context).size;
    final isTeacher = vm.isTeacher;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myCourses),
            backgroundColor: isTeacher ? Colors.blueAccent : Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            elevation: 4,
            actions: [
              if (!isTeacher)
                IconButton(
                  icon: const Icon(Icons.group_add),
                  onPressed: () => _showJoinCourseDialog(vm, l10n),
                  tooltip: l10n.joinCourse,
                ),
            ],
          ),
          body: _buildBody(vm, size, isTeacher, l10n),
          bottomNavigationBar: _buildBottomNavigationBar(l10n),
          floatingActionButton: isTeacher
              ? FloatingActionButton(
            onPressed: () => _showCreateCourseDialog(vm, l10n),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          )
              : null,
        );
      },
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(AppLocalizations l10n) {
    final vm = context.read<CourseViewModel>();
    final isTeacher = vm.isTeacher;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationsLoaded) {
          unreadCount = state.notifications.where((n) => !n.read).length;
        }

        // Para estudiantes
        if (!isTeacher) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => _onBottomNavItemTappedStudent(index, l10n),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.groups_rounded),
                label: l10n.members,
              ),
              BottomNavigationBarItem(
                icon: _buildNotificationIcon(unreadCount),
                label: l10n.notifications,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: l10n.configuration,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.logout),
                label: l10n.logout,
              ),
            ],
          );
        }

        // Para profesores
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onBottomNavItemTapped(index, l10n),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.groups_rounded),
              label: l10n.members,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.analytics),
              label: l10n.statistics,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: l10n.configuration,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.logout_rounded),
              label: l10n.logout,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationIcon(int unreadCount) {
    return Stack(
      children: [
        Icon(
          Icons.notifications,
          color: _currentIndex == 1 ? Colors.blueAccent : Colors.grey,
        ),
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

  void _onBottomNavItemTappedStudent(int index, AppLocalizations l10n) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Miembros
        _showCourseSelectionDialog(l10n);
        break;
      case 1: // Notificaciones
        _navigateToNotifications();
        break;
      case 2:
        _navigateToSettings();
        break;
      case 3:
        _showLogoutConfirmation(l10n);
        break;
    }
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _onBottomNavItemTapped(int index, AppLocalizations l10n) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        _showCourseSelectionDialog(l10n);
        break;
      case 1:
        _showStatisticsDialog(l10n);
        break;
      case 2:
        _navigateToSettings();
        break;
      case 3:
        _showLogoutConfirmation(l10n);
        break;
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    );
  }

  void _showCourseSelectionDialog(AppLocalizations l10n) {
    final vm = context.read<CourseViewModel>();

    if (vm.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noCoursesAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCourse),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.courses.length,
            itemBuilder: (context, index) {
              final course = vm.courses[index];
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(course.title),
                subtitle: Text('${l10n.code}: ${course.key}'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseUsersView(course: course),
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
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.logout,
          style: TextStyle(
            color: Colors.blue[800], // Color azul para el título
          ),
        ),
        content: Text(l10n.logoutConfirmation),
        actions: [
          // Botón Cancelar - Mantenemos el estilo por defecto
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Colors.grey[700], // Gris oscuro para cancelar
              ),
            ),
          ),
          // Botón Salir - CON FONDO AZUL Y LETRA BLANCA
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout(l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // FONDO AZUL
              foregroundColor: Colors.white, // LETRA BLANCA
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              l10n.logout,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(AppLocalizations l10n) async {
    try {
      await TokenService.clearUserInfo();

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.isDarkMode) {
        await themeProvider.switchTheme();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sessionClosedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.logoutError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatisticsDialog(AppLocalizations l10n) {
    final vm = context.read<CourseViewModel>();

    if (vm.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noCoursesAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectCourseStatistics),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.courses.length,
            itemBuilder: (context, index) {
              final course = vm.courses[index];
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(course.title),
                subtitle: Text('${l10n.code}: ${course.key}'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseStatisticsView(course: course),
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
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CourseViewModel vm, Size size, bool isTeacher, AppLocalizations l10n) {
    if (vm.isLoading && vm.courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(vm, isTeacher, l10n),
          const SizedBox(height: 20),
          Expanded(
            child: _buildCoursesList(vm, size, isTeacher, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CourseViewModel vm, bool isTeacher, AppLocalizations l10n) {
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
                  l10n.myCourses,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.coursesCount(vm.courses.length),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
                isTeacher ? l10n.professor : l10n.student,
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

  Widget _buildCoursesList(CourseViewModel vm, Size size, bool isTeacher, AppLocalizations l10n) {
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
              isTeacher ? l10n.noCoursesCreated : l10n.notEnrolledInAnyCourse,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher ? l10n.createFirstCourse : l10n.joinExistingCourse,
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
          return _buildCourseCard(course, vm, size, isTeacher, l10n);
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, CourseViewModel vm, Size size, bool isTeacher, AppLocalizations l10n) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Row(
                    children: [
                      Icon(Icons.vpn_key, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.code}: ${course.key}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                          child: Text(l10n.viewCourse, style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _copyJoinCode(course.key, l10n),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                          child: Text(l10n.copyCode, style: const TextStyle(fontSize: 12)),
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

  void _showCreateCourseDialog(CourseViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createCourse),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.courseTitle,
                border: const OutlineInputBorder(),
                hintText: l10n.courseTitleHint,
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
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await vm.createCourse(_titleController.text.trim());
                _titleController.clear();

                if (vm.error == null && vm.course != null) {
                  _showSuccessDialog(l10n.courseCreatedSuccessfully);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: Text(l10n.createCourse),
          ),
        ],
      ),
    );
  }

  void _showJoinCourseDialog(CourseViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.joinCourse),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _joinCodeController,
              decoration: InputDecoration(
                labelText: l10n.joinCode,
                border: const OutlineInputBorder(),
                hintText: l10n.joinCodeHint,
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
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_joinCodeController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await vm.joinCourse(_joinCodeController.text.trim());
                _joinCodeController.clear();

                if (vm.error == null && vm.course != null) {
                  _showSuccessDialog(l10n.joinedCourseSuccessfully);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l10n.joinCourse),
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsView(course: course),
      ),
    );
  }

  void _showEditCourseDialog(Course course, CourseViewModel vm, AppLocalizations l10n) {
    final editController = TextEditingController(text: course.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editCourse),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            labelText: l10n.newTitle,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
                  _showSuccessDialog(l10n.courseUpdatedSuccessfully);
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Course course, CourseViewModel vm, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCourse),
        content: Text(l10n.deleteCourseConfirmation(course.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteCourse(course.courseId);

              if (vm.error == null) {
                _showSuccessDialog(l10n.courseDeletedSuccessfully);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteCourse),
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

  void _copyJoinCode(String joinCode, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: joinCode));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.codeCopied(joinCode)),
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