import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/screens/editProfilePage.dart';
import 'package:projet_integration/services/user_service.dart';

class MentheraDrawer extends StatefulWidget {
  const MentheraDrawer({super.key});

  @override
  State<MentheraDrawer> createState() => _MentheraDrawerState();
}

class _MentheraDrawerState extends State<MentheraDrawer> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  String avatarUrl = ""; // <-- ajouter ici

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _loading = true);
    final user = await UserService.getProfile();
    setState(() {
      _user = user;
      // Construire l'URL complète de l'avatar
      avatarUrl = _user != null && _user!['avatar'] != null && _user!['avatar'] != ""
          ? "http://172.16.27.16:5000${_user!['avatar']}"
          : "";
      print(avatarUrl);
      _loading = false;
    });
  }

  void _editProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: _user)),
    );
    if (updated == true) _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double headerMinHeight = media.size.height * 0.22; // ~22% de l’écran

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0221), Color(0xFF1A0B2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // HEADER FLEXIBLE
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B5FF8), Color(0xFF15114A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: headerMinHeight),
                  child: _loading
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Stack(
                      children: [
                        // Contenu profil
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white,
                                    backgroundImage: avatarUrl.isNotEmpty
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl.isEmpty
                                        ? Icon(
                                      Icons.person,
                                      size: 34,
                                      color: Colors.grey[500],
                                    )
                                        : null,
                                  ),
                                  if (_user != null && (_user?['isPremium'] == true))
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "PRO",
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _user != null && (_user!['name'] ?? '').toString().isNotEmpty
                                    ? _user!['name']
                                    : "Utilisateur",
                                style: GoogleFonts.orbitron(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user != null ? (_user!['email'] ?? "") : "",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Icône edit en haut à droite
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: "Mettre à jour le profil",
                            onPressed: _editProfile,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // CONTENU SCROLLABLE
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.star_rounded, color: Colors.amber),
                    title: const Text('Payment', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/payment');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insights_rounded, color: Colors.white),
                    title: const Text('Historique d\'émotions', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Filtrer par période', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/emotion-history');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sports_esports_rounded, color: Colors.white),
                    title: const Text('Challenge hebdomadaire', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Mini-jeux & quiz', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/weekly-challenge');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.insert_chart, color: Colors.white),
                    title: const Text('Résumé hebdomadaire', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/weekly-summary');
                    },
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
