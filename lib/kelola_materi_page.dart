import 'package:flutter/material.dart';

class KelolaMateriPage extends StatefulWidget {
  const KelolaMateriPage({super.key});

  @override
  State<KelolaMateriPage> createState() => _KelolaMateriPageState();
}

class _KelolaMateriPageState extends State<KelolaMateriPage> {
  int _selectedIndex = 2; // Index untuk BottomNavigationBar (default ke 'Materi')

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan index
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/teacherpage');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/kelolatugas');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/kelolamateri');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/daftarsiswa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'), // Menambahkan judul untuk AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Mengubah untuk merapat ke atas
            children: [
              const SizedBox(height: 20), // Padding atas
              _buildMateriBox(context, "Matematika"),
              const SizedBox(height: 20), // Jarak antar box
              _buildMateriBox(context, "Biologi"),
              const SizedBox(height: 20), // Jarak antar box
              _buildMateriBox(context, "PKN"),
              const SizedBox(height: 20), // Jarak antar box
              _buildMateriBox(context, "Fisika"),
            ],
          ),
        ),
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
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildMateriBox(BuildContext context, String subject) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KelasPage(subject: subject),
          ),
        );
      },
      child: Container(
        width: 300, // Lebar box
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            subject,
            style: const TextStyle(
              color: Colors.white, // Warna teks
              fontSize: 24, // Ukuran teks
              fontWeight: FontWeight.bold, // Ketebalan teks
            ),
          ),
        ),
      ),
    );
  }
}

class KelasPage extends StatelessWidget {
  final String subject;

  const KelasPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelas $subject'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Mengubah agar rapat ke atas
            children: List.generate(3, (index) {
              int kelasNumber = index + 10; // Kelas 10, 11, 12
              return _buildKelasBox(kelasNumber);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildKelasBox(int kelasNumber) {
    return Container(
      width: 300, // Lebar box
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'Kelas $kelasNumber',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
