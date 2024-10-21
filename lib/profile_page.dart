import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<ProfilePage> {
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
        toolbarHeight: 0, // Mengatur tinggi toolbar
        backgroundColor: Colors.transparent,
        elevation: 0,
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
    );
  }
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
