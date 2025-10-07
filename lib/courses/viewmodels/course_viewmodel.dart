
import 'package:flutter/cupertino.dart';
import 'package:learnhive_mobile/courses/model/course.dart';

import '../../auth/services/token_service.dart';
import '../services/course_service.dart';

class CourseViewModel extends ChangeNotifier{

  final _courseService = CourseService();

  Course? _course;
  bool _isLoading = false;
  String? _error;
  List<Course> _courses = []; // ← Para listas de cursos

  bool? _isTeacher;


  Course? get course => _course;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Course> get courses => _courses;

  bool get isTeacher => _isTeacher ?? true;

  Future<Course> createCourse(String title) async {
    _setLoading(true);
    try {
      _course = await _courseService.createCourse(title);
      _error = null;
      await loadCourses();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _course!;
  }

  //updateCourse
  Future<Course> updateCourse(String title,String imageUrl, int id) async{
    _setLoading(true);
    try {
      _course = await _courseService.updateCourse(title,imageUrl,id);
      _error = null;

      // ✅ Actualizar en la lista local si existe
      final index = _courses.indexWhere((c) => c.courseId == id.toString());
      if (index != -1 && _course != null) {
        _courses[index] = _course!;
        notifyListeners(); // ← Notificar el cambio
      }

    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _course!;
  }

  //deleteCourse
  Future<void> deleteCourse(int id) async {
    _setLoading(true);
    try {
      await _courseService.deleteCourse(id);
      _error = null;

      // ✅ Remover de la lista local
      _courses.removeWhere((c) => c.courseId == id);
      notifyListeners(); // ← Notificar el cambio

    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  //joinCourse
  Future<Course> joinCourse(String key) async {
    _setLoading(true);
    try {
      _course = await _courseService.joinCourse(key);
      _error = null;

      // ✅ IMPORTANTE: Recargar la lista de cursos después de unirse
      await loadCourses();

    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _course!;
  }

  //kickStudentFromCourse
  Future<void> kickStudentFromCourse(int courseId, int studentId) async {
    _setLoading(true);
    try {
      debugPrint('🎯 CourseViewModel.kickStudentFromCourse: courseId=$courseId, studentId=$studentId');
      await _courseService.kickStudentFromCourse(courseId, studentId);
      _error = null;
      debugPrint('✅ Estudiante eliminado exitosamente');

    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error en ViewModel: $e');
      rethrow; // ← Esto es importante para que el error llegue al UI
    }
    _setLoading(false);
  }

  //setCourseJoinCodeByGroupId
  Future<void> setCourseJoinCodeByGroupId(int courseId, String keycode, DateTime expiration) async {
    _setLoading(true);
    try {
      await _courseService.setCourseJoinCodeByGroupId(courseId, keycode, expiration);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  //getAllCourses
  Future<List<Course>> getAllCourses() async {
    _setLoading(true);
    try {
      _courses = await _courseService.getAllCourses();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _courses;
  }

  //getCourseById
  Future<Course> getCourseById(String id) async {
    _setLoading(true);
    try {
      _course = await _courseService.getCourseById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _course!;
  }

  //getCoursesByStudentId()
  Future<List<Course>> getCoursesFromStudent() async {
    _setLoading(true);
    try {
      _courses = await _courseService.getCoursesFromStudent();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _courses;
  }

  //getCoursesByTeacherId()
  Future<List<Course>> getCoursesFromTeacher() async {
    _setLoading(true);
    try {
      _courses = await _courseService.getCoursesFromTeacher();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _courses;
  }




  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }




  // ✅ NUEVO MÉTODO: Forzar actualización del rol
  Future<void> refreshUserRole() async {
    _isTeacher = null; // ← Limpiar cache
    await determineUserRole();
  }

  Future<void> determineUserRole() async {
    try {
      debugPrint('🔄 Determinando rol del usuario...');
      final role = await TokenService.getUserRole();
      debugPrint('📋 Rol obtenido de TokenService: $role');

      _isTeacher = await TokenService.isTeacher();
      debugPrint('🎯 _isTeacher determinado: $_isTeacher');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error determinando rol: $e');
      _isTeacher = true;
      notifyListeners();
    }
  }

  Future<void> loadCourses() async {
    await refreshUserRole();

    _error = null; // ✅ Limpia errores anteriores antes de empezar
    _setLoading(true);

    try {
      if (_isTeacher!) {
        _courses = await _courseService.getCoursesFromTeacher();
      } else {
        _courses = await _courseService.getCoursesFromStudent();
      }

      // ⚠️ Si no hay cursos, no es error
      if (_courses.isEmpty) {
        debugPrint("ℹ️ No se encontraron cursos para el usuario actual.");
      }

    } catch (e) {
      _error = e.toString(); // Solo guarda error real
      _courses = [];
    } finally {
      _setLoading(false);
    }
  }





}