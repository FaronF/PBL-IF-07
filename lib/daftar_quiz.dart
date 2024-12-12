import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_main.dart'; // Make sure this imports your QuizMainPage

class DaftarQuizPage extends StatefulWidget {
  const DaftarQuizPage({super.key});

  @override
  State<DaftarQuizPage> createState() => _DaftarQuizPageState();
}

class _DaftarQuizPageState extends State<DaftarQuizPage> {
  int _selectedIndex = 2;

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
                  child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance.collection('quiz').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No quizzes found.'));
                      }

                      final quizDocs = snapshot.data!.docs;

                      final userId = FirebaseAuth.instance.currentUser?.uid;

                      return ListView.builder(
                        itemCount: quizDocs.length,
                        itemBuilder: (context, index) {
                          final quiz = quizDocs[index].data();
                          return QuizCard(
                            title: quiz['title'] ?? 'No Title',
                            className: quiz['kelas'] ?? 'No Class',
                            date: quiz['date'] ?? 'No Date',
                            time: quiz['time'] ?? 'No Time',
                            status: quiz['status'] ?? 'Unknown',
                            password: quiz['password'] ?? 'Need password',
                            userId: userId ??
                                'defaultUser  Id', // Use a default or handle null case
                            quizId: quizDocs[index].id, // Tambahkan quizId
                          );
                        },
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
  final String password;
  final String userId;
  final String quizId;

  const QuizCard({
    super.key,
    required this.title,
    required this.className,
    required this.date,
    required this.time,
    required this.status,
    required this.password,
    required this.userId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _checkQuizAttempt(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue,
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
      ),
    );
  }

  Future<void> _checkQuizAttempt(BuildContext context) async {
    final quizAttempts = await FirebaseFirestore.instance
        .collection('Students')
        .doc(userId)
        .collection('QuizAttempts')
        .where('quizId', isEqualTo: quizId)
        .get();

    if (quizAttempts.docs.isNotEmpty) {
      // Ambil nilai terbaru
      final latestAttempt = quizAttempts.docs.last;
      final score = latestAttempt['score'];

      // Tampilkan popup nilai
      _showScorePopup(context, score);
    } else {
      // Tampilkan dialog password hanya jika tidak ada upaya kuis sebelumnya
      _showPasswordDialog(context);
    }
  }

  void _showScorePopup(BuildContext context, int score) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Selesai'),
          content: Text('Nilai kamu: $score'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text == password) {
                  Navigator.of(context).pop();
                  _startQuiz(context);
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
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

  void _startQuiz(BuildContext context) {
    // Logic to start the quiz
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizMainPage(quizId: quizId)),
    );
  }
}
