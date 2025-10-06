
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
      await _courseService.kickStudentFromCourse(courseId, studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
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



  Future<void> determineUserRole() async {
    try {
      debugPrint('DEBUG: Determinando rol del usuario...');
      final role = await TokenService.getUserRole();
      debugPrint('DEBUG: Rol obtenido de TokenService: $role');

      _isTeacher = await TokenService.isTeacher();
      debugPrint('DEBUG: _isTeacher = $_isTeacher');

      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG: Error determinando rol: $e');
      _isTeacher = true;
      notifyListeners();
    }
  }

// Cargar cursos según el rol
  Future<void> loadCourses() async {

    if (_isTeacher == null) {
      await determineUserRole();
    }

    _setLoading(true);
    try {
      if (_isTeacher!) {
        _courses = await _courseService.getCoursesFromTeacher();
      } else {
        _courses = await _courseService.getCoursesFromStudent();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _courses = [];
    }
    _setLoading(false);
  }




}