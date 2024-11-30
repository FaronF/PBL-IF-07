import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaPengajarPage extends StatefulWidget {
  const KelolaPengajarPage({super.key});

  @override
  _KelolaPengajarPageState createState() => _KelolaPengajarPageState();
}

class _KelolaPengajarPageState extends State<KelolaPengajarPage> {
  int _selectedIndex = 2; // Menyimpan indeks item yang dipilih

  // Method untuk menangani perubahan item yang dipilih
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman yang sesuai
    switch (index) {
      case 0:
        // Navigasi ke halaman Home
        Navigator.pushNamed(context, '/adminpage');
        break;
      case 1:
        // Navigasi ke halaman Kelola Akademik
        Navigator.pushNamed(context, '/kelolapengguna');
        break;
      case 2:
        // Navigasi ke halaman Materi
        Navigator.pushNamed(context, '/kelolapengajar');
        break;
    }
  }

  Future<void> hapusPengajar(String id, String email, String password) async {
    try {
      // Menghapus akun pengguna dari Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Hapus pengguna dari Firebase Authentication
      await userCredential.user!.delete();

      // Menghapus data siswa dari Firestore
      await FirebaseFirestore.instance.collection('Teachers').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna berhasil dihapus')),
      );
      debugPrint('Pengajar berhasil dihapus');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pengajar: $e')),
      );
      debugPrint('Gagal menghapus pengajar: $e');
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi
  void showDeleteConfirmationDialog(String id, String email, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content:
              const Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                hapusPengajar(id, email,
                    password); // Memanggil fungsi hapus pengguna dengan semua argumen
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showTambahPengajarDialog(BuildContext context) {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pengajar'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Pengajar'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Membuat akun di Firebase Authentication
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  // Mendapatkan UID dari pengguna yang baru dibuat
                  String uid = userCredential.user!.uid;

                  // Menyimpan data pengajar ke Firestore
                  await FirebaseFirestore.instance
                      .collection('Teachers')
                      .doc(uid)
                      .set({
                    'nama': namaController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text.trim(),
                  });

                  // Menampilkan SnackBar setelah berhasil menambahkan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Pengajar berhasil ditambahkan')),
                  );

                  Navigator.of(context)
                      .pop(); // Menutup dialog setelah menambahkan
                } catch (e) {
                  // Menangani kesalahan jika terjadi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan pengajar: $e')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

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
              ),
              const SizedBox(height: 10),

              // Konten Utama
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Teachers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'));
                    }

                    final teachers = snapshot.data?.docs ?? [];
                    if (teachers.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada data pengajar.'));
                    }

                    return ListView.builder(
                      itemCount: teachers.length,
                      itemBuilder: (context, index) {
                        final teacher =
                            teachers[index].data() as Map<String, dynamic>;
                        final teacherId = teachers[index].id;
                        final email = teacher[
                            'email']; // Ambil email siswa (pastikan ini ada di data)
                        final password = teacher[
                            'password']; // Ambil password siswa (pastikan ini ada di data)

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title:
                                Text(teacher['nama'] ?? 'Nama tidak tersedia'),
                            subtitle: Text('Email: ${teacher['email'] ?? '-'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDeleteConfirmationDialog(
                                          teacherId, email, password);
                                    }),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Teks di tengah atas
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 40.0), // Mengatur jarak dari atas
              child: Text(
                'Kelola Pengajar',
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
            icon: Icon(Icons.person),
            label: 'Kelola User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chrome_reader_mode_rounded),
            label: 'Kelola Pengajar',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTambahPengajarDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
