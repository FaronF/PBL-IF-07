import 'package:flutter/material.dart';

class KelolaPenilaianSiswa extends StatefulWidget {
  @override
  _KelolaPenilaianSiswaState createState() => _KelolaPenilaianSiswaState();
}

class _KelolaPenilaianSiswaState extends State<KelolaPenilaianSiswa> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Mengatur tinggi toolbar
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              // Header setengah lingkaran dengan teks "Kelola Penilaian"
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 240, 69), // Warna header
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Kelola Penilaian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Cards List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    buildTaskCard(
                      title: 'Bakteri',
                      subtitle: 'Bab Fotosintesis lorem ipsum\nXII MIPA 3\nPDF',
                      dueDate: '27 Agustus 2025 22.00',
                      dikumpul: '13/24',
                      selesai: '0/24',
                    ),
                    buildTaskCard(
                      title: 'Pembelahan Sel',
                      subtitle: 'Bab Fotosintesis lorem ipsum\nXII MIPA 3\nPDF',
                      dueDate: '27 Agustus 2025 22.00',
                      dikumpul: '19/22',
                      selesai: '10/22',
                    ),
                    buildTaskCard(
                      title: 'Bakteri',
                      subtitle: 'Bab Fotosintesis lorem ipsum\nXII MIPA 3\nPDF',
                      dueDate: '27 Agustus 2025 22.00',
                      dikumpul: '13/24',
                      selesai: '0/24',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Bottom Navigation Bar
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

  // Card widget
    Widget buildTaskCard({
    required String title,
    required String subtitle,
    required String dueDate,
    required String dikumpul,
    required String selesai,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Menambahkan Spacer agar title berada di kiri, dan status di kanan
              Spacer(),
              Row(
                children: [
                  buildStatusBox('Dikumpul', dikumpul),
                  SizedBox(width: 10), // Jarak antara kotak
                  buildStatusBox('Selesai', selesai),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            dueDate,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  // Kotak Status widget
  Widget buildStatusBox(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
