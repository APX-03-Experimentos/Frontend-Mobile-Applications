import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/assignments/viewmodels/submission_viewmodel.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/services/user_service.dart';

class SubmissionDetailsPage extends StatefulWidget {
  final Submission submission;

  const SubmissionDetailsPage({super.key, required this.submission});

  @override
  State<SubmissionDetailsPage> createState() => _SubmissionDetailsPageState();
}

class _SubmissionDetailsPageState extends State<SubmissionDetailsPage> {
  bool _isTeacher = false;
  List<String> _files = [];
  final userService = UserService();
  int? _currentUserId;

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUser();
      _loadFiles();
    });
  }

  Future<void> _initUser() async {
    final isTeacher = await TokenService.isTeacher();
    final user = await userService.getCurrentUser(); // <-- asegúrate de que devuelve un User con id

    setState(() {
      _isTeacher = isTeacher;
      _currentUserId = user.id;
    });
  }

  bool get _canEditSubmission {
    return !_isTeacher && _currentUserId == widget.submission.studentId;
  }

  // =================== FILES SECTION ===================

  Future<void> _loadFiles() async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    try {
      final files = await vm.getFilesBySubmissionId(widget.submission.id);
      setState(() => _files = files);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar archivos: $e')),
      );
    }
  }

  Future<void> _addFilesToSubmission() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final vm = Provider.of<SubmissionViewModel>(context, listen: false);
      final List<http.MultipartFile> multipartFiles = result.files
          .where((file) => file.bytes != null)
          .map((file) => http.MultipartFile.fromBytes(
        'files',
        file.bytes!,
        filename: file.name,
      ))
          .toList();

      await vm.addFilesToSubmission(widget.submission.id, multipartFiles);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivos subidos correctamente')),
      );

      await _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivos: $e')),
      );
    }
  }

  Future<void> _removeFileFromSubmission(String fileUrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: const Text('¿Seguro que deseas eliminar este archivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vm = Provider.of<SubmissionViewModel>(context, listen: false);
      await vm.removeFileFromSubmission(widget.submission.id, fileUrl);
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

  Widget _buildFilesSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Archivos de la entrega',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_canEditSubmission && widget.submission.status == 'NOT_GRADED')
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addFilesToSubmission,
                  )
                else if (_canEditSubmission && widget.submission.status == 'GRADED')
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Entrega calificada',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_files.isEmpty)
              const Text('No hay archivos subidos.')
            else
              Column(
                children: _files.map((url) {
                  final name = url.split('/').last;
                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(name),
                    trailing: (_canEditSubmission && widget.submission.status == 'NOT_GRADED')
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFileFromSubmission(url),
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

  // =================== SUBMISSION INFO ===================

  Widget _buildSubmissionInfo() {
    final s = widget.submission;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                s.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.note, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          // Info básica
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Estado: ${s.status}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (s.score != null)
                  Row(
                    children: [
                      const Icon(Icons.grade, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Puntaje: ${s.score}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                if (s.content.isNotEmpty)
                  Text(
                    s.content,
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================== BUILD ===================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de la entrega"),
        backgroundColor: _isTeacher ? Colors.blueAccent : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFiles,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSubmissionInfo(),
            const SizedBox(height: 16),
            _buildFilesSection(),
          ],
        ),
      ),
    );
  }
}
