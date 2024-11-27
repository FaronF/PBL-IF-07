import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_pengguna.dart';

class KelolaPenggunaPage extends StatelessWidget {
  const KelolaPenggunaPage({super.key});

  Future<void> hapusPengguna(String id) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(id).delete();
      debugPrint('Pengguna berhasil dihapus');
    } catch (e) {
      debugPrint('Gagal menghapus pengguna: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengguna (Siswa)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TambahPenggunaPage()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final students = snapshot.data?.docs ?? [];
          if (students.isEmpty) {
            return const Center(child: Text('Tidak ada data siswa.'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              final studentId = students[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(student['nama'] ?? 'Nama tidak tersedia'),
                  subtitle: Text('Kelas: ${student['kelas'] ?? '-'}\n'
                      'NISN: ${student['nisn'] ?? '-'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusPengguna(studentId),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}