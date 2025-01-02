import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String quizId;
  final String title;

  Quiz({
    required this.quizId,
    required this.title,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Quiz(
      quizId: doc.id,
      title: data['title'] ?? '',
    );
  }
}

class KelolaPenilaianQuiz extends StatefulWidget {
  const KelolaPenilaianQuiz({super.key});

  @override
  KelolaPenilaianQuizState createState() => KelolaPenilaianQuizState();
}

class KelolaPenilaianQuizState extends State<KelolaPenilaianQuiz> {
  List<Quiz> quizzes = [];

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  void fetchQuizzes() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('quiz').get();
    setState(() {
      quizzes = snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 240, 69),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Daftar Kuis',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    return buildQuizCard(context, quizzes[index]);
                  },
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
            icon: Icon(Icons.school),
            label: 'Kelola Akademik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chrome_reader_mode_rounded),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Student List',
          ),
        ],
        currentIndex: 1, // Set the current index to the appropriate tab
        onTap: (index) {
          // Handle navigation based on the selected index
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/teacherpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/kelolaakademik');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/kelolamateri');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/daftarsiswa');
          }
        },
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget buildQuizCard(BuildContext context, Quiz quiz) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blue[300],
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          quiz.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailsPage(quizId: quiz.quizId),
            ),
          );
        },
      ),
    );
  }
}

class QuizDetailsPage extends StatelessWidget {
  final String quizId;

  const QuizDetailsPage({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kuis'),
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Students').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final studentDocs = snapshot.data!.docs;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(studentDocs.map((studentDoc) async {
              final quizSnapshot = await studentDoc.reference
                  .collection('QuizAttempts')
                  .where('quizId', isEqualTo: quizId)
                  .get();
              return {
                'student': studentDoc.data(),
                'quizAttempts':
                    quizSnapshot.docs.map((doc) => doc.data()).toList(),
              };
            }).toList()),
            builder: (context, quizSnapshot) {
              if (quizSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (quizSnapshot.hasError) {
                return Center(child: Text('Error: ${quizSnapshot.error}'));
              }

              return ListView.builder(
                itemCount: quizSnapshot.data!.length,
                itemBuilder: (context, index) {
                  final studentData = quizSnapshot.data![index]['student'];
                  final quizAttempts =
                      quizSnapshot.data![index]['quizAttempts'];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.grey[300], // Background color for the avatar
                        child: const Icon(
                          Icons.person, // Default user icon
                          color: Colors.black, // Icon color
                        ),
                        radius: 30,
                      ),
                      title: Text(studentData['nama'] ?? 'Unknown Student'),
                      subtitle: quizAttempts.isEmpty
                          ? const Text('No scores found.')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Score: ${quizAttempts.last['score']}'), // Display the latest score
                                const SizedBox(
                                    height:
                                        4), // Add space between score and feedback
                                Text(
                                    'Feedback: ${quizAttempts.last['feedback'] ?? 'No feedback available'}'), // Display feedback below the score
                              ],
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
