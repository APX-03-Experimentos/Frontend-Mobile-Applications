import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCoursesService {
  static const String _userCoursesKey = 'user_courses_ids';

  // Guardar IDs de cursos del usuario
  static Future<void> saveUserCourses(List<int> courseIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesString = courseIds.map((id) => id.toString()).join(',');
      await prefs.setString(_userCoursesKey, coursesString);
      debugPrint('📚 [UserCoursesService] Cursos guardados: $courseIds');
    } catch (e) {
      debugPrint('❌ [UserCoursesService] Error guardando cursos: $e');
    }
  }

  // Obtener IDs de cursos del usuario
  static Future<List<int>> getUserCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesString = prefs.getString(_userCoursesKey) ?? '';

      if (coursesString.isEmpty) {
        debugPrint('📚 [UserCoursesService] No hay cursos guardados');
        return [];
      }

      final courseIds = coursesString.split(',')
          .map((id) => int.tryParse(id) ?? 0)
          .where((id) => id > 0) // Filtrar IDs inválidos
          .toList();

      debugPrint('📚 [UserCoursesService] Cursos cargados: $courseIds');
      return courseIds;
    } catch (e) {
      debugPrint('❌ [UserCoursesService] Error cargando cursos: $e');
      return [];
    }
  }

  // Limpiar cursos (al cerrar sesión)
  static Future<void> clearUserCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userCoursesKey);
      debugPrint('📚 [UserCoursesService] Cursos limpiados');
    } catch (e) {
      debugPrint('❌ [UserCoursesService] Error limpiando cursos: $e');
    }
  }

  // Agregar un curso específico
  static Future<void> addUserCourse(int courseId) async {
    try {
      final currentCourses = await getUserCourses();
      if (!currentCourses.contains(courseId)) {
        currentCourses.add(courseId);
        await saveUserCourses(currentCourses);
        debugPrint('📚 [UserCoursesService] Curso agregado: $courseId');
      }
    } catch (e) {
      debugPrint('❌ [UserCoursesService] Error agregando curso: $e');
    }
  }

  // Verificar si el usuario está en un curso
  static Future<bool> isUserInCourse(int courseId) async {
    final userCourses = await getUserCourses();
    return userCourses.contains(courseId);
  }
}