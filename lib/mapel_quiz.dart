import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapelQuizPage extends StatefulWidget {
  final String? successMessage; // Define the successMessage parameter

  const MapelQuizPage({Key? key, this.successMessage}) : super(key: key);

  @override
  _MapelQuizPageState createState() => _MapelQuizPageState();
}

class _MapelQuizPageState extends State<MapelQuizPage> {
  List<String> mapelList = []; // List untuk menyimpan nama mata pelajaran

  @override
  void initState() {
    super.initState();
    _fetchMapel(); // Ambil data mata pelajaran saat halaman diinisialisasi
    // Show the success message if it exists
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            duration: const Duration(seconds: 2), // Duration of SnackBar
          ),
        );
      });
    }
  }

  Future<void> _fetchMapel() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Mapel').get();
      setState(() {
        mapelList =
            querySnapshot.docs.map((doc) => doc['mapel'] as String).toList();
      });
    } catch (e) {
      print('Error fetching mapel: $e');
    }
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
              // Header setengah lingkaran dengan teks
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
                        "Mapel Quiz",
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: mapelList.map((mapel) {
                        return Column(
                          children: [
                            _buildDashboardBox(
                              context,
                              mapel,
                              '/daftar_quiz', // Ganti dengan route yang sesuai
                              height: 70,
                              width: double.infinity,
                              onTap: () {
                                Navigator.pushNamed(context, '/daftar_quiz',
                                    arguments: mapel);
                              },
                            ),
                            const SizedBox(
                                height: 20), // Jarak antara setiap DashboardBox
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/studentpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/materi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/quiz_siswa');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Tugas',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }

  Widget _buildDashboardBox(
      BuildContext context, String title, String routeName,
      {double height = 150,
      double width = double.infinity,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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
              color: const Color.fromARGB(255, 131, 142, 240),
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
