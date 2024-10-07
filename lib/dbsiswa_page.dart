import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Implement the edit profile action
              Navigator.pushReplacementNamed(
                  context, '/edit_profile'); // Redirect to login
            },
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardBox(
              context,
              'assets/images/background1.png', // Replace with your image
              'Materi',
              '/materi', // Route to Materi page
            ),
            const SizedBox(height: 12),
            _buildDashboardBox(
              context,
              'assets/images/background2.png', // Replace with your image
              'Tugas',
              '/daftar_tugas', // Route to Tugas page
            ),
            const SizedBox(height: 12),
            _buildDashboardBox(
              context,
              'assets/images/background3.png', // Replace with your image
              'Quiz',
              '/daftar_quiz', // Route to Quiz page
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

  // Method to build each dashboard box with full background image and centered text
  Widget _buildDashboardBox(
      BuildContext context, String imagePath, String title, String routeName) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
            context, routeName); // Navigate to the respective page
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 8.0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Centered text with background shadow
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black45
                      .withOpacity(0.5), // Semi-transparent background for text
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
