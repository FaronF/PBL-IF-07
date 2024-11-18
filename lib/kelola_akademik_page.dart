import 'package:flutter/material.dart';

class KelolaAkademikPage extends StatefulWidget {
  @override
  _KelolaAkademikPageState createState() => _KelolaAkademikPageState();
}

class _KelolaAkademikPageState extends State<KelolaAkademikPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDashboardBox(
                    context,
                    'Kelola Tugas',
                    '/kelolatugassiswa',
                    height: 60,
                    width: 140,
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Quiz',
                    '/kelolaquizsiswa',
                    height: 60,
                    width: 140,
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Konten Pelajaran',
                    '/kelola_konten_pelajaran',
                    height: 60,
                    width: 140,
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Penilaian',
                    '/kelolapenilaiansiswa',
                    height: 60,
                    width: 140,
                  ),
                ],
              ),
            ),
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
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/teacherpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/kelolatugas');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/kelolamateri');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/daftarsiswa');
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

  Widget _buildDashboardBox(
      BuildContext context, String title, String routeName,
      {double height = 150, double width = double.infinity}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 8.0,
                ),
              ],
              color: const Color.fromARGB(255, 131, 142, 240),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 12, 12, 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
