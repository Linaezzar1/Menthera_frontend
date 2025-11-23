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
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0221), Color(0xFF1A0B2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B5FF8), Color(0xFF15114A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Stack(
                      children: [
                        // Profile content
                        Center(
                          child: SizedBox(
                            height: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 34,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          _user != null &&
                                              _user!['avatar'] != null &&
                                              _user!['avatar'] != ""
                                          ? NetworkImage(_user!['avatar'])
                                          : null,
                                      child:
                                          _user == null ||
                                              _user!['avatar'] == null ||
                                              _user!['avatar'] == ""
                                          ? Icon(
                                              Icons.person,
                                              size: 34,
                                              color: Colors.grey[500],
                                            )
                                          : null,
                                    ),
                                    if (_user != null &&
                                        (_user?['isPremium'] == true))
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            boxShadow: [
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
                                  _user != null &&
                                          (_user!['name'] ?? '')
                                              .toString()
                                              .isNotEmpty
                                      ? _user!['name']
                                      : "Utilisateur",
                                  style: GoogleFonts.orbitron(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _user != null ? (_user!['email'] ?? "") : "",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Stylo (edit) en haut à droite
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 25,
                            ),
                            tooltip: "Mettre à jour le profil",
                            onPressed: _editProfile,
                          ),
                        ),
                      ],
                    ),
            ),

            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text(
                'Payment',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/payment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights_rounded, color: Colors.white),
              title: const Text(
                'Historique d\'émotions',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Filtrer par période',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/emotion-history');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sports_esports_rounded,
                color: Colors.white,
              ),
              title: const Text(
                'Challenge hebdomadaire',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Mini-jeux & quiz',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/weekly-challenge');
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
