import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // Traducciones mínimas para empezar
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // TRADUCCIONES BÁSICAS EXISTENTES
      'courses': 'Courses',
      'assignments': 'Assignments',
      'submissions': 'Submissions',
      'notifications': 'Notifications',
      'logout': 'Logout',
      'login': 'Login',
      'register': 'Register',
      'join_course': 'Join Course',
      'create_course': 'Create Course',
      'professor_courses': 'Professor Courses',
      'student_courses': 'Student Courses',
      'switch_english': 'Switch to English',
      'switch_spanish': 'Switch to Spanish',

      // SETTINGS
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'dark_mode_description': 'Switch between light and dark theme',
      'language': 'Language',
      'app_language': 'App Language',
      'language_description': 'Change app language',
      'information': 'Information',

      // ✅ NUEVAS PARA COURSE_STATISTICS_VIEW
      'statistics': 'Statistics',
      'total_assignments': 'Total Assignments',
      'total_submissions': 'Total Submissions',
      'graded': 'Graded',
      'average': 'Average',
      'grade_distribution': 'Grade Distribution',
      'submissions_per_assignment': 'Submissions per Assignment',
      'no_submissions': 'No submissions',

      // ✅ NUEVAS PARA COURSE_USERS_VIEW
      'users': 'Users',
      'professor': 'Professor',
      'students': 'Students',
      'student': 'Student',
      'no_students_enrolled': 'No students enrolled in this course',
      'remove_student': 'Remove student',
      'remove_student_confirmation': 'Are you sure you want to remove {username} from the course?',
      'student_removed': '{username} removed from course',
      'error_loading_users': 'Error loading course information',
      'refresh': 'Refresh',
      'cancel': 'Cancel',

      // ✅ NUEVAS PARA COURSES_VIEW
      'my_courses': 'My Courses',
      'members': 'Members',
      'configuration': 'Configuration',
      'no_courses_created': 'You have no courses created',
      'not_enrolled_in_any_course': 'You are not enrolled in any course',
      'create_first_course': 'Create your first course to get started',
      'join_existing_course': 'Join an existing course using a code',
      'view_course': 'View Course',
      'copy_code': 'Copy Code',
      'code_copied': 'Code copied to clipboard: {code}',
      'no_courses_available': 'No courses available',
      'select_course': 'Select Course',
      'select_course_statistics': 'Select Course for Statistics',
      'course_created_successfully': 'Course created successfully',
      'joined_course_successfully': 'You have successfully joined the course',
      'course_updated_successfully': 'Course updated successfully',
      'course_deleted_successfully': 'Course deleted successfully',
      'course_title': 'Course Title',
      'course_title_hint': 'Ex: Advanced Mathematics',
      'join_code': 'Join Code',
      'join_code_hint': 'Enter the course code',
      'edit_course': 'Edit Course',
      'new_title': 'New title',
      'delete_course': 'Delete Course',
      'delete_course_confirmation': 'Are you sure you want to delete the course "{title}"?',
      'session_closed_successfully': 'Session closed successfully',
      'logout_error': 'Logout error',
      'courses_count': '{count} courses',
      'code': 'Code',
      'save': 'Save',
      'logout_confirmation': 'Are you sure you want to log out?',
      // NUEVAS PARA COURSE_DETAILS_VIEW
      'new_assignment': 'New Assignment',
      'title': 'Title',
      'description': 'Description',
      'deadline': 'Deadline',
      'click_to_select_date_time': 'Click to select date and time',
      'complete_all_fields': 'Complete all fields',
      'date_cannot_be_in_past': 'Date cannot be in the past',
      'no_assignments_for_this_course': 'No assignments for this course',
      // NUEVAS PARA ASSIGNMENT_DETAILS_PAGE
      'assignment_files': 'Assignment Files',
      'files_uploaded_successfully': 'Files uploaded successfully',
      'file_deleted_successfully': 'File deleted successfully',
      'error_loading_files': 'Error loading files',
      'error_uploading_files': 'Error uploading files',
      'error_deleting_file': 'Error deleting file',
      'error_opening_file': 'Error opening file',
      'no_files_available': 'No files available',
      'delete_file': 'Delete File',
      'delete_file_confirmation': 'Are you sure you want to delete this file?',
      'could_not_open_file': 'Could not open file',
      'new_submission': 'New Submission',
      'content': 'Content',
      'submit': 'Submit',
      'submission_created_successfully': 'Submission created successfully',
      'grade_submission': 'Grade Submission',
      'score_hint': 'Score (0-20)',
      'submission_graded_with_score': 'Submission graded with {score} points',
      'status': 'Status',
      'due_date': 'Due date',
      'no_submissions_registered': 'No submissions registered',
      'delete': 'Delete',
      // NUEVAS PARA SUBMISSION_DETAILS_PAGE
      'submission_files': 'Submission Files',
      'submission_details': 'Submission Details',
      'submission_graded': 'Submission graded',
      'no_files_uploaded': 'No files uploaded',
      'score': 'Score',
    },
    'es': {
      // TRADUCCIONES BÁSICAS EXISTENTES
      'courses': 'Cursos',
      'assignments': 'Tareas', // ✅ AGREGAR ESTA LÍNEA
      'submissions': 'Entregas',
      'notifications': 'Notificaciones',
      'logout': 'Cerrar Sesión',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'join_course': 'Unirse a Curso',
      'create_course': 'Crear Curso',
      'professor_courses': 'Cursos del Profesor',
      'student_courses': 'Cursos del Estudiante',
      'switch_english': 'Cambiar a Inglés',
      'switch_spanish': 'Cambiar a Español',

      // SETTINGS
      'settings': 'Configuración',
      'appearance': 'Apariencia',
      'dark_mode': 'Modo Oscuro',
      'dark_mode_description': 'Cambiar entre tema claro y oscuro',
      'language': 'Idioma',
      'app_language': 'Idioma de la App',
      'language_description': 'Cambiar el idioma de la aplicación',
      'information': 'Información',

      // ✅ NUEVAS PARA COURSE_STATISTICS_VIEW
      'statistics': 'Estadísticas',
      'total_assignments': 'Total de Tareas',
      'total_submissions': 'Total de Entregas',
      'graded': 'Calificados',
      'average': 'Promedio',
      'grade_distribution': 'Distribución de Calificaciones',
      'submissions_per_assignment': 'Entregas por Tarea',
      'no_submissions': 'No hay entregas',

      // ✅ NUEVAS PARA COURSE_USERS_VIEW
      'users': 'Usuarios',
      'professor': 'Profesor',
      'students': 'Alumnos',
      'student': 'Alumno',
      'no_students_enrolled': 'No hay alumnos inscritos en este curso',
      'remove_student': 'Eliminar alumno',
      'remove_student_confirmation': '¿Estás seguro de que quieres eliminar a {username} del curso?',
      'student_removed': '{username} eliminado del curso',
      'error_loading_users': 'Error al cargar información del curso',
      'refresh': 'Actualizar',
      'cancel': 'Cancelar',

      // ✅ NUEVAS PARA COURSES_VIEW
      'my_courses': 'Mis Cursos',
      'members': 'Miembros',
      'configuration': 'Configuración',
      'no_courses_created': 'No tienes cursos creados',
      'not_enrolled_in_any_course': 'No estás inscrito en ningún curso',
      'create_first_course': 'Crea tu primer curso para comenzar',
      'join_existing_course': 'Únete a un curso existente usando un código',
      'view_course': 'Ver Curso',
      'copy_code': 'Copiar Código',
      'code_copied': 'Código copiado al portapapeles: {code}',
      'no_courses_available': 'No tienes cursos disponibles',
      'select_course': 'Seleccionar Curso',
      'select_course_statistics': 'Seleccionar Curso para Estadísticas',
      'course_created_successfully': 'Curso creado exitosamente',
      'joined_course_successfully': 'Te has unido al curso exitosamente',
      'course_updated_successfully': 'Curso actualizado exitosamente',
      'course_deleted_successfully': 'Curso eliminado exitosamente',
      'course_title': 'Título del curso',
      'course_title_hint': 'Ej: Matemáticas Avanzadas',
      'join_code': 'Código de unión',
      'join_code_hint': 'Ingresa el código del curso',
      'edit_course': 'Editar Curso',
      'new_title': 'Nuevo título',
      'delete_course': 'Eliminar Curso',
      'delete_course_confirmation': '¿Estás seguro de que quieres eliminar el curso "{title}"?',
      'session_closed_successfully': 'Sesión cerrada exitosamente',
      'logout_error': 'Error al cerrar sesión',
      'courses_count': '{count} cursos',
      'code': 'Código',
      'save': 'Guardar',
      'logout_confirmation': '¿Estás seguro de que quieres cerrar sesión?',
      // NUEVAS PARA COURSE_DETAILS_VIEW
      'new_assignment': 'Nueva Tarea',
      'title': 'Título',
      'description': 'Descripción',
      'deadline': 'Fecha límite',
      'click_to_select_date_time': 'Haz clic para seleccionar fecha y hora',
      'complete_all_fields': 'Completa todos los campos',
      'date_cannot_be_in_past': 'La fecha no puede ser en el pasado',
      'no_assignments_for_this_course': 'No hay tareas para este curso',
      // NUEVAS PARA ASSIGNMENT_DETAILS_PAGE
      'assignment_files': 'Archivos del Assignment',
      'files_uploaded_successfully': 'Archivos subidos correctamente',
      'file_deleted_successfully': 'Archivo eliminado correctamente',
      'error_loading_files': 'Error al cargar archivos',
      'error_uploading_files': 'Error al subir archivos',
      'error_deleting_file': 'Error al eliminar archivo',
      'error_opening_file': 'Error al abrir archivo',
      'no_files_available': 'No hay archivos disponibles',
      'delete_file': 'Eliminar Archivo',
      'delete_file_confirmation': '¿Seguro que deseas eliminar este archivo?',
      'could_not_open_file': 'No se pudo abrir el archivo',
      'new_submission': 'Nueva Entrega',
      'content': 'Contenido',
      'submit': 'Enviar',
      'submission_created_successfully': 'Entrega creada exitosamente',
      'grade_submission': 'Calificar Entrega',
      'score_hint': 'Puntaje (0-20)',
      'submission_graded_with_score': 'Entrega calificada con {score} puntos',
      'status': 'Estado',
      'due_date': 'Vence',
      'no_submissions_registered': 'No hay entregas registradas',
      'delete': 'Eliminar',
      // NUEVAS PARA SUBMISSION_DETAILS_PAGE
      'submission_files': 'Archivos de la Entrega',
      'submission_details': 'Detalles de la Entrega',
      'submission_graded': 'Entrega calificada',
      'no_files_uploaded': 'No hay archivos subidos',
      'score': 'Puntaje',
    },
  };

  String _translate(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }

  // Método para traducciones con parámetros
  String translateWithParams(String key, Map<String, String> params) {
    String translation = _translate(key);
    params.forEach((key, value) {
      translation = translation.replaceAll('{$key}', value);
    });
    return translation;
  }

  // Getters para las traducciones EXISTENTES
  String get courses => _translate('courses');
  String get assignments => _translate('assignments');
  String get submissions => _translate('submissions');
  String get notifications => _translate('notifications');
  String get logout => _translate('logout');
  String get login => _translate('login');
  String get register => _translate('register');
  String get joinCourse => _translate('join_course');
  String get createCourse => _translate('create_course');
  String get professorCourses => _translate('professor_courses');
  String get studentCourses => _translate('student_courses');
  String get switchEnglish => _translate('switch_english');
  String get switchSpanish => _translate('switch_spanish');

  // SETTINGS
  String get settings => _translate('settings');
  String get appearance => _translate('appearance');
  String get darkMode => _translate('dark_mode');
  String get darkModeDescription => _translate('dark_mode_description');
  String get language => _translate('language');
  String get appLanguage => _translate('app_language');
  String get languageDescription => _translate('language_description');
  String get information => _translate('information');

  // NUEVOS GETTERS PARA COURSE_STATISTICS_VIEW
  String get statistics => _translate('statistics');
  String get totalAssignments => _translate('total_assignments');
  String get totalSubmissions => _translate('total_submissions');
  String get graded => _translate('graded');
  String get average => _translate('average');
  String get gradeDistribution => _translate('grade_distribution');
  String get submissionsPerAssignment => _translate('submissions_per_assignment');
  String get noSubmissions => _translate('no_submissions');

  // NUEVOS GETTERS PARA COURSE_USERS_VIEW
  String get users => _translate('users');
  String get professor => _translate('professor');
  String get students => _translate('students');
  String get student => _translate('student');
  String get noStudentsEnrolled => _translate('no_students_enrolled');
  String get removeStudent => _translate('remove_student');
  String get refresh => _translate('refresh');
  String get errorLoadingUsers => _translate('error_loading_users');
  String get cancel => _translate('cancel');

  // NUEVOS GETTERS PARA COURSES_VIEW
  String get myCourses => _translate('my_courses');
  String get members => _translate('members');
  String get configuration => _translate('configuration');
  String get noCoursesCreated => _translate('no_courses_created');
  String get notEnrolledInAnyCourse => _translate('not_enrolled_in_any_course');
  String get createFirstCourse => _translate('create_first_course');
  String get joinExistingCourse => _translate('join_existing_course');
  String get viewCourse => _translate('view_course');
  String get copyCode => _translate('copy_code');
  String get noCoursesAvailable => _translate('no_courses_available');
  String get selectCourse => _translate('select_course');
  String get selectCourseStatistics => _translate('select_course_statistics');
  String get courseCreatedSuccessfully => _translate('course_created_successfully');
  String get joinedCourseSuccessfully => _translate('joined_course_successfully');
  String get courseUpdatedSuccessfully => _translate('course_updated_successfully');
  String get courseDeletedSuccessfully => _translate('course_deleted_successfully');
  String get courseTitle => _translate('course_title');
  String get courseTitleHint => _translate('course_title_hint');
  String get joinCode => _translate('join_code');
  String get joinCodeHint => _translate('join_code_hint');
  String get editCourse => _translate('edit_course');
  String get newTitle => _translate('new_title');
  String get deleteCourse => _translate('delete_course');
  String get sessionClosedSuccessfully => _translate('session_closed_successfully');
  String get logoutError => _translate('logout_error');
  String get code => _translate('code');
  String get save => _translate('save');
  String get logoutConfirmation => _translate('logout_confirmation');

  // COURSE_DETAILS_VIEW
  String get newAssignment => _translate('new_assignment');
  String get title => _translate('title');
  String get description => _translate('description');
  String get deadline => _translate('deadline');
  String get clickToSelectDateTime => _translate('click_to_select_date_time');
  String get completeAllFields => _translate('complete_all_fields');
  String get dateCannotBeInPast => _translate('date_cannot_be_in_past');
  String get noAssignmentsForThisCourse => _translate('no_assignments_for_this_course');

  // ASSIGNMENT_DETAILS_PAGE
  String get assignmentFiles => _translate('assignment_files');
  String get filesUploadedSuccessfully => _translate('files_uploaded_successfully');
  String get fileDeletedSuccessfully => _translate('file_deleted_successfully');
  String get errorLoadingFiles => _translate('error_loading_files');
  String get errorUploadingFiles => _translate('error_uploading_files');
  String get errorDeletingFile => _translate('error_deleting_file');
  String get errorOpeningFile => _translate('error_opening_file');
  String get noFilesAvailable => _translate('no_files_available');
  String get deleteFile => _translate('delete_file');
  String get deleteFileConfirmation => _translate('delete_file_confirmation');
  String get couldNotOpenFile => _translate('could_not_open_file');
  String get newSubmission => _translate('new_submission');
  String get content => _translate('content');
  String get submit => _translate('submit');
  String get submissionCreatedSuccessfully => _translate('submission_created_successfully');
  String get gradeSubmission => _translate('grade_submission');
  String get scoreHint => _translate('score_hint');
  String get status => _translate('status');
  String get dueDate => _translate('due_date');
  String get noSubmissionsRegistered => _translate('no_submissions_registered');
  String get delete => _translate('delete');

  // NUEVOS GETTERS PARA SUBMISSION_DETAILS_PAGE
  String get submissionFiles => _translate('submission_files');
  String get submissionDetails => _translate('submission_details');
  String get submissionGraded => _translate('submission_graded');
  String get noFilesUploaded => _translate('no_files_uploaded');
  String get score => _translate('score');

  // Métodos con parámetros
  String removeStudentConfirmation(String username) {
    return translateWithParams('remove_student_confirmation', {'username': username});
  }

  String studentRemoved(String username) {
    return translateWithParams('student_removed', {'username': username});
  }

  // CoursesView
  String codeCopied(String code) {
    return translateWithParams('code_copied', {'code': code});
  }

  String deleteCourseConfirmation(String title) {
    return translateWithParams('delete_course_confirmation', {'title': title});
  }

  String coursesCount(int count) {
    return translateWithParams('courses_count', {'count': count.toString()});
  }

  // AssignmentDetailsPage
  String submissionGradedWithScore(int score) {
    return translateWithParams(
        'submission_graded_with_score', {'score': score.toString()});
  }

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}