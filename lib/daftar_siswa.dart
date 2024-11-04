import 'package:flutter/material.dart';

class DaftarSiswaPage extends StatelessWidget {
  final List<Map<String, String>> siswaList = [
    {
      "nama": "Jhon tor Bin Atang",
      "id": "2171145875436",
      "gender": "Laki-laki",
      "kelas": "Kelas 10",
      "foto": "assets/avatar1.png",
    },
    {
      "nama": "Jerome Jahit",
      "id": "2171145875436",
      "gender": "Perempuan",
      "kelas": "Kelas 11",
      "foto": "assets/avatar2.png",
    },
    {
      "nama": "Demi Kian",
      "id": "2171145875436",
      "gender": "Perempuan",
      "kelas": "Kelas 12",
      "foto": "assets/avatar3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hapus atau komentari bagian ini untuk menghilangkan tulisan "Daftar Siswa"
          /*
          Container(
            color: Colors.yellow,
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Daftar Siswa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          */
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Spacer(),
                SizedBox(
                  width: 200, // Perkecil lebar TextField
                  child: TextField(
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
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: siswaList.length,
              itemBuilder: (context, index) {
                final siswa = siswaList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(siswa['foto']!),
                      ),
                      title: Text(siswa['nama']!),
                      subtitle: Text(siswa['id']!),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(siswa['gender']!),
                          Text(siswa['kelas']!),
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
    );
  }
}
