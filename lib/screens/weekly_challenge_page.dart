import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/screens/weekly_challenge_detail_page.dart';
import 'package:projet_integration/services/weekly_challenge_service.dart';
import 'package:projet_integration/services/auth_service.dart';

class WeeklyChallengePage extends StatefulWidget {
  const WeeklyChallengePage({super.key});

  @override
  State<WeeklyChallengePage> createState() => _WeeklyChallengePageState();
}

class _WeeklyChallengePageState extends State<WeeklyChallengePage> {
  bool _loading = true;
  String? _error;
  List<WeeklyChallengeModel> _items = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _currentUserId = await AuthService.getCurrentUserId();
      print(_currentUserId);
      final items = await WeeklyChallengeService.listChallenges();
      print(items);
      final now = DateTime.now();
      final filtered = items.where((c) => isSameWeek(c.weekStart, now)).toList();

      setState(() => _items = filtered);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openChallenge(WeeklyChallengeModel c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeeklyChallengeDetailPage(challengeId: c.id)),
    );
  }

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
          'Challenge hebdomadaire',
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF))));
    if (_error != null) return Center(child: Text(_error!, style: GoogleFonts.poppins(color: Colors.white70), textAlign: TextAlign.center));
    if (_items.isEmpty) return Center(child: Text('Aucun challenge disponible pour le moment.', style: GoogleFonts.poppins(color: Colors.white70)));

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF00D4FF),
      backgroundColor: const Color(0xFF0D0221),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final c = _items[index];
          final participant = _currentUserId != null ? c.getParticipant(_currentUserId!) : null;
          final isDone = participant != null;
          final score = participant?.score;

          return GestureDetector(
            onTap: () => _openChallenge(c),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: c.isActive ? const Color(0xFF00FF88).withOpacity(0.7) : Colors.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sports_esports_rounded, color: c.isActive ? const Color(0xFF00FF88) : Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(c.description.isNotEmpty ? c.description : 'Challenge hebdomadaire', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text('Questions: ${c.questions.length}', style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 11)),
                        if (isDone)
                          Text('Score: $score', style: GoogleFonts.spaceGrotesk(color: const Color(0xFF00FF88), fontSize: 13)),
                      ],
                    ),
                  ),
                  if (!isDone) const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
