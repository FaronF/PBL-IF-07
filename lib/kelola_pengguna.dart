import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaPenggunaPage extends StatefulWidget {
  const KelolaPenggunaPage({super.key});

  @override
  KelolaPenggunaPageState createState() => KelolaPenggunaPageState();
}

class KelolaPenggunaPageState extends State<KelolaPenggunaPage> {
  int _selectedIndex = 1; // Menyimpan indeks item yang dipilih

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

  Future<void> hapusPengguna(String id, String email, String password) async {
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
      await FirebaseFirestore.instance.collection('Students').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna berhasil dihapus')),
      );
      debugPrint('Pengguna berhasil dihapus');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus pengguna: $e')),
      );
      debugPrint('Gagal menghapus pengguna: $e');
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
                hapusPengguna(id, email,
                    password); // Memanggil fungsi hapus pengguna dengan semua argumen
                Navigator.of(context).pop(); // Menutup dialog
              },
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

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Students')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Terjadi kesalahan: ${snapshot.error}'));
                    }

                    final students = snapshot.data?.docs ?? [];
                    if (students.isEmpty) {
                      return const Center(child: Text('Tidak ada data siswa.'));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student =
                            students[index].data() as Map<String, dynamic>;
                        final studentId = students[index].id; // Ambil ID siswa
                        final email = student[
                            'email']; // Ambil email siswa (pastikan ini ada di data)
                        final password = student[
                            'password']; // Ambil password siswa (pastikan ini ada di data)

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            title:
                                Text(student['nama'] ?? 'Nama tidak tersedia'),
                            subtitle: Text('Kelas: ${student['kelas'] ?? '-'}\n'
                                'NISN: ${student['nisn'] ?? '-'}'),
                            trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Memanggil fungsi dengan argumen yang benar
                                  showDeleteConfirmationDialog(
                                      studentId, email, password);
                                }),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
          // Teks di tengah atas
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 40.0), // Meng atur jarak dari atas
              child: Text(
                'Kelola Pengguna',
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahPenggunaPage()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class TambahPenggunaPage extends StatefulWidget {
  const TambahPenggunaPage({Key? key}) : super(key: key);

  @override
  _TambahPenggunaPageState createState() => _TambahPenggunaPageState();
}

class _TambahPenggunaPageState extends State<TambahPenggunaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String gender = 'Laki-laki';

  Future<void> tambahPengguna() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('Students').doc(uid).set({
          'nama': namaController.text.trim(),
          'email': emailController.text.trim(),
          'kelas': kelasController.text.trim(),
          'nisn': nisnController.text.trim(),
          'gender': gender,
          'password': passwordController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pengguna: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pengguna',
          style: TextStyle(color: Colors.black), // Teks hitam
        ),
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        iconTheme: const IconThemeData(color: Colors.black), // Ikon hitam
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: namaController,
                label: 'Nama',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              buildTextField(
                controller: kelasController,
                label: 'Kelas',
                icon: Icons.class_,
              ),
              const SizedBox(height: 15),
              buildTextField(
                controller: nisnController,
                label: 'NISN',
                icon: Icons.badge,
              ),
              const SizedBox(height: 15),
              buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      value: 'Laki-laki',
                      groupValue: gender,
                      title: const Text('Laki-laki'),
                      onChanged: (value) {
                        setState(() => gender = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      value: 'Perempuan',
                      groupValue: gender,
                      title: const Text('Perempuan'),
                      onChanged: (value) {
                        setState(() => gender = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: tambahPengguna,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 240, 69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Teks hitam
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.lightBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.lightBlue),
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}
