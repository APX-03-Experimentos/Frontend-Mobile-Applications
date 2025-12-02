import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/assignment.dart';

import '../services/assignment_service.dart';

class AssignmentViewModel extends ChangeNotifier {
  final _assignmentService = AssignmentService();

  Assignment? _assignment;
  bool _isLoading = false;
  String? _error;
  List<Assignment> _assignments = [];

  Assignment? get assignment => _assignment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Assignment> get assignments => _assignments;

  List<String> _files = [];
  List<String> get files => _files;

  // ✅ AGREGAR ESTE MÉTODO para limpiar las asignaciones
  void clearAssignments() {
    _assignments = [];
    notifyListeners();
    debugPrint('🧹 [AssignmentViewModel] Assignments limpiados');
  }

  //createAssignment
  Future<Assignment?> createAssignment(String title,String description,int courseId,DateTime deadline,String imageUrl) async{
    _setLoading(true);
    try {
      _assignment = await _assignmentService.createAssignment(title,description,courseId,deadline,imageUrl);
      _error = null;

      // ✅ Agregar la nueva asignación a la lista
      if (_assignment != null) {
        _assignments.add(_assignment!);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _assignment;
  }

  //updateAssignment
  Future<Assignment?> updateAssignment(int assignmentId, String title,String description,int courseId,DateTime deadline,String imageUrl) async{
    _setLoading(true);
    try {
      _assignment = await _assignmentService.updateAssignment(assignmentId,title,description,courseId,deadline,imageUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _assignment;
  }

  //deleteAssignment
  Future<Assignment> deleteAssignment(int assignmentId) async{
    _setLoading(true);
    try {
      final deletedAssignment = await _assignmentService.getAssignmentById(assignmentId);
      await _assignmentService.deleteAssignment(assignmentId);
      _error = null;
      _setLoading(false);
      return deletedAssignment;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    }
  }

  //getAssignmentById
  Future<Assignment?> getAssignmentById(int assignmentId) async{
    _setLoading(true);
    try {
      _assignment = await _assignmentService.getAssignmentById(assignmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _assignment;
  }

  //getAllAssignments
  Future<List<Assignment>> getAllAssignments() async{
    _setLoading(true);
    try {
      _assignments = await _assignmentService.getAllAssignments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
    return _assignments;
  }

  //getAssignmentsByCourseId
  Future<List<Assignment>> getAssignmentsByCourseId(int courseId) async{
    _setLoading(true);
    try {
      _assignments = await _assignmentService.getAssignmentsByCourseId(courseId);
      _error = null;
      debugPrint('📋 [AssignmentViewModel] Cargadas ${_assignments.length} asignaciones para curso $courseId');
    } catch (e) {
      _error = e.toString();
      _assignments = []; // Limpiar en caso de error
    }
    _setLoading(false);
    return _assignments;
  }

  // addFilesToAssignment - CORREGIDO (subir archivos binarios)
  Future<List<String>> addFilesToAssignment(int assignmentId, List<http.MultipartFile> files) async {
    _setLoading(true);
    try {
      final fileUrls = await _assignmentService.addFilesToAssignment(assignmentId, files);
      _error = null;
      _setLoading(false);
      return fileUrls;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow; // Propagar la excepción para que el llamador pueda manejarla
    }
  }

  // removeFileFromAssignment - CORREGIDO
  Future<void> removeFileFromAssignment(int assignmentId, String fileUrl) async {
    _setLoading(true);
    try {
      await _assignmentService.removeFileFromAssignment(assignmentId, fileUrl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<List<String>> getFilesByAssignmentId(int assignmentId) async {
    _setLoading(true);
    try {
      final files = await _assignmentService.getFilesByAssignmentId(assignmentId);
      _error = null;
      _setLoading(false);
      return files;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }








  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}