import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionHistoryPage extends StatefulWidget {
  const EmotionHistoryPage({super.key});

  @override
  State<EmotionHistoryPage> createState() => _EmotionHistoryPageState();
}

class _EmotionHistoryPageState extends State<EmotionHistoryPage> {
  String _selectedFilter = '7 jours';

  final List<String> _filters = [
    '7 jours',
    '30 jours',
    '3 mois',
    'Personnalisé',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historique d\'émotions',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0221), Color(0xFF4A2C6D)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 12),
            Expanded(child: _buildEmotionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((f) {
          final isSelected = f == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = f);
              },
              selectedColor: const Color(0xFF00FF88),
              backgroundColor: Colors.white.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF00FF88)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmotionList() {
    // fake data pour template
    final items = [
      {'emotion': 'joie', 'score': 'Elevé', 'date': 'Aujourd\'hui, 10:30'},
      {'emotion': 'stress', 'score': 'Modéré', 'date': 'Hier, 21:15'},
      {'emotion': 'tristesse', 'score': 'Faible', 'date': 'Lun 14:05'},
    ];

    Color _emotionColor(String e) {
      switch (e) {
        case 'joie':
          return const Color(0xFF00FF88);
        case 'stress':
          return const Color(0xFFFF4466);
        case 'tristesse':
          return const Color(0xFF6B8EFF);
        default:
          return const Color(0xFF9B8FDB);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final emotion = item['emotion']!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _emotionColor(emotion).withOpacity(0.2),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: _emotionColor(emotion),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emotion.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Niveau: ${item['score']}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item['date']!,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
