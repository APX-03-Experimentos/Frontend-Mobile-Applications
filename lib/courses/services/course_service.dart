import 'dart:convert';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/courses/model/course.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';
import 'package:http/http.dart' as http;

import '../../shared/services/base_service.dart';

class CourseService extends BaseService {

  CourseService() : super('courses');

  //createCourse
  Future<Course> createCourse(String title) async {  // ← Quita imageUrl
    final token = await TokenService.getToken();

    final res = await http.post(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'title': title,
        })
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Course.fromJson(data);
    } else {
      throw Exception('Error creating course: ${res.statusCode} - ${res.body}');
    }
  }

  //updateCourse
  Future<Course> updateCourse(String title,String imageUrl, int id) async {
    final token = await TokenService.getToken();

    final res = await http.put(
        Uri.parse('${fullPath()}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'title': title,
          'imageUrl': imageUrl
        })
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Course.fromJson(data);
    } else{
      throw Exception('Error updating course: ${res.body}');
    }
  }

  //deleteCourse
  Future<void> deleteCourse(int id) async {
    final token = await TokenService.getToken();

    final res = await http.delete(
        Uri.parse('${fullPath()}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode != 204) {
      throw Exception('Error deleting course: ${res.body}'); // ← ✅ Mensaje correcto
    }
  }

  //joinCourse
  Future<Course> joinCourse(String key) async {
    final token = await TokenService.getToken();

    final res = await http.post(
        Uri.parse('${fullPath()}/join/$key'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Course.fromJson(data);
    } else{
      throw Exception('Error joining course: ${res.body}');
    }
  }

  // En CourseService
  Future<void> kickStudentFromCourse(int courseId, int studentId) async {
    final token = await TokenService.getToken();

    final res = await http.delete(
      Uri.parse('${fullPath()}/$courseId/students/$studentId'), // ← Verifica esta URL
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (res.statusCode == 200 || res.statusCode == 204) {
      return;
    } else {
      throw Exception('Error removing student from course: ${res.statusCode} - ${res.body}');
    }
  }

  //setCourseJoinCodeByGroupId
  Future<void> setCourseJoinCodeByGroupId(int courseId, String keycode, DateTime expiration) async {
    final token = await TokenService.getToken();

    final res = await http.put(
        Uri.parse('${fullPath()}/$courseId/join-code'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'keycode': keycode,
          'expiration': expiration.millisecondsSinceEpoch
        })
    );
    if (res.statusCode == 200) {
      return;
    } else {
      throw Exception('Error setting join code: ${res.body}');
    }
  }

  //getAllCourses
  Future<List<Course>> getAllCourses() async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error fetching courses: ${res.body}');
    }
  }

  //getCourseById
  Future<Course> getCourseById(String id) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode == 200) {
      return Course.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error fetching course: ${res.body}');
    }
  }

  //getCoursesByStudentId()
  Future<List<Course>> getCoursesFromStudent() async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/student'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error fetching courses: ${res.body}');
    }
  }

  //getCoursesByTeacherId()
  Future<List<Course>> getCoursesFromTeacher() async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/teacher'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error fetching courses: ${res.body}');
    }
  }


}