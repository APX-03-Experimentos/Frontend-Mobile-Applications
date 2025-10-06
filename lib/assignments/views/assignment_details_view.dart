import 'package:flutter/material.dart';
import 'package:learnhive_mobile/assignments/model/assignment.dart';
import 'package:learnhive_mobile/assignments/model/submission.dart';
import 'package:learnhive_mobile/auth/services/token_service.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUserAndLoadSubmissions();
    });
  }

  Future<void> _initUser() async {
    final isTeacher = await TokenService.isTeacher();
    final prefsId = await TokenService.getUserId();
    setState(() {
      _isTeacher = isTeacher;
      _userId = prefsId;
    });
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
                  contentController.text
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
            decoration: const InputDecoration(labelText: 'Puntaje (0-100)'),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          submission.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estado: ${submission.status}"),
            if (submission.score > 0) Text("Puntaje: ${submission.score}"),
            if (submission.fileUrls.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: submission.fileUrls.map((url) {
                  return InkWell(
                    onTap: () {

                    },
                    child: Chip(
                      label: Text(url.split('/').last),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: _isTeacher
            ? IconButton(
          icon: const Icon(Icons.grade, color: Colors.orange),
          onPressed: () => _showGradeDialog(submission),
        )
            : null,
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    final a = widget.assignment;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.description),
            const SizedBox(height: 6),
            Text("Fecha límite: ${a.deadline?.toLocal()}"),
          ],
        ),
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
