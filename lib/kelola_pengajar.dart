import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_pengajar.dart';
import 'edit_pengajar.dart';

class KelolaPengajarPage extends StatelessWidget {
  const KelolaPengajarPage({super.key});

  Future<void> hapusPengajar(String id) async {
    try {
      await FirebaseFirestore.instance.collection('teachers').doc(id).delete();
      debugPrint('Pengajar berhasil dihapus');
    } catch (e) {
      debugPrint('Gagal menghapus pengajar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pengajar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TambahPengajarPage()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final teachers = snapshot.data?.docs ?? [];
          if (teachers.isEmpty) {
            return const Center(child: Text('Tidak ada data pengajar.'));
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index].data() as Map<String, dynamic>;
              final teacherId = teachers[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(teacher['nama'] ?? 'Nama tidak tersedia'),
                  subtitle: Text('Email: ${teacher['email'] ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditPengajarPage(pengajarId: teacherId),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusPengajar(teacherId),
                      ),
                    ],
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