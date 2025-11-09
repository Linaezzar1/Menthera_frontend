import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;

class VoiceToAiScreen extends StatefulWidget {
  const VoiceToAiScreen({super.key});

  @override
  _VoiceToAiScreenState createState() => _VoiceToAiScreenState();
}

class _VoiceToAiScreenState extends State<VoiceToAiScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isHovering = false; // État hover
  double _recordingDuration = 0.0;
  Timer? _recordingTimer;
  AnimationController? _pulseController;
  AnimationController? _breatheController;
  Animation<double>? _breatheAnimation;

  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  final AudioRecorder _recorder = AudioRecorder();
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController!, curve: Curves.easeInOut),
    );

    _messages.add(ChatMessage(
      text: 'Bonjour ! Je suis Menthera, votre psychologue virtuel. Comment vous sentez-vous aujourd\'hui ?',
      isUser: false,
      emotion: 'neutral',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController?.dispose();
    _breatheController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    if (_isProcessing) return;

    setState(() => _isRecording = !_isRecording);

    if (_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
      _processAudio();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (await hasPermission) {
      _recordingDuration = 0.0;
      _breatheController?.repeat(reverse: true);

      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _recordingDuration += 0.1;
        });
      });

      final path = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc), // ✅ Correct constant name
        path: path,
      );
      _audioPath = path;
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _breatheController?.stop();

    _audioPath = await _recorder.stop();
    print('Audio saved at: $_audioPath');
  }


  Future<void> _processAudio() async {
    setState(() {
      _isProcessing = true;

      _messages.add(ChatMessage(
        text: 'Message vocal (${_recordingDuration.toStringAsFixed(1)}s)',
        isUser: true,
        emotion: '',
        timestamp: DateTime.now(),
        duration: _recordingDuration,
        audioPath: _audioPath, // attach recorded file
      ));
    });
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final responses = [
      {
        'emotion': 'anxiété',
        'text': 'Je perçois de l\'anxiété dans votre voix. Prenez une profonde respiration. Voulez-vous essayer un exercice de relaxation ?',
      },
      {
        'emotion': 'tristesse',
        'text': 'Je sens de la tristesse. Il est normal de ressentir cela. Parlons-en ensemble, je suis là pour vous écouter.',
      },
      {
        'emotion': 'joie',
        'text': 'Votre voix rayonne de positivité ! C\'est merveilleux. Qu\'est-ce qui vous rend heureux aujourd\'hui ?',
      },
      {
        'emotion': 'stress',
        'text': 'Je détecte du stress. Essayons ensemble d\'identifier les sources et trouver des solutions pour vous apaiser.',
      },
    ];

    final response = responses[math.Random().nextInt(responses.length)];

    setState(() {
      _isProcessing = false;
      _messages.add(ChatMessage(
        text: response['text']!,
        isUser: false,
        emotion: response['emotion']!,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF0D0221),
              const Color(0xFF1A0B2E),
              const Color(0xFF2D1B4E),
              const Color(0xFF4A2C6D),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildStarryBackground(),
            _buildFloatingOrbs(),
            SafeArea(
              child: Column(
                children: [
                  _buildModernAppBar(context),
                  Expanded(child: _buildChatArea()),
                  _buildInputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarryBackground() {
    return Stack(
      children: List.generate(40, (index) {
        final random = math.Random(index);
        return Positioned(
          left: random.nextDouble() * 400,
          top: random.nextDouble() * 900,
          child: Container(
            width: random.nextDouble() * 2.5 + 1,
            height: random.nextDouble() * 2.5 + 1,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(random.nextDouble() * 0.7 + 0.3),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)],
            ),
          ).animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: Duration(milliseconds: 1000 + random.nextInt(2000)))
              .then()
              .fadeIn(duration: Duration(milliseconds: 1000 + random.nextInt(2000))),
        );
      }),
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        Positioned(
          top: 120,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFFFF6EC7).withOpacity(0.35), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(duration: 5000.ms, begin: 0, end: 40, curve: Curves.easeInOut),
        ),
        Positioned(
          bottom: 200,
          left: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF00D4FF).withOpacity(0.3), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(duration: 6000.ms, begin: 0, end: 50, curve: Curves.easeInOut),
        ),
      ],
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NeonButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pushReplacementNamed(context, '/welcome')),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FF88),
                  boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.8), blurRadius: 8, spreadRadius: 2)],
                ),
              ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 1000.ms).then().fadeIn(duration: 1000.ms),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF6EC7), Color(0xFF00D4FF)]).createShader(bounds),
                child: Text('Menthera AI', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
              ),
            ],
          ),
          _NeonButton(
            icon: Icons.history_rounded,
            onTap: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildChatArea() {
    final processingExtra = _isProcessing ? 1 : 0;
    final total = _messages.length + processingExtra;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: total,
      itemBuilder: (context, index) {
        if (_isProcessing && index == _messages.length) {
          return _buildTypingIndicator();
        }
        if (index < 0 || index >= _messages.length) {
          return const SizedBox.shrink();
        }
        final message = _messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAIAvatar(),
          if (!message.isUser) const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    gradient: LinearGradient(
                      colors: message.isUser
                          ? [
                        const Color(0xFF6B5FF8).withOpacity(0.9),
                        const Color(0xFF00D4FF).withOpacity(0.8)
                      ]
                          : [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.08)
                      ],
                    ),
                    border: Border.all(
                      color: message.isUser
                          ? const Color(0xFF6B5FF8).withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: message.isUser
                            ? const Color(0xFF6B5FF8).withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!message.isUser && message.emotion.isNotEmpty)
                            _buildEmotionBadge(message.emotion),

                          // 🎧 Check if this message contains an audio file
                          if (message.audioPath != null)
                            _AudioPlayerWidget(
                              audioPath: message.audioPath!,
                              duration: message.duration ?? 0,
                            )
                          else if (message.duration != null)
                            _buildVoiceWave(message.duration!)
                          else
                            Text(
                              message.text,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.95),
                                height: 1.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 12),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }


  Widget _buildAIAvatar() {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFFFF6EC7), Color(0xFF6B5FF8), Color(0xFF00D4FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFF6B5FF8).withOpacity(0.5), blurRadius: 12)],
      ),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFF0D0221), shape: BoxShape.circle),
        padding: const EdgeInsets.all(6),
        child: Image.asset('assets/images/robot1.png', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF6B5FF8), Color(0xFF00D4FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFF6B5FF8).withOpacity(0.4), blurRadius: 12)],
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _buildEmotionBadge(String emotion) {
    final emotionColors = {
      'anxiété': [const Color(0xFFFFAA00), const Color(0xFFFF6600)],
      'tristesse': [const Color(0xFF6B8EFF), const Color(0xFF4A6FE8)],
      'joie': [const Color(0xFF00FF88), const Color(0xFF00CC6A)],
      'stress': [const Color(0xFFFF4466), const Color(0xFFFF2244)],
      'neutral': [const Color(0xFF9B8FDB), const Color(0xFF7B68C8)],
    };
    final colors = emotionColors[emotion] ?? emotionColors['neutral']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.4), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emotion == 'joie'
                ? Icons.sentiment_very_satisfied_rounded
                : emotion == 'tristesse'
                ? Icons.sentiment_dissatisfied_rounded
                : (emotion == 'stress' || emotion == 'anxiété')
                ? Icons.mood_bad_rounded
                : Icons.sentiment_neutral_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(emotion.toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildVoiceWave(double duration) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        ...List.generate(
          12,
              (index) => Container(
            width: 3,
            height: 12 + (index % 4) * 6,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Text('${duration.toStringAsFixed(1)}s', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAIAvatar(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.08)]),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                    (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(color: Color(0xFF00D4FF), shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat())
                    .fadeOut(duration: Duration(milliseconds: 600 + index * 200))
                    .then()
                    .fadeIn(duration: Duration(milliseconds: 600 + index * 200)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
      ),
      child: Column(
        children: [
          if (_isRecording) _buildRecordingIndicator(),
          if (_isRecording) const SizedBox(height: 12),
          _buildMicButton(),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [const Color(0xFFFF0055).withOpacity(0.2), const Color(0xFFFF0055).withOpacity(0.1)]),
        border: Border.all(color: const Color(0xFFFF0055).withOpacity(0.5), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF0055), boxShadow: [BoxShadow(color: Color(0xFFFF0055), blurRadius: 10, spreadRadius: 2)]),
            ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 700.ms).then().fadeIn(duration: 700.ms),
            const SizedBox(width: 12),
            Text('Recording...', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
          Text('${_recordingDuration.toStringAsFixed(1)}s', style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFFFF6EC7))),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _isProcessing ? null : _toggleRecording,
        child: AnimatedScale(
          scale: _isHovering && !_isRecording ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Glow extérieur au hover
              if (_isHovering && !_isRecording)
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF6EC7).withOpacity(0.3),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 800.ms)
                    .then()
                    .fadeOut(duration: 800.ms),

              // Ondes pendant l'enregistrement
              if (_isRecording) ...[
                _buildPulseWave(scale: 1.3, delay: 0, opacity: 0.4),
                _buildPulseWave(scale: 1.5, delay: 600, opacity: 0.25),
                _buildPulseWave(scale: 1.7, delay: 1200, opacity: 0.15),
              ],

              // Bouton principal
              AnimatedBuilder(
                animation: _breatheAnimation ?? const AlwaysStoppedAnimation(1.0),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _breatheAnimation!.value : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [const Color(0xFFFF0055), const Color(0xFFFF3366)]
                              : _isHovering
                              ? [const Color(0xFF00D4FF), const Color(0xFFFF6EC7), const Color(0xFF6B5FF8)]
                              : [const Color(0xFFFF6EC7), const Color(0xFF6B5FF8), const Color(0xFF00D4FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                ? const Color(0xFFFF0055)
                                : _isHovering
                                ? const Color(0xFF00D4FF)
                                : const Color(0xFF6B5FF8))
                                .withOpacity(_isRecording ? 0.6 : _isHovering ? 0.7 : 0.4),
                            blurRadius: _isRecording ? 25 : _isHovering ? 30 : 20,
                            spreadRadius: _isRecording ? 3 : _isHovering ? 4 : 2,
                          ),
                          if (_isRecording)
                            BoxShadow(
                                color: const Color(0xFFFF0055).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10
                            ),
                          if (_isHovering && !_isRecording)
                            BoxShadow(
                              color: const Color(0xFFFF6EC7).withOpacity(0.5),
                              blurRadius: 35,
                              spreadRadius: 8,
                            ),
                        ],
                      ),
                      child: AnimatedRotation(
                        turns: _isHovering && !_isRecording ? 0.05 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                            _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 34
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseWave({required double scale, required int delay, required double opacity}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('$scale-$delay-${DateTime.now().millisecondsSinceEpoch % 1000}'),
      tween: Tween(begin: 1.0, end: scale),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOut,
      onEnd: () {
        if (_isRecording && mounted) setState(() {});
      },
      builder: (context, value, child) {
        final currentOpacity = opacity * (1.0 - ((value - 1.0) / (scale - 1.0)));
        return Transform.scale(
          scale: value,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF0055).withOpacity(currentOpacity.clamp(0.0, opacity)), width: 2.5),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: Duration(milliseconds: delay), curve: Curves.easeOut);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String emotion;
  final DateTime timestamp;
  final double? duration;
  final String? audioPath;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.emotion,
    required this.timestamp,
    this.duration,
    this.audioPath,
  });
}
class _AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final double duration;
  const _AudioPlayerWidget({
    required this.audioPath,
    required this.duration,
  });
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow, color: Colors.white),
          onPressed: () async {
            await _player.play(DeviceFileSource(widget.audioPath));
          },
        ),
        Text("${widget.duration.toStringAsFixed(1)} sec",
            style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}




class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  double _seconds = 0.0;

  /// Callback to notify the UI about duration changes
  Function(double)? onDurationChanged;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<String?> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      // Reset duration
      _seconds = 0.0;

      // Start timer for 0.1s precision (100 ms)
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _seconds += 0.1;
        onDurationChanged?.call(double.parse(_seconds.toStringAsFixed(1)));
      });

      return filePath;
    }
    return null;
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    _timer = null;
    final path = await _recorder.stop();
    return path;
  }

  double get duration => _seconds;
}



class _NeonButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NeonButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]),
        border: Border.all(color: const Color(0xFF6B5FF8).withOpacity(0.4), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
