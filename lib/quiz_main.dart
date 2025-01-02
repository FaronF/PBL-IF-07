import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tester/feedback_page.dart';
import 'dart:async';

class QuizMainPage extends StatefulWidget {
  final String quizId;

  const QuizMainPage({super.key, required this.quizId});

  @override
  QuizMainPageState createState() => QuizMainPageState();
}

class QuizMainPageState extends State<QuizMainPage> {
  int currentQuestionIndex = 0;
  int totalTime = 0; // Total time in seconds for the entire quiz
  late Timer timer;
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = []; // List to store selected answers
  String studentId = ""; // Initialize studentId as an empty string
  bool isLoading = true; // Flag untuk menunjukkan apakah data sedang di-load
  String _quizId = ''; // Variabel untuk menyimpan nilai quizId

  final List<Color> optionColors = [
    Colors.blue[400]!,
    Colors.green[700]!,
    Colors.purple[600]!,
    Colors.pink[700]!,
  ];

  void selectQuizId() async {
    // Fungsi untuk memilih quizId secara dinamis
    // Contoh: dari database, dari pengguna, dll.
    _quizId = widget.quizId; // Ambil nilai quizId dari widget
    fetchQuestions(_quizId); // Fetch questions from Firestore
  }

  @override
  void initState() {
    super.initState();
    fetchStudentId(); // Fetch student ID from Firestore
    selectQuizId(); // Pilih quizId secara dinamis
    // Tambahkan delay untuk memastikan bahwa fetchQuestions selesai sebelum startTimer
    Future.delayed(const Duration(milliseconds: 500), () {
      startTimer();
    });
  }

  void fetchStudentId() async {
    try {
      // Replace 'studentDocumentId' with the actual document ID you want to fetch
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc('studentDocumentId')
          .get();

      if (studentDoc.exists) {
        // Cast the data to Map<String, dynamic>
        Map<String, dynamic>? data = studentDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          setState(() {
            studentId = data['studentId'] ??
                'defaultStudentId'; // Access the studentId field
          });
          print("Student ID: $studentId");
        } else {
          print("No data found in the document!");
        }
      } else {
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching student ID: $e");
    }
  }

  void fetchQuestions(String quizId) async {
    try {
      print('Fetching questions...');
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('quiz').doc(quizId).get();
      print('Questions fetched.');
      List<Map<String, dynamic>> fetchedQuestions = [];

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;

        // Ambil waktu dari field 'duration' dan konversi ke detik
        String duration =
            data['duration'] ?? '00:01'; // Default ke 00:01 jika tidak ada
        List<String> timeParts = duration.split(':');
        int hours = int.parse(timeParts[0]);
        int minutes = int.parse(timeParts[1]);
        totalTime = (hours * 3600) + (minutes * 60); // Konversi ke detik

        // Check if 'questions' is an array
        if (data['questions'] is List) {
          for (var question in data['questions']) {
            if (question is Map<String, dynamic>) {
              String questionText =
                  question['question'] ?? 'Pertanyaan tidak tersedia';
              List<Map<String, dynamic>> answers =
                  List<Map<String, dynamic>>.from(question['answers'] ?? []);
              int correctAnswerIndex = question['correctAnswer'] ?? -1;

              fetchedQuestions.add({
                "question": questionText,
                "options": answers.map((answer) => answer['text']).toList(),
                "correctAnswerIndex": correctAnswerIndex,
              });
            }
          }
        }
      }

      setState(() {
        questions = fetchedQuestions;
        selectedAnswers = List<int?>.filled(questions.length, null);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (totalTime > 0) {
          totalTime--;
        } else {
          timer.cancel(); // Hentikan timer
          autoFinishQuiz(); // Panggil fungsi untuk menyelesaikan kuis
        }
      });
    });
  }

  String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds detik'; // Tampilkan dalam detik
    } else {
      int hours = totalSeconds ~/ 3600;
      int minutes = (totalSeconds % 3600) ~/ 60;
      int seconds = totalSeconds % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'; // Format hh:mm:ss
    }
  }

  void autoFinishQuiz() {
    // Hitung skor berdasarkan jawaban yang sudah dipilih
    int score = calculateScore();

    // Simpan hasil ke Firestore
    saveResultsToFirestore(score, _quizId);

    // Navigasi langsung ke halaman feedback
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackPage(
          score: score,
          quizId: _quizId,
        ),
      ),
    );
  }

  void endQuiz(String quizId) {
    // Tampilkan dialog konfirmasi sebelum mengakhiri kuis
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin mengakhiri kuis?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Jika pengguna mengonfirmasi, hitung skor dan simpan hasil
              int score = calculateScore();
              saveResultsToFirestore(score, quizId);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kuis Selesai'),
                  content: Text('Skor Anda: $score'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    )
                  ],
                ),
              );
            },
            child: const Text('Finish Attempt'),
          ),
        ],
      ),
    );
  }

  int calculateScore() {
    int score = 0;
    int totalQuestions = questions.length; // Hitung jumlah total pertanyaan

    for (int i = 0; i < totalQuestions; i++) {
      if (selectedAnswers[i] != null &&
          selectedAnswers[i] == questions[i]['correctAnswerIndex']) {
        score += 100 ~/
            totalQuestions; // Tambahkan poin berdasarkan jumlah pertanyaan
      }
    }

    return score; // Kembalikan skor akhir
  }

  void saveResultsToFirestore(int score, String quizId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Students')
          .doc(userId)
          .collection('QuizAttempts')
          .doc(quizId); // Gunakan quizId sebagai ID dokumen

      // Simpan hasil ke Firestore
      await docRef.set({
        'quizId': quizId,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).then((value) {
        print("Quiz attempt data saved successfully");
        // Navigasi ke halaman feedback setelah menyimpan data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackPage(
              quizId: quizId,
              score: score,
            ),
          ),
        );
      }).catchError((error) {
        print("Failed to save quiz attempt data: $error");
      });
    } else {
      print("No user is currently signed in.");
    }
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        timer.cancel();
        endQuiz(_quizId);
      }
    });
  }

  void previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    });
  }

  void showQuestionList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          // Tambahkan Center
          child: AlertDialog(
            title: const Text('Daftar Soal', textAlign: TextAlign.center),
            content: Container(
              width:
                  MediaQuery.of(context).size.width * 0.8, // Atur lebar dialog
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center, // Tambahkan ini
                  children: List.generate(questions.length, (index) {
                    return Center(
                      // Tambahkan Center pada setiap ListTile
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          horizontalTitleGap: 10,
                          leading: CircleAvatar(
                            backgroundColor: selectedAnswers[index] != null
                                ? Colors.green
                                : Colors.red,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            'Soal ${index + 1}',
                            textAlign: TextAlign.center,
                          ),
                          trailing: selectedAnswers[index] != null
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.clear, color: Colors.red),
                          onTap: () {
                            Navigator.of(context).pop(); // Tutup dialog
                            setState(() {
                              currentQuestionIndex =
                                  index; // Pindah ke soal yang dipilih
                            });
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            actions: <Widget>[
              Center(
                // Tambahkan Center pada actions
                child: TextButton(
                  child: const Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(
          child:
              CircularProgressIndicator()); // Show loading indicator while fetching
    }

    var currentQuestion = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: const Color.fromARGB(255, 250, 235, 21),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${currentQuestionIndex + 1} / ${questions.length} ${selectedAnswers[currentQuestionIndex] != null ? '✓' : '✗'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Waktu: ${formatDuration(totalTime)}', // Menampilkan waktu dalam format hh:mm
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                currentQuestion['question'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ...currentQuestion['options'].asMap().entries.map<Widget>(
              (entry) {
                int index = entry.key;
                String option = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          optionColors[index % optionColors.length],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedAnswers[currentQuestionIndex] = index;
                      });
                      nextQuestion();
                    },
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ).toList(),
            const SizedBox(height: 80), // Memberikan ruang di bawah konten
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 196, 194, 179),
        child: SizedBox(
          height: 60, // Tetapkan tinggi yang konsisten
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tombol Previous (selalu ada di posisi yang sama)
              SizedBox(
                width: 60, // Lebar tetap
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: currentQuestionIndex > 0 ? previousQuestion : null,
                ),
              ),

              const SizedBox(width: 16), // Spacer

              // Tombol List Soal (selalu di tengah)
              SizedBox(
                width: 60, // Lebar tetap
                child: IconButton(
                  icon: const Icon(Icons.list, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: showQuestionList,
                ),
              ),

              const SizedBox(width: 16), // Spacer

              // Tombol Next/Finish (selalu ada di posisi yang sama)
              SizedBox(
                width: 60, // Lebar tetap
                child: IconButton(
                  icon: Icon(
                      currentQuestionIndex < questions.length - 1
                          ? Icons.arrow_forward_ios
                          : Icons.check,
                      size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (currentQuestionIndex < questions.length - 1) {
                      nextQuestion();
                    } else {
                      bool allAnswered = true;
                      for (var answer in selectedAnswers) {
                        if (answer == null) {
                          allAnswered = false;
                          break;
                        }
                      }

                      if (!allAnswered) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Anda harus menjawab semua soal sebelum menyelesaikan kuis!'),
                          ),
                        );
                      } else {
                        timer.cancel();
                        endQuiz(_quizId);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
