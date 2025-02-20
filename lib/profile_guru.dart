import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileGuruPage extends StatefulWidget {
  const ProfileGuruPage({super.key});

  @override
  EditProfileGuruPageState createState() => EditProfileGuruPageState();
}

class EditProfileGuruPageState extends State<ProfileGuruPage> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _nuptk = '';
  String _kelas = '';
  String _mapel = '';
  List<String> _kelasList = []; // Daftar kelas
  String? _selectedKelas; // Kelas yang dipilih

  @override
  void initState() {
    super.initState();
    _getUserProfile(); // Ambil data pengguna saat inisialisasi
    _getKelasList(); // Ambil daftar kelas
  }

  Future<void> _reauthenticateUser(String email, String password) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    }
  }

  Future<void> _getKelasList() async {
    QuerySnapshot snapshot = await _firestore.collection('Kelas').get();
    List<String> kelasList = [];
    for (var doc in snapshot.docs) {
      kelasList.add(doc['kelas']); // Asumsikan field 'kelas' ada di dokumen
    }
    setState(() {
      _kelasList = kelasList;
      _selectedKelas =
          _kelas; // Set kelas yang dipilih ke kelas pengguna saat ini
    });
  }

  Future<void> _getUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile =
          await _firestore.collection('Teachers').doc(user.uid).get();

      if (userProfile.exists) {
        setState(() {
          _name = userProfile['nama'];
          _email = userProfile['email'];
          _nuptk = userProfile['nuptk'];
          _kelas = userProfile['kelas'];
          _mapel = userProfile['mapel'];
          _passwordController.text = userProfile['password'];
          _selectedKelas = _kelas; // Set kelas yang dipilih
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User  profile not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently logged in')),
      );
    }
  }

  Future<void> _updateKelas(String newKelas) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Teachers').doc(user.uid).update({
        'kelas': newKelas,
      });
      setState(() {
        _kelas = newKelas; // Update kelas di state
        _selectedKelas = newKelas; // Update kelas yang dipilih
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas berhasil diperbarui')),
      );
    }
  }

  Future<void> showChangePasswordModal() async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController currentPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
                    labelStyle: const TextStyle(color: Color(0xFF000000)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true, // Hides the text input
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    labelStyle: const TextStyle(color: Color(0xFF000000)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true, // Hides the text input
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    labelStyle: const TextStyle(color: Color(0xFF000000)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  obscureText: true, // Hides the text input
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
                onPressed: () {
                  if (newPasswordController.text ==
                      confirmPasswordController.text) {
                    // Ambil email dari current user
                    String email = FirebaseAuth.instance.currentUser!.email!;
                    _updatePassword(
                      newPasswordController.text,
                      email,
                      currentPasswordController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password tidak cocok')),
                    );
                  }
                },
                child: const Text('Simpan')),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(
      String newPassword, String email, String currentPassword) async {
    try {
      // Reauthenticate user
      await _reauthenticateUser(email, currentPassword);

      // Mengubah password di Firebase Authentication
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

      // Mengambil user ID
      final User? user = FirebaseAuth.instance.currentUser;

      // Memperbarui password di Firestore
      if (user != null) {
        await _firestore.collection('Teachers').doc(user.uid).update({
          'password':
              newPassword, // Pastikan field ini sesuai dengan struktur Firestore Anda
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );
    } catch (e) {
      print('Error updating password: $e'); // Menampilkan kesalahan di konsol
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah password: ${e.toString()}')),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa logout
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _logout(); // Panggil fungsi logout
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk logout
  void _logout() {
    FirebaseAuth.instance.signOut(); // Lakukan proses sign out
    Navigator.pushReplacementNamed(
        context, '/login'); // Arahkan ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // Header setengah lingkaran
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 240, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(190),
                bottomRight: Radius.circular(190),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -30,
                  left: 30,
                  width: 200,
                  height: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo-ulilalbab.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 45,
                  right: 25,
                  child: IconButton(
                    onPressed: () {
                      _showLogoutConfirmation(context);
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Profile form
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildDisplayField('Nama', _name),
                    const SizedBox(height: 16),
                    _buildDisplayField('Email', _email),
                    const SizedBox(height: 16),
                    _buildDisplayField('NUPTK', _nuptk),
                    const SizedBox(height: 16),
                    _buildDisplayField('Mata Pelajaran', _mapel),
                    const SizedBox(height: 16),
                    _buildDropdownField(), // Menambahkan dropdown kelas
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Password',
                        isPassword: true, onEdit: showChangePasswordModal),
                    const SizedBox(height: 20),
                  ],
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
            icon: Icon(Icons.school),
            label: 'Kelola Akademik',
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
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/teacherpage');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/kelolaakademik');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/kelolamateri');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/daftarsiswa');
              break;
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

  Widget _buildDisplayField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kelas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedKelas,
              isExpanded: true,
              hint: const Text('Pilih Kelas'),
              items: _kelasList.map((String kelas) {
                return DropdownMenuItem<String>(
                  value: kelas,
                  child: Text(kelas),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKelas = newValue;
                });
                if (newValue != null) {
                  _updateKelas(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false, VoidCallback? onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPassword ? '********' : controller.text,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
