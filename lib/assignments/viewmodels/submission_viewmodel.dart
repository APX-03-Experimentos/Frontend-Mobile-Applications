import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/submission.dart';
import '../services/submission_service.dart';

class SubmissionViewModel extends ChangeNotifier {
  final _submissionService = SubmissionService();

  Submission?  _submission;
  bool _isLoading = false;
  String? _error;
  List<Submission> _submissions = []; // ← Para listas de submissions

  Submission? get submission => _submission;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Submission> get submissions => _submissions;

  //createSubmission
  Future<Submission> createSubmission(int assignmentId,String content,String imageUrl) async {
    _setLoading(true);
    try {
      _submission = await _submissionService.createSubmission(assignmentId,content,imageUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submission!;

  }

  //updateSubmission
  Future<Submission> updateSubmission(int submissionId,int assignmentId,int studentId,String content,int score,String imageUrl) async {
    _setLoading(true);
    try {
      _submission = await _submissionService.updateSubmission(submissionId,assignmentId,studentId,content,score,imageUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submission!;

  }

  //deleteSubmission

  Future<Submission> deleteSubmission(int submissionId) async {
    _setLoading(true);
    try {
      final deletedSubmission = await _submissionService.getSubmissionById(submissionId);
      await _submissionService.deleteSubmission(submissionId);
      _error = null;
      _setLoading(false);
      return deletedSubmission;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    }

  }

  //getSubmissionById
  Future<Submission> getSubmissionById(int submissionId) async {
    _setLoading(true);
    try {
      _submission = await _submissionService.getSubmissionById(submissionId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submission!;

  }

  //getAllSubmissions
  Future<List<Submission>> getAllSubmissions() async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getAllSubmissions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;

  }


  //getSubmissionsByAssignmentIdQuery
  Future<List<Submission>> getSubmissionsByAssignmentId(int assignmentId) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getSubmissionsByAssignmentId(assignmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;

  }

  //getSubmissionsByStudentId
  Future<List<Submission>> getSubmissionsByStudentId(int studentId) async {

    _setLoading(true);
    try {
      _submissions = await _submissionService.getSubmissionsByStudentId(studentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;

  }

  //getSubmissionsByStudentIdAndAssignmentId
  Future<List<Submission>> getSubmissionsByStudentIdAndAssignmentId(int studentId, int assignmentId) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getSubmissionsByStudentIdAndAssignmentId(studentId, assignmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;
  }

  //getSubmissionsByStudentIdAndCourseId
  Future<List<Submission>> getSubmissionsByStudentIdAndCourseId(int studentId, int courseId) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getSubmissionsByStudentIdAndCourseId(studentId, courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;
  }

  //getSubmissionsByCourseId
  Future<List<Submission>> getSubmissionsByCourseId(int courseId) async {
    _setLoading(true);
    try {
      _submissions = await _submissionService.getSubmissionsByCourseId(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submissions;
  }

  //gradeSubmission
  Future<Submission> gradeSubmission(int submissionId, int score) async {
    _setLoading(true);
    try {
      _submission = await _submissionService.gradeSubmission(submissionId, score);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _submission!;
  }

  // addFilesToSubmission
  Future<List<String>> addFilesToSubmission(int submissionId, List<http.MultipartFile> files) async {
    _setLoading(true);
    try {
      final fileUrls = await _submissionService.addFilesToSubmission(submissionId, files);
      _error = null;
      _setLoading(false);
      return fileUrls;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    }
  }

  // removeFileFromSubmission - CORREGIDO
  Future<void> removeFileFromSubmission(int submissionId, String fileUrl) async {
    _setLoading(true);
    try {
      await _submissionService.removeFileFromSubmission(submissionId, fileUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}