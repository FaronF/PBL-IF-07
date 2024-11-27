import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

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
                    'assets/images/background2.png', // Replace with your image
                    'Tugas',
                    '/daftar_tugas', // Route to Tugas page
                    height: 140, // Set height smaller
                    width: 250, // Set width smaller
                  ),
                  const SizedBox(height: 20),
                  _buildDashboardBox(
                    context,
                    'assets/images/background3.png', // Replace with your image
                    'Quiz',
                    '/daftar_quiz', // Route to Tugas page
                    height: 140, // Set height smaller
                    width: 250, // Set width smaller
                  ),
                ],
              ),
            ),
          ),
          // Add another swipeable page if needed
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDashboardBox(
                    context,
                    'assets/images/background3.png', // Replace with your image
                    'Quiz',
                    '/quiz', // Route to Quiz page
                    height: 100, // Set height smaller
                    width: 250, // Set width smaller
                  ),
                  const SizedBox(height: 50),
                  _buildDashboardBox(
                    context,
                    'assets/images/background4.png', // Replace with your image
                    'Leaderboard',
                    '/leaderboard', // Route to Leaderboard page
                    height: 100, // Set height smaller
                    width: 250, // Set width smaller
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
      BuildContext context, String imagePath, String title, String routeName,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.black45.withOpacity(
                          0.5), // Semi-transparent background for text
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
          );
        },
      ),
    );
  }
}
