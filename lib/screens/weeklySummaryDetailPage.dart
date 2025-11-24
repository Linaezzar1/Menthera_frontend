import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklySummaryDetailPage extends StatelessWidget {
  final Map<String, dynamic> summary;
  const WeeklySummaryDetailPage({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List? sessions = summary['sessionsSummary'] as List?;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Détail du résumé", style: GoogleFonts.orbitron()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bloc résumé principal
          Card(
            elevation: 2,
            color: Colors.deepPurple.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summary['summaryText'] ?? "", style: GoogleFonts.orbitron(fontSize: 19, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _infoRow("Période", "${_formatDate(summary['weekStart'])} à ${_formatDate(summary['weekEnd'])}"),
                  _infoRow("Durée totale", "${summary['totalDurationSec']}s"),
                  _infoRow("Émotion dominante", "${summary['predominantEmotion'] ?? "N/A"}"),
                  _infoRow("Nombre de séances", "${summary['sessionsCount'] ?? "N/A"}"),
                  _infoRow("Note moyenne", summary['averageRating'] == null ? "N/A" : "${summary['averageRating']}"),
                  const SizedBox(height: 8),
                  Text("Généré le : ${_formatDate(summary['metadata']?['generatedAt'])}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.deepPurple)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text("Détails des séances", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
          const Divider(),
          if (sessions != null && sessions.isNotEmpty)
            ...sessions.map((sess) => _buildSessionTile(sess)).toList()
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text("Aucune séance cette semaine.", style: GoogleFonts.poppins(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(label + " : ", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.deepPurple)),
          Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSessionTile(dynamic sess) {
    final color = _emotionColor(sess['emotion']);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: color.withOpacity(0.13),
      child: ListTile(
        leading: Icon(Icons.event_note, color: color),
        title: Text(_formatDate(sess['sessionDate']), style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Émotion: ${sess['emotion'] ?? "N/A"}", style: GoogleFonts.poppins(fontSize: 13, color: color)),
            Text("Durée: ${sess['durationSec']}s – Note: ${sess['rating'] ?? "N/A"}", style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Color _emotionColor(String? emotion) {
    switch (emotion?.toLowerCase()) {
      case 'joie': return Colors.green;
      case 'tristesse': return Colors.blue;
      case 'colere': return Colors.red;
      case 'anxiete': return Colors.orangeAccent;
      case 'peur': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    try {
      final dt = DateTime.parse(date as String);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return date.toString();
    }
  }
}
