import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/assignments/viewmodels/submission_viewmodel.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/auth/services/user_service.dart';
import 'package:learnhive_mobile/core/l10n/app_localizations.dart';
import 'package:learnhive_mobile/core/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final user = await userService.getCurrentUser();

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
        SnackBar(content: Text('${AppLocalizations.of(context).errorLoadingFiles}: $e')),
      );
    }
  }

  Future<void> _addFilesToSubmission(AppLocalizations l10n) async {
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
        SnackBar(content: Text(l10n.filesUploadedSuccessfully)),
      );

      await _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorUploadingFiles}: $e')),
      );
    }
  }

  Future<void> _removeFileFromSubmission(String fileUrl, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteFile),
        content: Text(l10n.deleteFileConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final vm = Provider.of<SubmissionViewModel>(context, listen: false);
      await vm.removeFileFromSubmission(widget.submission.id, fileUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileDeletedSuccessfully)),
      );
      await _loadFiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorDeletingFile}: $e')),
      );
    }
  }

  Widget _buildFilesSection(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.submissionFiles,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_canEditSubmission && widget.submission.status == 'NOT_GRADED')
                  IconButton(
                    // icon: const Icon(Icons.attach_file_rounded),
                    icon: Text("Adjuntar"),
                    onPressed: () => _addFilesToSubmission(l10n),
                  )
                else if (_canEditSubmission && widget.submission.status == 'GRADED')
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      l10n.submissionGraded,
                      style: const TextStyle(
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
              Text(l10n.noFilesUploaded)
            else
              Column(
                children: _files.map((url) {
                  final name = url.split('/').last;
                  return ListTile(
                    // leading: const Icon(Icons.insert_drive_file),
                    leading: Text("Archivo"),
                    title: Text(name),
                    trailing: (_canEditSubmission && widget.submission.status == 'NOT_GRADED')
                        ? IconButton(
                      // icon: const Icon(Icons.delete, color: Colors.red),
                      icon: Text("Eliminar", style: TextStyle(color: Colors.red)),
                      onPressed: () => _removeFileFromSubmission(url, l10n),
                    )
                        : null,
                    onTap: () async {
                      final uri = Uri.parse(url);
                      try {
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                          throw l10n.couldNotOpenFile;
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.errorOpeningFile}: $e')),
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

  Widget _buildSubmissionInfo(AppLocalizations l10n) {
    final s = widget.submission;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    // child: const Icon(Icons.note, size: 50, color: Colors.grey),
                    child: Center(child: Text("Error")),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    Text("Info: "),
                    const SizedBox(width: 8),
                    Text(
                      "${l10n.status}: ${s.status}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (s.score != null)
                  Row(
                    children: [
                      // const Icon(Icons.grade, size: 16, color: Colors.grey),
                      Text("Nota: "),
                      const SizedBox(width: 8),
                      Text(
                        "${l10n.score}: ${s.score}",
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.submissionDetails),
            backgroundColor: _isTeacher ? Colors.blueAccent : Colors.lightBlueAccent,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: _loadFiles,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSubmissionInfo(l10n),
                const SizedBox(height: 16),
                _buildFilesSection(l10n),
              ],
            ),
          ),
        );
      },
    );
  }
}
