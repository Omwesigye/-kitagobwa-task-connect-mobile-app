import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/admin_service.dart';


class AdminReportsPage extends StatefulWidget {
  final AdminService service;
  const AdminReportsPage({super.key, required this.service});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  List reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      reports = await widget.service.fetchReports();
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text('No reports available'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final user = report['user'] ?? {};
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: const Icon(Icons.report_problem),
                        title: Text(report['category']?.toString() ?? 'Report'),
                        subtitle: Text(
                            'By: ${user['email']?.toString() ?? 'Unknown'}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KeyValueRow(
                                    label: 'ID', value: report['id']?.toString()),
                                KeyValueRow(
                                    label: 'Urgency',
                                    value: report['urgency']?.toString()),
                                KeyValueRow(
                                    label: 'Status',
                                    value: report['status']?.toString()),
                                KeyValueRow(
                                    label: 'Description',
                                    value: report['description']?.toString()),
                                if (report['image_path'] != null)
                                  KeyValueRow(
                                      label: 'Image',
                                      value: report['image_path'].toString()),
                                if (report['created_at'] != null)
                                  KeyValueRow(
                                      label: 'Created',
                                      value: report['created_at'].toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ---------------- Reusable KeyValueRow Widget ----------------
class KeyValueRow extends StatelessWidget {
  final String label;
  final String? value;
  const KeyValueRow({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }
}
