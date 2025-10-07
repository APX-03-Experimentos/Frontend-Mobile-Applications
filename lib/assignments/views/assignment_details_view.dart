import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:learnhive_mobile/assignments/model/assignment.dart';
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/assignments/views/submission_details_view.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodels/assignment_viewmodel.dart';
import '../viewmodels/submission_viewmodel.dart';

class AssignmentDetailsPage extends StatefulWidget {
  final Assignment assignment;

  const AssignmentDetailsPage({super.key, required this.assignment});

  @override
  State<AssignmentDetailsPage> createState() => _AssignmentDetailsPageState();
}

class _AssignmentDetailsPageState extends State<AssignmentDetailsPage> {
  bool _isTeacher = false;
  int? _userId;
  List<String> _files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserAndLoadSubmissions();
      _loadFiles();
    });
  }

  //FILES SECTIONS

// ======================= FILES SECTION =======================



  Future<void> _loadFiles() async {
    final vm = Provider.of<AssignmentViewModel>(context, listen: false);
    try {
      final files = await vm.getFilesByAssignmentId(widget.assignment.id);
      setState(() {
        _files = files;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar archivos: $e')),
      );
    }
  }

// 📤 SUBIR ARCHIVOS
  Future<void> _addFilesToAssignment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final assignmentVm = Provider.of<AssignmentViewModel>(context, listen: false);
      final List<http.MultipartFile> multipartFiles = result.files
          .where((file) => file.bytes != null)
          .map((file) => http.MultipartFile.fromBytes(
        'files',
        file.bytes!,
        filename: file.name,
      ))
          .toList();

      final uploadedUrls = await assignmentVm.addFilesToAssignment(
        widget.assignment.id,
        multipartFiles,
      );

      // ✅ Agregamos directamente los nuevos archivos sin recargar
      setState(() {
        _files.addAll(uploadedUrls);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivos subidos correctamente')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivos: $e')),
      );
    }
  }

// ❌ ELIMINAR ARCHIVO
  Future<void> _removeFileFromAssignment(String fileUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Seguro que deseas eliminar este archivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vm = Provider.of<AssignmentViewModel>(context, listen: false);
      await vm.removeFileFromAssignment(widget.assignment.id, fileUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo eliminado correctamente')),
      );
      await _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar archivo: $e')),
      );
    }
  }

  // 📁 SECCIÓN DE ARCHIVOS (solo editable para profesores)
  Widget _buildFilesSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + botón de agregar (solo profesor)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Archivos del assignment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_isTeacher) // 👈 solo si es profesor
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addFilesToAssignment,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Contenido de archivos
            if (_files.isEmpty)
              const Text('No hay archivos disponibles.')
            else
              Column(
                children: _files.map((url) {
                  final name = url.split('/').last;
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(name),
                    trailing: _isTeacher
                        ? IconButton( // 👈 solo el profesor puede eliminar
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFileFromAssignment(url),
                    )
                        : null,
                    onTap: () async {
                      final uri = Uri.parse(url);

                      try {
                        // Intentar abrir directamente en navegador externo (Chrome, Safari, etc.)
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          throw 'No se pudo abrir el archivo.';
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al abrir el archivo: $e')),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }



  //FILES SECTIONS

  Future<void> _loadSubmissions() async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    if (_isTeacher) {
      await vm.getSubmissionsByAssignmentId(widget.assignment.id);
    } else if (_userId != null) {
      await vm.getSubmissionsByStudentIdAndAssignmentId(_userId!, widget.assignment.id);
    }
  }

  Future<void> _initUserAndLoadSubmissions() async {
    try {
      debugPrint('🔄 INICIANDO _initUserAndLoadSubmissions');

      final isTeacher = await TokenService.isTeacher();
      final userId = await TokenService.getUserId();

      // ✅ DEBUG: Mostrar valores obtenidos
      debugPrint('👤 DATOS DEL USUARIO:');
      debugPrint('   - isTeacher: $isTeacher');
      debugPrint('   - userId: $userId');
      debugPrint('   - assignment.id: ${widget.assignment.id}');

      setState(() {
        _isTeacher = isTeacher;
        _userId = userId;
      });

      final vm = Provider.of<SubmissionViewModel>(context, listen: false);

      debugPrint('🎯 EJECUTANDO CARGA:');
      if (isTeacher) {
        debugPrint('   - Modo: PROFESOR');
        debugPrint('   - Llamando: getSubmissionsByAssignmentId(${widget.assignment.id})');
        await vm.getSubmissionsByAssignmentId(widget.assignment.id);
      } else if (userId != null) {
        debugPrint('   - Modo: ESTUDIANTE');
        debugPrint('   - Llamando: getSubmissionsByStudentIdAndAssignmentId($userId, ${widget.assignment.id})');
        await vm.getSubmissionsByStudentIdAndAssignmentId(userId, widget.assignment.id);
      } else {
        debugPrint('❌ ERROR: userId es NULL para estudiante');
      }

      debugPrint('✅ CARGA COMPLETADA');

    } catch (e) {
      debugPrint('❌ ERROR en _initUserAndLoadSubmissions: $e');
    }
  }

  Future<void> _showCreateSubmissionDialog() async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Entrega'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
              )
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Enviar'),
              onPressed: () async {
                await vm.createSubmission(
                  widget.assignment.id,
                  contentController.text,
                  'https://placehold.co/600x400',
                );
                Navigator.pop(context);
                await _loadSubmissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entrega creada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showGradeDialog(Submission submission) async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    final scoreController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calificar Entrega'),
          content: TextField(
            controller: scoreController,
            decoration: const InputDecoration(labelText: 'Puntaje (0-20)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final score = int.tryParse(scoreController.text) ?? 0;
                await vm.gradeSubmission(submission.id, score);
                Navigator.pop(context);
                await _loadSubmissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entrega calificada con $score puntos'),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmissionCard(Submission submission) {
    return InkWell(
      onTap: () {
        // Navega a la vista de detalles de la entrega
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionDetailsPage(submission: submission),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del submission
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    submission.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.note,
                          size: 20,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contenido con ícono
                    Row(
                      children: [
                        const Icon(Icons.description, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            submission.content,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Estado
                    Row(
                      children: [
                        const Icon(Icons.info, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "Estado: ${submission.status}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Score a la derecha (solo si está calificado)
              if (submission.score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(submission.score),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grade, size: 16, color: Colors.white),
                      const SizedBox(height: 2),
                      Text(
                        '${submission.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              // Botón de calificar para profesores
              if (_isTeacher && submission.score == 0)
                IconButton(
                  icon: const Icon(Icons.grade, color: Colors.orange),
                  onPressed: () => _showGradeDialog(submission),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 17) return Colors.green;
    if (score <18 && score>13) return Colors.yellowAccent.shade700;
    if (score <14) return Colors.redAccent;
    return Colors.red;
  }

  Widget _buildAssignmentInfo() {
    final a = widget.assignment;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del assignment - MÁS GRANDE Y ENCIMA
          Container(
            height: 180, // Más grande
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                a.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.assignment,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          // Información del assignment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (a.description?.isNotEmpty == true)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                if (a.deadline != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Vence: ${a.deadline!.day}/${a.deadline!.month}/${a.deadline!.year}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubmissionViewModel>(
      builder: (context, vm, child) {
        final submissions = vm.submissions;
        final isLoading = vm.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.assignment.title),
            backgroundColor: _isTeacher ? Colors.blueAccent : Colors.green,
            foregroundColor: Colors.white,
          ),
          floatingActionButton: !_isTeacher
              ? FloatingActionButton(
            onPressed: _showCreateSubmissionDialog,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          )
              : null,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _loadSubmissions,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                _buildAssignmentInfo(),

                const SizedBox(height: 16),

                _buildFilesSection(),

                const SizedBox(height: 16),

                Text(
                  "Entregas",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (submissions.isEmpty)
                  const Center(
                    child: Text("No hay entregas registradas."),
                  )
                else
                  ...submissions.map(_buildSubmissionCard).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
