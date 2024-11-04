import 'package:flutter/material.dart';

class KelolaAkademikPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          // Wrap in SingleChildScrollView for vertical scroll support
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDashboardBox(
                    context,
                    'Kelola Tugas',
                    '/kelolatugassiswa', // Route to Tugas page
                    height: 60, // Set height smaller
                    width: 140, // Set width smaller
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Quiz',
                    '/kelola_quiz_siswa', // Route to Quiz page
                    height: 60, // Set height smaller
                    width: 140, // Set width smaller
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Konten Pelajaran',
                    '/kelola_konten_pelajaran', // Route to Konten Pelajaran page
                    height: 60, // Set height smaller
                    width: 140, // Set width smaller
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'Kelola Penilaian',
                    '/kelola_penilaian', // Route to Penilaian page
                    height: 60, // Set height smaller
                    width: 140, // Set width smaller
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each dashboard box with adjustable size
  Widget _buildDashboardBox(
      BuildContext context, String title, String routeName,
      {double height = 150, double width = double.infinity}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
            context, routeName); // Navigate to the respective page
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: height, // Use passed height value to adjust size
            width: width, // Use passed width value to adjust size
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 8.0,
                ),
              ],
              color: const Color.fromARGB(255, 131, 142, 240), // Set background color if needed
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 12, 12, 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
