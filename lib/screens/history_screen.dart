import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _allSessions = [];
  bool _isLoading = true;
  bool _isPremium = false;
  int _displayed = 0;
  int _total = 0;
  String? _upgradeMessage;
  String _filter = 'toutes';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/voice/sessions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _allSessions = data['data']['sessions'] ?? [];
          _isPremium = data['data']['isPremium'] ?? false;
          _displayed = data['data']['displayed'] ?? 0;
          _total = data['data']['total'] ?? 0;
          _upgradeMessage = data['data']['message'];
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Erreur de chargement');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur: $e');
      _showErrorSnackBar('Erreur de connexion');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/voice/sessions/$sessionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _allSessions.removeWhere((s) => s['_id'] == sessionId);
        });
        _showSuccessSnackBar('Session supprimée');
      } else {
        _showErrorSnackBar('Impossible de supprimer');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur de suppression');
    }
  }

  List<dynamic> get _filteredSessions {
    if (_filter == 'toutes') return _allSessions;
    return _allSessions.where((s) =>
    (s['emotion'] ?? 'neutre').toLowerCase() == _filter.toLowerCase()
    ).toList();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6EC7),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00FF88),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF0D0221),
              Color(0xFF1A0B2E),
              Color(0xFF2D1B4E),
              Color(0xFF4A2C6D)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              if (_upgradeMessage != null) _buildUpgradeBanner(),
              _buildFilters(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/voice'),
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
          Text(
            'Historique',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (!_isPremium)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/payment'),
              icon: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700)),
              tooltip: 'S\'abonner',
            ),
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Actualiser',
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6EC7).withOpacity(0.2),
            const Color(0xFF6B5FF8).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6EC7).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _upgradeMessage!,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/payment'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6EC7), Color(0xFF6B5FF8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Passer à Premium',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final emotions = ['toutes', 'anxiété', 'stress', 'tristesse', 'joie', 'neutre'];
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
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? Colors.white : Colors.white24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
      );
    }

    if (_filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              _filter == 'toutes'
                  ? 'Aucune session enregistrée'
                  : 'Aucune session avec cette émotion',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF00D4FF),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final session = _filteredSessions[i];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(dynamic session) {
    final emotion = session['emotion'] ?? 'neutre';
    final emotionColor = _getEmotionColor(emotion);

    return InkWell(
      onTap: () {
        // TODO: Naviguer vers détail de session
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: emotionColor.withOpacity(0.5), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _emotionBadge(emotion, emotionColor),
                    Text(
                      _formatDate(session['createdAt']),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (session['transcription'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    session['transcription'],
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (session['therapistResponse'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology,
                            color: Color(0xFF00D4FF), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session['therapistResponse'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _confirmDelete(session['_id']),
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white70, size: 20),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Supprimer la session ?',
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSession(sessionId);
            },
            child: Text('Supprimer', style: GoogleFonts.spaceGrotesk(color: const Color(0xFFFF6EC7))),
          ),
        ],
      ),
    );
  }

  Widget _emotionBadge(String emotion, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        emotion.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joie':
        return const Color(0xFF00FF88);
      case 'tristesse':
        return const Color(0xFF6B8EFF);
      case 'anxiété':
      case 'anxiete':
      case 'stress':
        return const Color(0xFFFFAA00);
      case 'colère':
      case 'colere':
        return const Color(0xFFFF4466);
      default:
        return const Color(0xFF9B8FDB);
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    final dt = DateTime.parse(date);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
