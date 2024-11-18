import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaftarSiswaPage extends StatefulWidget {
  @override
  _DaftarSiswaPageState createState() => _DaftarSiswaPageState();
}

class _DaftarSiswaPageState extends State<DaftarSiswaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';
  List<Map<String, dynamic>> siswaList = [];
  List<Map<String, dynamic>> filteredSiswaList = [];
  int _selectedIndex = 3; // Indeks awal sesuai dengan "Student List"

  @override
  void initState() {
    super.initState();
    fetchSiswaData();
  }

  // Fungsi untuk mengambil data siswa dari Firestore
  void fetchSiswaData() async {
    QuerySnapshot snapshot = await _firestore.collection('Students').get();
    setState(() {
      siswaList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      filteredSiswaList = siswaList; // Inisialisasi dengan semua data
    });
  }

  // Fungsi untuk mencari siswa berdasarkan nama, id, dan kelas
  void searchSiswa(String query) {
    final filtered = siswaList.where((siswa) {
      return siswa['nama'].toLowerCase().contains(query.toLowerCase()) ||
          siswa['nisn'].toLowerCase().contains(query.toLowerCase()) ||
          siswa['kelas'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredSiswaList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Siswa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      searchSiswa(
                          searchQuery); // Panggil fungsi pencarian saat teks berubah
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari Siswa',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchSiswa(
                        searchQuery); // Panggil fungsi pencarian saat tombol ditekan
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSiswaList.length,
              itemBuilder: (context, index) {
                final siswa = filteredSiswaList[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                            siswa['foto'] ?? 'assets/default_avatar.png'),
                      ),
                      title: Text(siswa['nama'] ?? 'Nama tidak tersedia'),
                      subtitle: Text(siswa['nisn'] ?? 'NISN tidak tersedia'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(siswa['gender'] ?? 'Gender tidak tersedia'),
                          Text(siswa['kelas'] ?? 'Kelas tidak tersedia'),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
}
