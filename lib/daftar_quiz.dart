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
  String? mapel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil argumen mapel dari navigasi
    mapel = ModalRoute.of(context)?.settings.arguments as String?;
  }

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
        title: const Text('Daftar Quiz'),
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('quiz')
                        .where('mapel',
                            isEqualTo: mapel) // Filter berdasarkan mapel
                        .get(),
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
                            userId: FirebaseAuth.instance.currentUser?.uid ??
                                'defaultUser  Id',
                            quizId: quizDocs[index].id,
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
      final feedback = latestAttempt['feedback'] ??
          'No feedback available'; // Ambil feedback

      // Tampilkan popup nilai dan feedback
      _showScorePopup(context, score, feedback);
    } else {
      // Tampilkan dialog password hanya jika tidak ada upaya kuis sebelumnya
      _showPasswordDialog(context);
    }
  }

  void _showScorePopup(BuildContext context, int score, String feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          title: const Text(
            'Quiz Selesai',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10), // Add vertical padding
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Make the dialog size wrap its content
              children: [
                Text(
                  'Nilai kamu: $score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10), // Add some space
                Text(
                  'Feedback:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Add some space
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center, // Center align the feedback text
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
