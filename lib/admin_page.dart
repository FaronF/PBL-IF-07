import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'kelola_materi_page.dart'; // Import halaman Materi
import 'kelola_akademik_page.dart'; // Import halaman Manage Tasks
import 'daftar_siswa.dart'; // Import halaman Student List
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout', style: GoogleFonts.poppins()),
          content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa logout
              },
              child: Text('Batal', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _logout(); // Panggil fungsi logout
              },
              child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    FirebaseAuth.instance.signOut(); // Lakukan proses sign out
    Navigator.pushReplacementNamed(
        context, '/login'); // Arahkan ke halaman login
  }

  static final List<Widget> _pages = <Widget>[
    const HomeContent(), // Halaman Home
    const KelolaAkademikPage(), // Halaman Manage Tasks
    const KelolaMateriPage(), // Halaman Materi
    const DaftarSiswaPage(),
    const LoginPage(), // Halaman Student List
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Mengatur tinggi toolbar
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 240, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(190),
                bottomRight: Radius.circular(190),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -30,
                  left: 30,
                  width: 200,
                  height: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo-ulilalbab.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 45,
                  right: 25,
                  child: IconButton(
                    onPressed: () {
                      _showLogoutConfirmation(context);
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Kelola User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chrome_reader_mode_rounded),
            label: 'Kelola Pengajar',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/adminpage');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/kelolapengguna');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/kelolapengajar');
              break;
          }
        },
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final List<bool> _isHovered = List.generate(5, (_) => false);
  final List<String> _images = [
    'assets/TPA_ua.png',
    'assets/Logo-TK.png',
    'assets/Logo-SDIT.jpg',
    'assets/Logo-SMPIT.png',
    'assets/Logo-SMAIT.png',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/ASET-PPDB.png'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'YAYASAN ULIL ALBAB BATAM',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Merupakan Lembaga Pendidikan Islam Rujukan di Provinsi Kepulauan Riau, alhamdulillah saat ini masih diberi amanah mengelola jenjang Pendidikan Tingkat TKIT, SDIT, SMPIT Dan SMAIT.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Jenjang Pendidikan",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: _images.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildCard(
                  index: index,
                  image: _images[index],
                  title: index == 0
                      ? 'TPA'
                      : index == 1
                          ? 'TKIT Anak'
                          : index == 2
                              ? 'SDIT'
                              : index == 3
                                  ? 'SMPIT'
                                  : 'SMAIT',
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required int index, required String image, required String title}) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered[index] = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered[index] = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered[index] ? -10 : 0, 0),
        child: Card(
          elevation: _isHovered[index] ? 10 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Bentuk persegi
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover, // Agar gambar memenuhi area
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
