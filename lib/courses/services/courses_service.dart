import 'dart:convert';

import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/courses/model/course.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';
import 'package:http/http.dart' as http;

class CoursesService extends BaseService {

  CoursesService() : super('courses');

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
}