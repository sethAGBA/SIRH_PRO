import 'package:flutter/material.dart';
import 'package:afroforma/models/user.dart';
import 'package:afroforma/services/auth_service.dart';
import 'package:afroforma/services/notification_service.dart';
import 'package:afroforma/widgets/menu_item_widget.dart';
import '../models/menu_item.dart';
import 'coming_soon_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'no_access_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  int selectedIndex = 0;
  String? _selectedTitle;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<MenuItem> _fullMenuItems = [
    MenuItem(
      icon: Icons.dashboard_rounded,
      title: 'Tableau de bord',
      gradient: const LinearGradient(colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)]),
    ),
    MenuItem(
      icon: Icons.people_alt_rounded,
      title: 'Patients',
      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
    ),
    MenuItem(
      icon: Icons.local_hospital_rounded,
      title: 'Personnel medical',
      gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
    ),
    MenuItem(
      icon: Icons.bed_rounded,
      title: 'Chambres & lits',
      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
    ),
    MenuItem(
      icon: Icons.event_available_rounded,
      title: 'Consultations',
      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
    ),
    MenuItem(
      icon: Icons.science_rounded,
      title: 'Examens & labo',
      gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
    ),
    MenuItem(
      icon: Icons.medication_rounded,
      title: 'Pharmacie & stocks',
      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    ),
    MenuItem(
      icon: Icons.warning_amber_rounded,
      title: 'Urgences',
      gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
    ),
    MenuItem(
      icon: Icons.local_hospital_outlined,
      title: 'Interventions',
      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
    ),
    MenuItem(
      icon: Icons.receipt_long_rounded,
      title: 'Facturation',
      gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
    ),
    MenuItem(
      icon: Icons.account_balance_rounded,
      title: 'Comptabilite',
      gradient: const LinearGradient(colors: [Color(0xFF64748B), Color(0xFF475569)]),
    ),
    MenuItem(
      icon: Icons.query_stats_rounded,
      title: 'Reporting',
      gradient: const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0F766E)]),
    ),
    MenuItem(
      icon: Icons.settings_rounded,
      title: 'Parametres',
      gradient: const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]),
    ),
  ];

  late List<MenuItem> _visibleMenuItems;

  @override
  void initState() {
    super.initState();
    _updateVisibleMenuItems();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    _notificationService.addListener(_onNotificationsChanged);
  }

  void _updateVisibleMenuItems() {
    final user = AuthService.currentUser;
    final permissions = user?.permissions.map((p) => p.module).toSet() ?? {};

    if (user?.role == UserRole.admin) {
      _visibleMenuItems = List.from(_fullMenuItems);
    } else {
      _visibleMenuItems = _fullMenuItems.where((item) => permissions.contains(item.title)).toList();
    }

    final hasAccessibleModules = _visibleMenuItems.isNotEmpty;

    _visibleMenuItems.add(
      MenuItem(
        icon: Icons.logout_rounded,
        title: 'Deconnexion',
        gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
      ),
    );

    if (!hasAccessibleModules && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NoAccessScreen()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  void _onNotificationsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _showQuickAdmissionNotice() {
    _notificationService.showNotification(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Nouvelle admission',
        details: 'Ouverture du formulaire de pre-admission.',
        backgroundColor: const Color(0xFF0EA5A4),
        progressColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickAdmissionNotice,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Nouvelle admission'),
        backgroundColor: const Color(0xFF0EA5A4),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainArea()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5A4).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Res Hopital',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Gestion clinique & administrative',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: _visibleMenuItems.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _fadeAnimation.value) * 40 * (index + 1)),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MenuItemWidget(
                              item: _visibleMenuItems[index],
                              isSelected: (selectedIndex == index && _selectedTitle == null) ||
                                  (_selectedTitle == _visibleMenuItems[index].title),
                              selectedTitle: _selectedTitle,
                              onMenuItemSelected: (item) {
                                if (item.title == 'Deconnexion') {
                                  _confirmLogout();
                                  return;
                                }
                                setState(() {
                                  _selectedTitle = item.title;
                                  final topIndex = _visibleMenuItems.indexWhere((m) => m.title == item.title);
                                  if (topIndex != -1) selectedIndex = topIndex;
                                });
                                _animationController.reset();
                                _animationController.forward();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildMainArea() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: _buildContent(),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _visibleMenuItems[selectedIndex].title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildSearchBar(),
          const SizedBox(width: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher patient, personnel, chambre...',
          hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final hasNotifications = _notificationService.notifications.isNotEmpty;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Occupation 78%',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
              ),
              if (hasNotifications)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final urgentCount = _notificationService.notifications.length;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF22C55E), size: 10),
              const SizedBox(width: 8),
              Text(
                'Services stables · Lits libres: 23 · Temps attente moyen: 28 min',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: urgentCount > 0 ? const Color(0xFFEF4444) : Colors.white24, size: 18),
              const SizedBox(width: 6),
              Text(
                urgentCount > 0 ? '$urgentCount alertes urgentes' : 'Aucune alerte urgente',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF0EA5A4),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AuthService.currentUser?.name ?? 'Utilisateur',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  AuthService.currentUser?.email ?? 'email@example.com',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Confirmation de deconnexion', style: TextStyle(color: Colors.white)),
          content: const Text('Voulez-vous vraiment vous deconnecter ?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Deconnexion', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                AuthService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    if (selectedIndex >= _visibleMenuItems.length) {
      selectedIndex = 0;
    }

    final titleToUse = _selectedTitle ?? _visibleMenuItems[selectedIndex].title;
    final selectedMenuItem = _visibleMenuItems.firstWhere(
      (item) => item.title == titleToUse,
      orElse: () => _visibleMenuItems[selectedIndex],
    );

    switch (titleToUse) {
      case 'Tableau de bord':
        return DashboardScreen(fadeAnimation: _fadeAnimation);
      case 'Deconnexion':
        return const SizedBox.shrink();
      default:
        return ComingSoonScreen(screenName: titleToUse, gradient: selectedMenuItem.gradient);
    }
  }
}
