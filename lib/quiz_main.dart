import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tester/feedback_page.dart';
import 'dart:async';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});
  @override
  QuizMainPageState createState() => QuizMainPageState();
}

class QuizMainPageState extends State<QuizMainPage> {
  int currentQuestionIndex = 0;
  int totalTime = 60; // Total time in seconds for the entire quiz
  late Timer timer;
  List<Map<String, dynamic>> questions = [];
  List<int?> selectedAnswers = []; // List to store selected answers
  String studentId = ""; // Initialize studentId as an empty string

  final List<Color> optionColors = [
    Colors.blue[400]!,
    Colors.green[700]!,
    Colors.purple[600]!,
    Colors.pink[700]!,
  ];

  @override
  void initState() {
    super.initState();
    fetchStudentId(); // Fetch student ID from Firestore
    fetchQuestions(); // Fetch questions from Firestore
    startTimer();
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

  void fetchQuestions() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('quiz').get();
      List<Map<String, dynamic>> fetchedQuestions = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Check if 'questions' is an array
        if (data['questions'] is List) {
          for (var question in data['questions']) {
            if (question is Map<String, dynamic>) {
              String questionText =
                  question['question'] ?? 'Pertanyaan tidak tersedia';
              List<Map<String, dynamic>> answers =
                  List<Map<String, dynamic>>.from(question['answers'] ?? []);
              int correctAnswerIndex = question['correctAnswer'] ??
                  -1; // Using -1 as default if not available

              fetchedQuestions.add({
                "question": questionText,
                "options": answers.map((answer) => answer['text']).toList(),
                "correctAnswerIndex":
                    correctAnswerIndex, // Store the index of the correct answer
              });
            }
          }
        }
      }

      setState(() {
        questions = fetchedQuestions; // Update the state with fetched questions
        selectedAnswers = List<int?>.filled(
            questions.length, null); // Initialize selected answers
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
          timer.cancel();
          endQuiz();
        }
      });
    });
  }

  void endQuiz() {
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
              saveResultsToFirestore(score);

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

  void saveResultsToFirestore(int score) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      CollectionReference studentsCollection =
          FirebaseFirestore.instance.collection('Students');

      await studentsCollection.doc(userId).collection('QuizAttempts').add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        print("Quiz attempt data saved successfully");
        // Redirect to QuizResultPage after saving data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackPage(score: score), // Pass the score
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
        endQuiz();
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
          title: const Text("Quiz"), // Menambahkan judul pada AppBar
          backgroundColor:
              const Color.fromARGB(255, 253, 240, 69), // Warna kuning
          elevation: 4, // Menambahkan sedikit elevasi untuk efek bayangan
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding di seluruh body
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menambahkan indikator jawaban
                      Text(
                        'Soal ${currentQuestionIndex + 1} / ${questions.length} ${selectedAnswers[currentQuestionIndex] != null ? '✓' : '✗'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Waktu: $totalTime detik',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Mengurangi jarak
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10), // Mengurangi jarak
                  ...currentQuestion['options'].asMap().entries.map<Widget>(
                    (entry) {
                      int index = entry.key;
                      String option = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0), // Tambahkan padding vertikal
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                optionColors[index % optionColors.length],
                            foregroundColor: Colors.white, // Set text color
                          ),
                          onPressed: () {
                            setState(() {
                              selectedAnswers[currentQuestionIndex] =
                                  index; // Simpan jawaban yang dipilih
                            });
                            nextQuestion(); // Pindah ke soal berikutnya setelah memilih jawaban
                          },
                          child: Text(option),
                        ),
                      );
                    },
                  ).toList(),
                  const SizedBox(
                      height: 10), // Mengurangi jarak di bawah pilihan jawaban
                ],
              ),
            ),
            // Baris untuk tombol Next dan Previous
            Positioned(
              bottom: 16, // Jarak dari bawah
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: currentQuestionIndex == 0
                    ? MainAxisAlignment
                        .end // Posisi tombol Next di kanan untuk soal pertama
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (currentQuestionIndex >
                      0) // Tampilkan tombol "Previous" hanya jika bukan soal pertama
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Warna latar belakang putih
                        foregroundColor: Colors.black, // Warna teks hitam
                      ),
                      onPressed: previousQuestion,
                      child: const Text('Previous'),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentQuestionIndex <
                              questions.length - 1
                          ? Colors.white // Tombol "Next" berwarna putih
                          : const Color.fromARGB(255, 253, 240,
                              69), // Tombol "Finish Attempt" berwarna kuning
                      foregroundColor: Colors.black, // Warna teks hitam
                    ),
                    onPressed: () {
                      if (currentQuestionIndex < questions.length - 1) {
                        nextQuestion();
                      } else {
                        // Cek apakah semua jawaban telah dipilih
                        bool allAnswered = true;
                        for (var answer in selectedAnswers) {
                          if (answer == null) {
                            allAnswered = false;
                            break;
                          }
                        }

                        if (!allAnswered) {
                          // Jika ada soal yang belum dijawab, tampilkan pesan kesalahan
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Anda harus menjawab semua soal sebelum menyelesaikan kuis!'),
                            ),
                          );
                        } else {
                          timer
                              .cancel(); // Hentikan timer saat menyelesaikan kuis
                          endQuiz(); // Tampilkan dialog penyelesaian
                        }
                      }
                    },
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? 'Next'
                          : 'Finish Attempt',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
