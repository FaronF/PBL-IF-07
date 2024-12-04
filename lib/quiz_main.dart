import 'package:flutter/material.dart';
import 'dart:async';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuizMainPage(),
    );
  }
}

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});
  @override
  QuizMainPageState createState() => QuizMainPageState();
}

class QuizMainPageState extends State<QuizMainPage> {
  int currentQuestionIndex = 0;
  int totalTime = 60; // Total time in seconds for the entire quiz
  late Timer timer;

  List<Map<String, dynamic>> questions = [
    {
      "question": "Apa ibukota Indonesia?",
      "options": ["Jakarta", "Surabaya", "Bandung", "Medan"],
      "answer": "Jakarta",
    },
    {
      "question": "Berapa hasil dari 5 + 3?",
      "options": ["6", "7", "8", "9"],
      "answer": "8",
    },
    {
      "question": "Siapa penemu bola lampu?",
      "options": [
        "Albert Einstein",
        "Thomas Edison",
        "Nikola Tesla",
        "Isaac Newton"
      ],
      "answer": "Thomas Edison",
    }
  ];

  final List<Color> optionColors = [
    Colors.blue[400]!,
    Colors.green[700]!,
    Colors.purple[600]!,
    Colors.pink[700]!,
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kuis Selesai'),
        content: const Text('Waktu habis! Terima kasih telah mengikuti kuis.'),
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
    var currentQuestion = questions[currentQuestionIndex];
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
                      height: 110,
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
              // Bagian utama Quiz
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Soal ${currentQuestionIndex + 1} / ${questions.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Waktu: $totalTime detik',
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentQuestion['question'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ...currentQuestion['options'].asMap().entries.map<Widget>(
                        (entry) {
                          int index = entry.key;
                          String option = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0), // Tambahkan padding vertikal
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    optionColors[index % optionColors.length],
                                foregroundColor: Colors.white, // Set text color
                              ),
                              onPressed: () {
                                // Add logic for option selection
                              },
                              child: Text(option),
                            ),
                          );
                        },
                      ).toList(),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: currentQuestionIndex == 0
                            ? MainAxisAlignment.end // Jika soal pertama, tombol "Next" di kanan
                            : MainAxisAlignment.spaceBetween, // Jika bukan soal pertama, tombol diatur di kedua sisi
                        children: [
                          if (currentQuestionIndex > 0) // Tampilkan tombol "Previous" hanya jika bukan soal pertama
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Warna latar belakang putih
                                foregroundColor: Colors.black, // Warna teks hitam
                              ),
                              onPressed: previousQuestion,
                              child: const Text('Previous'),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentQuestionIndex < questions.length - 1
                                  ? Colors.white // Tombol "Next" berwarna putih
                                  : const Color.fromARGB(255, 253, 240, 69), // Tombol "Finish Attempt" berwarna kuning
                              foregroundColor: Colors.black, // Warna teks hitam
                            ),
                            onPressed: () {
                              if (currentQuestionIndex < questions.length - 1) {
                                nextQuestion();
                              } else {
                                timer.cancel(); // Hentikan timer saat menyelesaikan kuis
                                endQuiz(); // Tampilkan dialog penyelesaian
                              }
                            },
                            child: Text(
                              currentQuestionIndex < questions.length - 1 ? 'Next' : 'Finish Attempt',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
