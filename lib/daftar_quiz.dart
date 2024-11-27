import 'package:flutter/material.dart';

class DaftarQuizPage extends StatefulWidget {
  const DaftarQuizPage({super.key});

  @override
  State<DaftarQuizPage> createState() => _DaftarQuizPageState();
}

class _DaftarQuizPageState extends State<DaftarQuizPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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

  final List<Map<String, String>> quizzes = [
    {
      'title': 'Genetika',
      'class': '10 MIPA C',
      'date': 'Selasa 15 September',
      'time': '13.00–14.30',
      'status': 'Dibuka',
    },
    {
      'title': 'Virus',
      'class': '10 MIPA D',
      'date': 'Kamis 12 Agustus',
      'time': '09.45–12.00',
      'status': 'Ditutup',
    },
    {
      'title': 'Mutasi',
      'class': '10 MIPA B',
      'date': 'Senin 27 Agustus',
      'time': '10.00–12.00',
      'status': 'Selesai',
    },
  ];

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
                        "Daftar Quiz",
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return QuizCard(
                        title: quiz['title']!,
                        className: quiz['class']!,
                        date: quiz['date']!,
                        time: quiz['time']!,
                        status: quiz['status']!,
                      );
                    },
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
}

class QuizCard extends StatelessWidget {
  final String title;
  final String className;
  final String date;
  final String time;
  final String status;

  const QuizCard({
    super.key,
    required this.title,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  className,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date\n$time',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dibuka':
        return Colors.black;
      case 'Ditutup':
        return Colors.red;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}
