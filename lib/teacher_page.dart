import 'package:flutter/material.dart';
import 'kelola_materi_page.dart'; // Import halaman Materi
import 'kelola_akademik_page.dart'; // Import halaman Manage Tasks
import 'daftar_siswa.dart'; // Import halaman Student List
import 'profile_guru.dart'; // Import halaman Profile
import 'login_page.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> _pages = <Widget>[
    HomeContent(), // Halaman Home
    KelolaAkademikPage(), // Halaman Manage Tasks
    KelolaMateriPage(), // Halaman Materi
    DaftarSiswaPage(),
    LoginPage(), // Halaman Student List
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
          // Header setengah lingkaran
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 240, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -30,
                  left: 15,
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
                  top: 40,
                  right: 25,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileGuruPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Konten Utama
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
          icon: Icon(Icons.list_alt_rounded),
          label: 'Manage Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chrome_reader_mode_rounded),
          label: 'Materi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Student List',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/teacherpage');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/kelolatugas');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/kelolamateri');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/daftarsiswa');
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
  // Daftar hover untuk setiap kartu
  final List<bool> _isHovered = List.generate(5, (_) => false);

  // Daftar gambar untuk setiap kartu
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
            const Center(
              child: Text(
                'YAYASAN ULIL ALBAB BATAM',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Merupakan Lembaga Pendidikan Islam Rujukan di Provinsi Kepulauan Riau...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Jenjang Pendidikan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(image),
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
