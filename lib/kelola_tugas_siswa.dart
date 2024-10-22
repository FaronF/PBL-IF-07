import 'package:flutter/material.dart';

class KelolaTugasSiswa extends StatefulWidget {
  @override
  KelolaTugasSiswaState createState() => KelolaTugasSiswaState();
}

class KelolaTugasSiswaState extends State<KelolaTugasSiswa> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              // Header setengah lingkaran
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 240, 69), // Warna header
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
                        decoration: const BoxDecoration(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), // Memberi jarak setelah header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildContentCard('Biologi', 'Kelas 10', 'Genetika', 'Stupen S.Pd'),
                    SizedBox(height: 16),
                    _buildContentCard('Biologi', 'Kelas 10', 'Sel dan Molekuler', 'Stupen S.Pd'),
                  ],
                ),
              ),
            ],
          ),
          // Teks di tengah atas
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0), // Mengatur jarak dari atas
              child: Text(
                'Kelola Konten Pelajaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
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
        backgroundColor: const Color.fromARGB(255, 253, 240, 69), // Menyamakan dengan header
        selectedItemColor: Colors.white, // Warna teks/icon ketika item dipilih
        unselectedItemColor: Colors.black, // Warna teks/icon ketika item tidak dipilih
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed, // Ini penting agar background color terlihat
      ),
    );
  }

  Widget _buildContentCard(
      String subject, String grade, String topic, String teacher) {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(grade, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(topic, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(teacher, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Edit action
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Delete action
              },
            ),
          ],
        ),
      ),
    );
  }
}
