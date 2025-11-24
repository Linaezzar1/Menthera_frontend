import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/user_service.dart';
import 'EditPasswordPage.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;
  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  String? avatar;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?['name'] ?? '');
    avatar = widget.user?['avatar'];
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    String? avatarPath = avatar;

    // Vérifier fichier local uniquement si ce n'est PAS une URL
    if (avatarPath != null && avatarPath.isNotEmpty && !_isHttpUrl(avatarPath)) {
      if (!File(avatarPath).existsSync()) {
        setState(() {
          _loading = false;
          _error = "Image introuvable sur l’appareil";
        });
        return;
      }
    }

    final updated = await UserService.updateProfile(
      name: _nameCtrl.text,
      avatar: (!_isHttpUrl(avatarPath ?? "")) ? avatarPath : null,
    );

    setState(() => _loading = false);

    if (updated != null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = "Erreur lors de la mise à jour");
    }
  }

  Future<void> _changeAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? picked =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);

      if (picked != null) {
        setState(() {
          avatar = picked.path;
        });
      }
    } catch (e) {
      setState(() => _error = "Erreur image picker : $e");
    }
  }

  bool _isHttpUrl(String s) {
    return s.startsWith('http://') || s.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Modifier le profil",
            style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildFloatingOrbs(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAvatarBox(context),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _nameCtrl,
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: "Nom",
                          labelStyle: GoogleFonts.poppins(color: Colors.white70),
                          fillColor: Colors.white.withOpacity(0.09),
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (val) =>
                        val == null || val.isEmpty ? "Veuillez entrer un nom" : null,
                      )
                          .animate()
                          .slideY(begin: 0.21, end: 0)
                          .fadeIn(duration: 600.ms),

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(_error!,
                              style: GoogleFonts.poppins(
                                  color: Colors.redAccent, fontSize: 14)),
                        ),

                      const SizedBox(height: 26),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _loading
                            ? const CircularProgressIndicator(color: Color(0xFF6B5FF8))
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B5FF8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22)),
                            ),
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: Text("Enregistrer",
                                style: GoogleFonts.orbitron(
                                    fontSize: 16, color: Colors.white)),
                            onPressed: _onSave,
                          )
                              .animate()
                              .fadeIn(duration: 700.ms)
                              .slideY(begin: 0.18, end: 0),
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_outline, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6EC7),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                          ),
                          label: Text("Changer mon mot de passe",
                              style: GoogleFonts.orbitron(
                                  fontSize: 15, color: Colors.white)),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditPasswordPage())),
                        )
                            .animate()
                            .fadeIn(duration: 700.ms)
                            .slideY(begin: 0.17, end: 0),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBox(BuildContext context) {
    Widget imageWidget;

    if (avatar != null && avatar!.isNotEmpty) {
      if (_isHttpUrl(avatar!)) {
        imageWidget = CircleAvatar(
          radius: 57,
          backgroundImage: NetworkImage(avatar!),
        );
      } else {
        imageWidget = CircleAvatar(
          radius: 57,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.file(
              File(avatar!),
              width: 114,
              height: 114,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } else {
      imageWidget = const CircleAvatar(
        radius: 57,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 52, color: Color(0xFF6B5FF8)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6EC7),
            Color(0xFF6B5FF8),
            Color(0xFF00D4FF)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          imageWidget,
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF6B5FF8), size: 32),
            onPressed: _changeAvatar,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1A0B2E),
            Color(0xFF3D2C5C),
            Color(0xFF5B4FB3),
            Color(0xFF7B68C8)
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        Positioned(
          top: 67,
          right: -33,
          child: Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6EC7).withOpacity(0.29),
                  Colors.transparent
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(duration: 4000.ms, begin: 0, end: 28),
        ),
        Positioned(
          bottom: 50,
          left: -44,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B5FF8).withOpacity(0.17),
                  Colors.transparent
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(duration: 3200.ms, begin: 0, end: 17),
        ),
      ],
    );
  }
}
