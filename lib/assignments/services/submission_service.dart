import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/shared/services/base_service.dart';

import '../../auth/services/token_service.dart';

class SubmissionService extends BaseService{
  SubmissionService() : super('submissions');

  Future<Submission> createSubmission(int assignmentId, String content, String imageUrl) async {
    final token = await TokenService.getToken();

    final res = await http.post(
      Uri.parse('${fullPath()}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'assignmentId': assignmentId,
        'content': content,
        'imageUrl': imageUrl
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return Submission.fromJson(data);
    } else {
      throw Exception('Error creating submission: ${res.statusCode} - ${res.body}');
    }
  }

  //updateSubmission
  Future<Submission> updateSubmission(int submissionId,int assignmentId,int studentId,String content,int score,String imageUrl) async {
    final token = await TokenService.getToken();

    final res = await http.put(
        Uri.parse('${fullPath()}/$submissionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'assignmentId': assignmentId,
          'studentId': studentId,
          'content': content,
          'score': score,
          'imageUrl': imageUrl
        })
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Submission.fromJson(data);
    } else{
      throw Exception('Error updating submission: ${res.statusCode} - ${res.body}');
    }

  }

  //deleteSubmission

  Future<Submission> deleteSubmission(int submissionId) async {
    final token = await TokenService.getToken();

    final res = await http.delete(
        Uri.parse('${fullPath()}/$submissionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==204){
      final data = jsonDecode(res.body);
      return Submission.fromJson(data);
    } else{
      throw Exception('Error deleting submission: ${res.statusCode} - ${res.body}');
    }

  }

  //getSubmissionById
  Future<Submission> getSubmissionById(int submissionId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/$submissionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Submission.fromJson(data);
    } else{
      throw Exception('Error fetching submission: ${res.statusCode} - ${res.body}');
    }

  }

  //getAllSubmissions
  Future<List<Submission>> getAllSubmissions() async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions: ${res.statusCode} - ${res.body}');
    }

  }


  //getSubmissionsByAssignmentIdQuery
  Future<List<Submission>> getSubmissionsByAssignmentId(int assignmentId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/assignment/$assignmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions by assignment ID: ${res.statusCode} - ${res.body}');
    }

  }

  //getSubmissionsByStudentId
  Future<List<Submission>> getSubmissionsByStudentId(int studentId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/student/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions by student ID: ${res.statusCode} - ${res.body}');
    }

  }

  //getSubmissionsByStudentIdAndAssignmentId
  Future<List<Submission>> getSubmissionsByStudentIdAndAssignmentId(int studentId, int assignmentId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/student/$studentId/assignment/$assignmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions by student ID and assignment ID: ${res.statusCode} - ${res.body}');
    }

  }

  //getSubmissionsByStudentIdAndCourseId
  Future<List<Submission>> getSubmissionsByStudentIdAndCourseId(int studentId, int courseId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/student/$studentId/course/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions by student ID and course ID: ${res.statusCode} - ${res.body}');
    }

  }

  //getSubmissionsByCourseId
  Future<List<Submission>> getSubmissionsByCourseId(int courseId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
        Uri.parse('${fullPath()}/course/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(res.statusCode==200){
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Submission.fromJson(json)).toList();
    } else{
      throw Exception('Error fetching submissions by course ID: ${res.statusCode} - ${res.body}');
    }

  }

  //gradeSubmission
  Future<Submission> gradeSubmission(int submissionId, int score) async {
    final token = await TokenService.getToken();

    debugPrint('🌐 Calificando submission $submissionId con score: $score');

    final res = await http.put(
        Uri.parse('${fullPath()}/$submissionId/grade'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'score': score
        })
    );

    debugPrint('📡 Response status: ${res.statusCode}');
    debugPrint('📡 Response body: ${res.body}');

    if(res.statusCode==200){
      final data = jsonDecode(res.body);
      return Submission.fromJson(data);
    } else{
      throw Exception('Error grading submission: ${res.statusCode} - ${res.body}');
    }
  }

  // addFilesToSubmission
  Future<List<String>> addFilesToSubmission(int submissionId, List<http.MultipartFile> files) async {
    final token = await TokenService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${fullPath()}/$submissionId/files'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    // Agregar archivos binarios
    for (var file in files) {
      request.files.add(file);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Error adding files to submission: ${response.statusCode} - ${response.body}');
    }
  }

  // removeFileFromSubmission - CORREGIDO
  Future<void> removeFileFromSubmission(int submissionId, String fileUrl) async {
    final token = await TokenService.getToken();

    // Usar Uri.replace para agregar query parameter de forma segura
    final uri = Uri.parse('${fullPath()}/$submissionId/files')
        .replace(queryParameters: {'fileUrl': fileUrl});

    final res = await http.delete(
      uri,  // ← URI con query parameter incluido
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (res.statusCode == 204) {
      return;
    } else {
      throw Exception('Error removing file from submission: ${res.statusCode} - ${res.body}');
    }
  }

  Future<List<String>> getFilesBySubmissionId(int submissionId) async {
    final token = await TokenService.getToken();

    final res = await http.get(
      Uri.parse('${fullPath()}/$submissionId/files'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<String>.from(data);
    } else if (res.statusCode == 404) {
      // 👇 Si el backend devuelve 404 pero la entrega existe,
      // devolvemos lista vacía sin lanzar error.
      return [];
    } else {
      throw Exception('Error fetching files for submission: ${res.statusCode} - ${res.body}');
    }
  }


}