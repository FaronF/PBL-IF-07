import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _selectedIndex = 2; // Track the selected tab index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected tab
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/studentpage');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/materi');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/quiz_siswa');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Menyembunyikan tinggi AppBar default
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              // Header berbentuk setengah lingkaran dengan teks
              Stack(
                children: [
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
                  Center(
                    child: Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: const Text(
                        "Halaman Quiz",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Lebar konten 80% dari lebar layar
                    child: Center(
                      child: PageView(
                        children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDashboardBox(
                                    context,
                                    'assets/images/background2.png',
                                    'Tugas',
                                    '/daftar_tugas',
                                    height: 140,
                                    width: 250,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDashboardBox(
                                    context,
                                    'assets/images/background3.png',
                                    'Quiz',
                                    '/daftar_quiz',
                                    height: 140,
                                    width: 250,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
            icon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Quiz',
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
    );
  }

  Widget _buildDashboardBox(
      BuildContext context, String imagePath, String title, String routeName,
      {double height = 150, double width = double.infinity}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: height,
            width: width,
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.black45.withOpacity(0.5),
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
