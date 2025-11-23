import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/services/weekly_challenge_service.dart';

class WeeklyChallengeDetailPage extends StatefulWidget {
  final String challengeId;

  const WeeklyChallengeDetailPage({super.key, required this.challengeId});

  @override
  State<WeeklyChallengeDetailPage> createState() =>
      _WeeklyChallengeDetailPageState();
}

class _WeeklyChallengeDetailPageState
    extends State<WeeklyChallengeDetailPage> {
  bool _loading = true;
  String? _error;
  WeeklyChallengeModel? _challenge;
  List<int?> _answers = [];
  bool _submitting = false;
  int? _score;
  List<bool>? _results; // true si correct, false si incorrect

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
      final c = await WeeklyChallengeService.getChallenge(widget.challengeId);
      setState(() {
        _challenge = c;
        if (c.userDone && c.userAnswers != null) {
          _answers = List<int?>.from(c.userAnswers!);
          _results = List<bool>.generate(
            c.questions.length,
                (i) => (c.userAnswers![i] == c.questions[i].correctIndex),
          );
          _score = c.userScore;
        } else {
          _answers = List<int?>.filled(c.questions.length, null);
          _results = null;
          _score = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_challenge == null) return;
    if (_answers.any((a) => a == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réponds à toutes les questions avant de valider.'),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final data = await WeeklyChallengeService.submitScore(
        challengeId: _challenge!.id,
        answers: _answers.map((e) => e ?? -1).toList(),
      );

      final score = (data['score'] as num?)?.toInt();
      final fresh =
      await WeeklyChallengeService.getChallenge(_challenge!.id);

      setState(() {
        _score = score;
        _challenge = fresh;
        _results = List<bool>.generate(
          _answers.length,
              (i) =>
          (_answers[i] != null &&
              fresh.questions[i].correctIndex == _answers[i]),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Score enregistré: $_score')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _challenge;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
          const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // return updated
        ),
        title: Text(
          c?.title ?? 'Challenge',
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
            colors: [Color(0xFF0D0221), Color(0xFF2D1B4E)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: GoogleFonts.poppins(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_challenge == null) {
      return Center(
        child: Text(
          'Challenge introuvable.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    final c = _challenge!;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: c.questions.length,
      itemBuilder: (context, index) {
        final q = c.questions[index];
        final selected = _answers[index];
        final isAnswered = _results != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q${index + 1}. ${q.text}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(q.choices.length, (i) {
                final choice = q.choices[i];
                final isSelected = selected == i;

                Color? bgColor;
                Color borderColor = Colors.white.withOpacity(0.15);
                Color textColor = Colors.white;

                if (_results != null) {
                  print (_challenge!.questions[index].correctIndex);
                  final correctIndex = _challenge!.questions[index].correctIndex;
                  final selectedIndex = _answers[index];

                  if (i == correctIndex) {
                    // la bonne réponse → vert
                    bgColor = Colors.green.withOpacity(0.18);
                    borderColor = Colors.green;
                    textColor = Colors.green;
                  }

                  if (selectedIndex == i && i != correctIndex) {
                    print(correctIndex);
                    print(i);
                    // mauvaise réponse sélectionnée → rouge
                    bgColor = Colors.red.withOpacity(0.18);
                    borderColor = Colors.red;
                    textColor = Colors.red;
                  }
                } else if (isSelected) {
                  // avant validation → bleu
                  bgColor = const Color(0xFF00D4FF).withOpacity(0.19);
                  borderColor = const Color(0xFF00D4FF);
                }



                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: isAnswered
                        ? null
                        : () {
                      setState(() {
                        _answers[index] = i;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: bgColor ?? Colors.white.withOpacity(0.03),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? textColor
                                : Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              choice,
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    if (_challenge == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0221).withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_score != null)
              Expanded(
                child: Text(
                  'Score: $_score',
                  style: GoogleFonts.spaceGrotesk(
                    color: const Color(0xFF00FF88),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              const Spacer(),
            ElevatedButton(
              onPressed: _results != null
                  ? () {
                Navigator.pop(context, true); // return updated
              }
                  : (_submitting ? null : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _results != null
                  ? Text(
                'Quitter',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              )
                  : (_submitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
                  : Text(
                'Valider',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
