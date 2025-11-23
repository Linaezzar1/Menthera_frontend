import 'package:flutter/material.dart';
import 'package:projet_integration/screens/editProfilePage.dart';
import 'package:projet_integration/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  void _navigateToEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditProfilePage(user: _user),
      ),
    );
    if (updated == true) _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mon profil")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final user = _user ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        leading: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditProfile,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage:
                user['avatar'] != null && user['avatar'] != "" ? NetworkImage(user['avatar']) : null,
                child: user['avatar'] == null || user['avatar'] == ""
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user['name'] ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user['email'] ?? "", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 36),
            Text("Premium: ${user['isPremium'] == true ? "Actif" : "Non"}"),
            Text("Dernière connexion: ${user['lastLogin'] ?? "Jamais"}"),
            Text("Inscrit le: ${user['createdAt'] ?? "-"}"),
          ],
        ),
      ),
    );
  }
}
