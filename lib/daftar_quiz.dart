import 'package:flutter/material.dart';
import 'profile_page.dart';

class DaftarQuizPage extends StatefulWidget {
  @override
  _DaftarQuizPageState createState() => _DaftarQuizPageState();
}

class _DaftarQuizPageState extends State<DaftarQuizPage> {
  final List<Map<String, String>> quizzes = [
    {
      'title': 'Mikroorganisme',
      'description': 'Quiz tentang Mikroorganisme.',
      'deadline': '10 Oktober 2024',
      'status': 'Ditutup',
    },
    {
      'title': 'Molekul',
      'description': 'Quiz mengenai Molekul.',
      'deadline': '12 Oktober 2024',
      'status': 'Dibuka',
    },
    {
      'title': 'Virus',
      'description': 'Quiz tentang Virus.',
      'deadline': '15 Oktober 2024',
      'status': 'Belum Dibuka',
    },
  ];

  int _selectedIndex = 2; // For the bottom navigation

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/materi');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/quiz');
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
      body: Column(
        children: <Widget>[
          // Header setengah lingkaran
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 253, 240, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -30,
                  left: 15,
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
                  top: 40,
                  right: 25,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Quiz
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return QuizItem(
                    title: quiz['title']!,
                    description: quiz['description']!,
                    deadline: quiz['deadline']!,
                    status: quiz['status']!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
            label: 'Quiz',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 255, 234, 0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}

class QuizItem extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final String status;

  const QuizItem({
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (status == 'Dibuka') {
          _showPasswordDialog(context);
        } else if (status == 'Ditutup') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "$title" Telah Ditutup.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "$title" Belum Dibuka.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  Text(
                    'Deadline: $deadline',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: Text(
                status,
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dibuka':
        return Colors.green;
      case 'Ditutup':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == '1234') {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Password benar. Mengarahkan ke quiz...')),
                  );
                  Navigator.pushNamed(context, '/quiz_siswa');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password salah.')),
                  );
                }
              },
              child: const Text('Mulai Quiz'),
            ),
          ],
        );
      },
    );
  }
}
