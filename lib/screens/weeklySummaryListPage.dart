import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/screens/weeklySummaryDetailPage.dart';
import 'package:projet_integration/services/weeklySummary_service.dart';

class WeeklySummaryListPage extends StatefulWidget {
  const WeeklySummaryListPage({super.key});

  @override
  State<WeeklySummaryListPage> createState() => _WeeklySummaryListPageState();
}

class _WeeklySummaryListPageState extends State<WeeklySummaryListPage> {
  bool _loading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _loading = true);
    final summary = await WeeklySummaryService.getPreviousWeekSummaryCurrentUser();
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text(
          "Résumé hebdomadaire",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
                      : _summary == null
                      ? Center(child: Text("Aucun résumé hebdomadaire", style: GoogleFonts.poppins(color: Colors.white60)))
                      : _buildWeeklySummaryCard(_summary!),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchSummary,
        label: const Text("Actualiser"),
        icon: const Icon(Icons.refresh),
        backgroundColor: const Color(0xFF6B5FF8),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A0B2E), Color(0xFF3D2C5C), Color(0xFF5B4FB3), Color(0xFF7B68C8)],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard(Map<String, dynamic> summary) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeeklySummaryDetailPage(summary: summary),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary['summaryText'] ?? "", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              "Période: ${_formatDate(summary['weekStart'])} - ${_formatDate(summary['weekEnd'])}",
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              "Émotion dominante: ${summary['predominantEmotion'] ?? "N/A"}",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              "Nombre de séances: ${summary['sessionsCount'] ?? "N/A"}",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text("Voir détails...", style: GoogleFonts.orbitron(color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      final dt = DateTime.parse(date as String);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return date.toString();
    }
  }
}
