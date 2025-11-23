// lib/screens/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_integration/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  bool _markingAll = false;
  String? _error;
  List<NotificationItem> _items = [];

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
      final items = await NotificationService.list();
      setState(() {
        _items = items;
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

  Future<void> _onMarkAllRead() async {
    setState(() {
      _markingAll = true;
    });
    try {
      await NotificationService.markAllRead();
      setState(() {
        _items = _items.map((n) => NotificationItem(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          read: true,
          createdAt: n.createdAt,
        )).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _markingAll = false;
        });
      }
    }
  }

  Future<void> _onTapNotification(NotificationItem n) async {
    if (!n.read) {
      try {
        await NotificationService.markRead(n.id);
        setState(() {
          final idx = _items.indexWhere((e) => e.id == n.id);
          if (idx != -1) {
            _items[idx] = NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              read: true,
              createdAt: n.createdAt,
            );
          }
        });
      } catch (_) {}
    }
    // TODO: navigation selon n.type / n.payload si besoin
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
          'Notifications',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_loading && _items.isNotEmpty)
            TextButton(
              onPressed: _markingAll ? null : _onMarkAllRead,
              child: _markingAll
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Tout lire',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
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
    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Aucune notification pour le moment.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF00D4FF),
      backgroundColor: const Color(0xFF0D0221),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final n = _items[index];
          return GestureDetector(
            onTap: () => _onTapNotification(n),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(n.read ? 0.04 : 0.10),
                border: Border.all(
                  color: n.read
                      ? Colors.white.withOpacity(0.12)
                      : const Color(0xFF00D4FF).withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    n.read
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_active_rounded,
                    color: n.read
                        ? Colors.white70
                        : const Color(0xFF00D4FF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (n.body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(n.createdAt),
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!n.read)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 6, top: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3366),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'À l’instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
