import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'delete_account_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifOn = true;
  String? _nama;
  String? _nik;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    String? name;
    String? nik;
    if (user != null) {
      // Ambil nama dan NIK dari users
      final usersQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();
      if (usersQuery.docs.isNotEmpty) {
        final data = usersQuery.docs.first.data();
        name = data['name'] ?? '-';
        nik = data['nik'] ?? '-';
      } else {
        name = '-';
        nik = '-';
      }
    }
    setState(() {
      _nama = name ?? '-';
      _nik = nik ?? '-';
      _loading = false;
    });
  }

  void _onNavBarTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/berita');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chatbot');
        break;
      case 3:
        // Stay on current page
        break;
    }
  }

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya'),
              ),
            ],
          ),
    );

    if (result == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/splash', (route) => false);
      }
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF07477C)),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF07477C)),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: _notifOn,
                activeColor: const Color(0xFF07477C),
                onChanged: (val) {
                  setState(() {
                    _notifOn = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF07477C);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Header Profile Card
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 40),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _loading
                          ? const CircularProgressIndicator()
                          : Text(
                            _nama ?? '-',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      const SizedBox(height: 4),
                      _loading
                          ? const SizedBox(height: 18)
                          : Text(
                            _nik ?? '-',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Menu Options
            Expanded(
              child: ListView(
                children: [
                  _buildMenuButton(
                    icon: Icons.password,
                    title: "Ubah Kata Sandi",
                    onTap: () {
                      Navigator.pushNamed(context, '/ubah-kata-sandi');
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.security,
                    title: "Keamanan dan Privasi",
                    onTap: () {
                      Navigator.pushNamed(context, '/keamanan-privasi');
                    },
                  ),
                  _buildSwitchTile(Icons.notifications, "Notifikasi"),
                  _buildMenuButton(
                    icon: Icons.menu_book,
                    title: "Panduan",
                    onTap: () {
                      Navigator.pushNamed(context, '/panduan-aplikasi');
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.settings,
                    title: "Pengaturan",
                    onTap: () {
                      Navigator.pushNamed(context, '/pengaturan');
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.logout,
                    title: "Keluar",
                    onTap: _logout,
                  ),
                  _buildMenuButton(
                    icon: Icons.delete_forever,
                    title: "Hapus Akun",
                    onTap: () => showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Profile tab is active
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Berita"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
