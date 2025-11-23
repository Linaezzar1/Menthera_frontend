import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/user_service.dart';

class EmotionHistoryPage extends StatefulWidget {
  const EmotionHistoryPage({super.key});

  @override
  State<EmotionHistoryPage> createState() => _EmotionHistoryPageState();
}

class _EmotionHistoryPageState extends State<EmotionHistoryPage> {
  bool _loading = true;
  List<dynamic> _rawEmotions = [];
  String _filter = 'toutes';

  @override
  void initState() {
    super.initState();
    _fetchEmotions();
  }

  Future<void> _fetchEmotions() async {
    setState(() => _loading = true);
    final user = await UserService.getProfile();
    if (user != null && user['emotionHistory'] is List) {
      setState(() {
        _rawEmotions = (user['emotionHistory'] as List).reversed.toList();
        _loading = false;
      });
    } else {
      setState(() {
        _rawEmotions = [];
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredEmotions {
    if (_filter == 'toutes') return _rawEmotions;
    return _rawEmotions.where((e) =>
    (e['emotion'] ?? 'neutre').toLowerCase() == _filter.toLowerCase()
    ).toList();
  }

  // Utility: Always convert to double for safety
  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text(
          'Historique Émotions',
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
                _buildFilters(),
                Expanded(
                  child: _loading
                      ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
                      : _buildList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchEmotions,
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

  Widget _buildFilters() {
    final emotions = ['toutes', 'joie', 'tristesse', 'colere', 'anxiete', 'peur', 'neutre'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: emotions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final e = emotions[i];
          final selected = e == _filter;
          return ChoiceChip(
            label: Text(e, style: GoogleFonts.poppins(color: Colors.white)),
            selected: selected,
            onSelected: (_) => setState(() => _filter = e),
            selectedColor: const Color(0xFF6B5FF8),
            backgroundColor: Colors.white.withOpacity(0.14),
            shape: StadiumBorder(
              side: BorderSide(color: selected ? Colors.white : Colors.white24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_filteredEmotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_neutral, size: 64, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              _filter == 'toutes'
                  ? "Aucune émotion enregistrée"
                  : "Aucune émotion de ce type",
              style: GoogleFonts.poppins(color: Colors.white60),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      itemCount: _filteredEmotions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (ctx, i) {
        final em = _filteredEmotions[i];
        return _emotionCard(em);
      },
    );
  }

  Widget _emotionCard(dynamic em) {
    final String emotion = em['emotion'] ?? "neutre";
    final double intensity = _toDouble(em['intensity']) * 100;
    final String date = em['timestamp'] ?? "";
    final icon = _iconByEmotion(emotion);
    final color = _colorByEmotion(emotion);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.36), width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 34),
        title: Text(
          emotion[0].toUpperCase() + emotion.substring(1),
          style: GoogleFonts.orbitron(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Intensité: ${intensity.toStringAsFixed(0)}%  •  ${_formatDate(date)}",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  IconData _iconByEmotion(String e) {
    switch (e.toLowerCase()) {
      case 'joie': return Icons.sentiment_very_satisfied;
      case 'tristesse': return Icons.sentiment_dissatisfied;
      case 'colere': return Icons.sentiment_very_dissatisfied;
      case 'anxiete': return Icons.sentiment_neutral;
      case 'peur': return Icons.warning_amber_rounded;
      default: return Icons.sentiment_satisfied;
    }
  }

  Color _colorByEmotion(String e) {
    switch (e.toLowerCase()) {
      case 'joie': return const Color(0xFF00FF88);
      case 'tristesse': return const Color(0xFF7194FF);
      case 'colere': return const Color(0xFFFF4466);
      case 'anxiete': return const Color(0xFFFFA500);
      case 'peur': return const Color(0xFFB678EE);
      default: return const Color(0xFF9B8FDB);
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return date;
    }
  }
}
