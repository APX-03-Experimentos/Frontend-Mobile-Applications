import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/assignment.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';

import '../../auth/services/token_service.dart';

class AssignmentService extends BaseService{
  AssignmentService() : super('assignments');

  //createAssignment
  Future<Assignment> createAssignment(String title,String description,int courseId,DateTime deadline,String imageUrl) async{
    final token = await TokenService.getToken();

    final res = await http.post(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'courseId': courseId,
          'deadline': deadline.toIso8601String(),
          'imageUrl': imageUrl
        })
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Assignment.fromJson(data);
    } else {
      throw Exception('Error creating course: ${res.statusCode} - ${res.body}');
    }
  }

  //updateAssignment
  Future<Assignment> updateAssignment(int assignmentId, String title,String description,int courseId,DateTime deadline,String imageUrl) async{
    final token = await TokenService.getToken();

    final res = await http.put(
        Uri.parse('${fullPath()}/$assignmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'courseId': courseId,
          'deadline': deadline.toIso8601String(),
          'imageUrl': imageUrl
        })
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Assignment.fromJson(data);
    } else{
      throw Exception('Error updating course: ${res.body}');
    }
  }

  //deleteAssignment
  Future<Assignment> deleteAssignment(int assignmentId) async{
    final token = await TokenService.getToken();

    final res = await http.delete(
        Uri.parse('${fullPath()}/$assignmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Assignment.fromJson(data);
    } else{
      throw Exception('Error deleting course: ${res.body}');
    }
  }

  //getAssignmentById
  Future<Assignment> getAssignmentById(int assignmentId) async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/$assignmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Assignment.fromJson(data);
    } else{
      throw Exception('Error getting course: ${res.body}');
    }
  }

  //getAllAssignments
  Future<List<Assignment>> getAllAssignments() async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return (data as List).map((item)=>Assignment.fromJson(item)).toList();
      //return data.map((e) => Assignment.fromJson(e)).toList();
    } else{
      throw Exception('Error getting courses: ${res.body}');
    }
  }

  //getAssignmentsByCourseId
  Future<List<Assignment>> getAssignmentsByCourseId(int courseId) async{
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/course/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return (data as List).map((item)=>Assignment.fromJson(item)).toList();
    } else{
      throw Exception('Error getting courses: ${res.body}');
    }
  }

  // addFilesToAssignment - CORREGIDO (subir archivos binarios)
  Future<List<String>> addFilesToAssignment(int assignmentId, List<http.MultipartFile> files) async {
    final token = await TokenService.getToken();

    final res = http.MultipartRequest(
      'POST',
      Uri.parse('${fullPath()}/$assignmentId/files'),
    );

    res.headers['Authorization'] = 'Bearer $token';

    // Agregar archivos binarios (como espera el backend)
    for (var file in files) {
      res.files.add(file);
    }

    var streamedResponse = await res.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Error adding files to assignment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> removeFileFromAssignment(int assignmentId, String fileUrl) async {
    final token = await TokenService.getToken();

    final uri = Uri.parse('${fullPath()}/$assignmentId/files')
        .replace(queryParameters: {'fileUrl': fileUrl});

    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (res.statusCode == 200) {  // ← ✅ CORREGIR: Backend devuelve 200, no 204
      return;
    } else {
      throw Exception('Error removing file from assignment: ${res.statusCode} - ${res.body}');
    }
  }

}