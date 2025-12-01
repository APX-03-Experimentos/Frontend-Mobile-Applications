import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learnhive_mobile/assignments/model/assignment.dart';
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/assignments/views/submission_details_view.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:learnhive_mobile/core/l10n/app_localizations.dart';
import 'package:learnhive_mobile/core/providers/theme_provider.dart';
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
        SnackBar(content: Text('${AppLocalizations.of(context).errorLoadingFiles}: $e')),
      );
    }
  }

  Future<void> _addFilesToAssignment(AppLocalizations l10n) async {
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

      setState(() {
        _files.addAll(uploadedUrls);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.filesUploadedSuccessfully)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorUploadingFiles}: $e')),
      );
    }
  }

  Future<void> _removeFileFromAssignment(String fileUrl, AppLocalizations l10n) async {
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
      final vm = Provider.of<AssignmentViewModel>(context, listen: false);
      await vm.removeFileFromAssignment(widget.assignment.id, fileUrl);
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
                Text(l10n.assignmentFiles, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_isTeacher)
                  TextButton(
                    // icon: const Icon(Icons.file_upload_rounded),
                    child: const Text("Subir archivo"),
                    onPressed: () => _addFilesToAssignment(l10n),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_files.isEmpty)
              Text(l10n.noFilesAvailable)
            else
              Column(
                children: _files.map((url) {
                  final name = url.split('/').last;
                  return ListTile(
                    // leading: const Icon(Icons.insert_drive_file_rounded),
                    leading: const Text("Archivo"),
                    title: Text(name),
                    trailing: _isTeacher
                        ? TextButton(
                      // icon: const Icon(Icons.delete_rounded, color: Colors.red),
                      child: const Text(
                        "Eliminar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => _removeFileFromAssignment(url, l10n),
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
      final isTeacher = await TokenService.isTeacher();
      final userId = await TokenService.getUserId();

      setState(() {
        _isTeacher = isTeacher;
        _userId = userId;
      });

      final vm = Provider.of<SubmissionViewModel>(context, listen: false);

      if (isTeacher) {
        await vm.getSubmissionsByAssignmentId(widget.assignment.id);
      } else if (userId != null) {
        await vm.getSubmissionsByStudentIdAndAssignmentId(userId, widget.assignment.id);
      }
    } catch (e) {
      debugPrint('ERROR en _initUserAndLoadSubmissions: $e');
    }
  }

  Future<void> _showCreateSubmissionDialog(AppLocalizations l10n) async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newSubmission),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: l10n.content),
              )
            ],
          ),
          actions: [
            TextButton(child: Text(l10n.cancel), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: Text(l10n.submit),
              onPressed: () async {
                await vm.createSubmission(
                  widget.assignment.id,
                  contentController.text,
                  'https://placehold.co/600x400',
                );
                Navigator.pop(context);
                await _loadSubmissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.submissionCreatedSuccessfully),
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

  Future<void> _showGradeDialog(Submission submission, AppLocalizations l10n) async {
    final vm = Provider.of<SubmissionViewModel>(context, listen: false);
    final scoreController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.gradeSubmission),
          content: TextField(
            controller: scoreController,
            decoration: InputDecoration(labelText: l10n.scoreHint),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(child: Text(l10n.cancel), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: Text(l10n.save),
              onPressed: () async {
                final score = int.tryParse(scoreController.text) ?? 0;
                await vm.gradeSubmission(submission.id, score);
                Navigator.pop(context);
                await _loadSubmissions();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.submissionGradedWithScore(score)),
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

  Widget _buildSubmissionCard(Submission submission, AppLocalizations l10n) {
    return InkWell(
      onTap: () {
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
              // Imagen
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
                        // child: const Icon(Icons.note, size: 20, color: Colors.grey),
                        child: const Center(child: Text("Sin imagen")),
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
                    Row(
                      children: [
                        // const Icon(Icons.description, size: 14, color: Colors.grey),
                        const Text("Descripción: "),
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

                    Row(
                      children: [
                        // const Icon(Icons.info, size: 14, color: Colors.grey),
                        const Text("Estado: "),
                        Text(
                          submission.status,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (submission.score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(submission.score),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${submission.score}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),

              if (_isTeacher && submission.score == 0)
                TextButton(
                  // icon: const Icon(Icons.grade, color: Colors.orange),
                  child: const Text("Calificar"),
                  onPressed: () => _showGradeDialog(submission, l10n),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 17) return Colors.green;
    if (score < 18 && score > 13) return Colors.yellowAccent.shade700;
    if (score < 14) return Colors.redAccent;
    return Colors.red;
  }

  Widget _buildAssignmentInfo(AppLocalizations l10n) {
    final a = widget.assignment;

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
                a.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    // child: const Icon(Icons.assignment, size: 50, color: Colors.grey),
                    child: const Center(child: Text("Sin imagen")),
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
                Text(
                  a.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                if (a.description?.isNotEmpty == true)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Icon(Icons.description, size: 16, color: Colors.grey),
                      const Text("Descripción: "),
                      Expanded(
                        child: Text(
                          a.description!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),

                if (a.deadline != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // const Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey),
                      const Text("Fecha límite: "),
                      Text(
                        "${a.deadline!.day}/${a.deadline!.month}/${a.deadline!.year}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final l10n = AppLocalizations.of(context);

            return Scaffold(
              appBar: AppBar(
                title: Text(widget.assignment.title),
                backgroundColor: _isTeacher ? Colors.blueAccent : Colors.lightBlueAccent,
                foregroundColor: Colors.white,
              ),

              floatingActionButton: !_isTeacher
                  ? FloatingActionButton(
                onPressed: () => _showCreateSubmissionDialog(l10n),
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                child: const Text("+"),
              )
                  : null,

              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: _loadSubmissions,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAssignmentInfo(l10n),
                    const SizedBox(height: 16),
                    _buildFilesSection(l10n),
                    const SizedBox(height: 16),

                    Text(
                      l10n.submissions,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 12),

                    if (submissions.isEmpty)
                      Center(child: Text(l10n.noSubmissionsRegistered))
                    else
                      ...submissions.map((s) => _buildSubmissionCard(s, l10n)).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
