import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dummy data for user profile
  @override
  void initState() {
    super.initState();
    _nameController.text = "Darren Watkins";
    _classController.text = "11 MIPA 2";
    _emailController.text = "ishowspeed@gmail.com";
  }

  // Method to handle saving profile
  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  // Method untuk handle logout
  void _logout() {
    // Arahkan kembali ke halaman login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Memberi warna biru langit pada AppBar
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          children: [
            // Menambahkan logo di dalam AppBar
            Image.asset(
              'assets/images/logo.png', // Ganti dengan path logo Anda
              height: 40, // Sesuaikan ukuran logo
            ),
            const SizedBox(width: 10), // Spasi antara logo dan nama website
            const Text(
              'SMA IT ULIL ALBAB', // Ganti dengan nama website Anda
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Tampilkan alert dialog ketika tombol logout ditekan
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Logout"),
                    content: Text("Apakah Anda Ingin Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Batal", tutup dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Ya", lakukan logout dan redirect ke halaman login
                          Navigator.of(context)
                              .pop(); // Tutup dialog terlebih dahulu
                          Navigator.pushReplacementNamed(
                              context, '/login'); // Redirect ke login
                        },
                        child: Text("Ya"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top profile section
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/background.png'), // Replace with your background image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                        'assets/images/profile.png'), // Replace with profile image
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60), // Space for profile image offset

            // Profile form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Nama'),
                  const SizedBox(height: 16),
                  _buildTextField(_classController, 'Kelas'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 30),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      backgroundColor: const Color.fromARGB(
                          255, 211, 204, 204), // Sky blue color for the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/pelajaran');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/edit_profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Pelajaran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Text field for profile input
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
