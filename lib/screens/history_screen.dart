import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/services/auth_service.dart';

class HistoryItem {
  final String id;
  final String emotion;
  final double durationSec;
  final DateTime date;
  final String summary;

  HistoryItem({
    required this.id,
    required this.emotion,
    required this.durationSec,
    required this.date,
    required this.summary,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryItem> _all = [
    HistoryItem(id: '1', emotion: 'anxiété', durationSec: 32.4, date: DateTime.now().subtract(const Duration(hours: 2)), summary: 'Exercice respiration proposé'),
    HistoryItem(id: '2', emotion: 'joie', durationSec: 18.2, date: DateTime.now().subtract(const Duration(days: 1)), summary: 'Renforcement positif'),
    HistoryItem(id: '3', emotion: 'stress', durationSec: 45.0, date: DateTime.now().subtract(const Duration(days: 3)), summary: 'Suggestions d’organisation'),
  ];

  String _filter = 'toutes';

  List<HistoryItem> get _filtered {
    if (_filter == 'toutes') return _all;
    return _all.where((e) => e.emotion == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0D0221), Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF4A2C6D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilters(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/voice_to_ai'),
        icon: const Icon(Icons.mic_rounded),
        label: const Text('Nouvelle session'),
        backgroundColor: const Color(0xFF6B5FF8),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text('Historique', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/payment'),
            icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
            tooltip: 'S’abonner',
          ),

        ],
      ),
    );
  }

  Widget _buildFilters() {
    final emotions = ['toutes', 'anxiété', 'stress', 'tristesse', 'joie'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: emotions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final e = emotions[i];
          final selected = e == _filter;
          return ChoiceChip(
            label: Text(e, style: GoogleFonts.poppins(color: Colors.white)),
            selected: selected,
            onSelected: (_) => setState(() => _filter = e),
            selectedColor: const Color(0xFF6B5FF8),
            backgroundColor: Colors.white.withOpacity(0.12),
            shape: StadiumBorder(side: BorderSide(color: selected ? Colors.white : Colors.white24)),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('Aucun élément', style: GoogleFonts.poppins(color: Colors.white70)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = _filtered[i];
        return InkWell(
          onTap: () {
            // TODO: Ouvrir le détail de la session
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                _emotionBadge(item.emotion),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.summary, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_formatMeta(item), style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _all.removeWhere((x) => x.id == item.id)),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emotionBadge(String emotion) {
    final map = {
      'anxiété': const [Color(0xFFFFAA00), Color(0xFFFF6600)],
      'tristesse': [const Color(0xFF6B8EFF), const Color(0xFF4A6FE8)],
      'joie': [const Color(0xFF00FF88), const Color(0xFF00CC6A)],
      'stress': [const Color(0xFFFF4466), const Color(0xFFFF2244)],
      'toutes': [Colors.white70, Colors.white60],
    };
    final colors = map[emotion] ?? [Colors.white70, Colors.white60];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: colors),
      ),
      child: Text(
        emotion.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1),
      ),
    );
  }

  String _formatMeta(HistoryItem i) {
    final d = '${i.date.day.toString().padLeft(2, '0')}/${i.date.month.toString().padLeft(2, '0')}/${i.date.year}';
    final t = '${i.date.hour.toString().padLeft(2, '0')}:${i.date.minute.toString().padLeft(2, '0')}';
    return '$d • $t • ${i.durationSec.toStringAsFixed(1)}s';
  }
}
