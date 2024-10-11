import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int totalQuestions = 10;
  int score = 0;
  Duration timerDuration = Duration(seconds: 15);
  String selectedAnswer = "";
  String feedbackMessage = "";

  List<Map<String, dynamic>> questions = [
    {
      "question":
          "Enzim restriksi digunakan dalam teknik rekayasa genetika. Menurutmu apa fungsi utama enzim restriksi dalam rekayasa genetika?",
      "options": [
        "Memotong molekul DNA pada urutan basa tertentu",
        "Menggabungkan potongan-potongan DNA",
        "Menyalin molekul DNA",
        "Menerjemahkan kode genetik menjadi protein"
      ],
      "correctAnswer": "Memotong molekul DNA pada urutan basa tertentu",
    },
    // More questions can be added here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Memberi warna biru langit pada AppBar
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          children: [
            // Menambahkan logo di dalam AppBar
            Image.asset(
              'assets/images/logo.png', // Ganti dengan path logo Anda
              height: 40, // Sesuaikan ukuran logo
            ),
            const SizedBox(width: 10), // Spasi antara logo dan nama website
            const Text(
              'SMA IT ULIL ALBAB', // Ganti dengan nama website Anda
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AutoSizeText(
              questions[currentQuestion]["question"],
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
              maxLines: 5, // Allows up to 3 lines for the question
              minFontSize: 14, // Minimum size before it truncates
              overflow: TextOverflow.ellipsis, // Handles overflow with "..."
            ),
            SizedBox(height: 20),
            // Creating the answer buttons with different background colors
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[200], // Light Blue color
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  selectedAnswer = questions[currentQuestion]["options"][0];
                });
              },
              child: AutoSizeText(
                questions[currentQuestion]["options"][0],
                style: TextStyle(color: Colors.black), // Text color black
                maxLines: 1, // Limit text to 1 line
                minFontSize: 10, // Minimum font size before truncating
                overflow:
                    TextOverflow.ellipsis, // If text is too long, show "..."
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200], // Light Purple color
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  selectedAnswer = questions[currentQuestion]["options"][1];
                });
              },
              child: AutoSizeText(
                questions[currentQuestion]["options"][1],
                style: TextStyle(color: Colors.black), // Text color black
                maxLines: 1, // Limit text to 1 line
                minFontSize: 10, // Minimum font size before truncating
                overflow:
                    TextOverflow.ellipsis, // If text is too long, show "..."
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[200], // Light Orange color
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  selectedAnswer = questions[currentQuestion]["options"][2];
                });
              },
              child: AutoSizeText(
                questions[currentQuestion]["options"][2],
                style: TextStyle(color: Colors.black), // Text color black
                maxLines: 1, // Limit text to 1 line
                minFontSize: 10, // Minimum font size before truncating
                overflow:
                    TextOverflow.ellipsis, // If text is too long, show "..."
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[200], // Light Yellow color
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                setState(() {
                  selectedAnswer = questions[currentQuestion]["options"][3];
                });
              },
              child: AutoSizeText(
                questions[currentQuestion]["options"][3],
                style: TextStyle(color: Colors.black), // Text color black
                maxLines: 1, // Limit text to 1 line
                minFontSize: 10, // Minimum font size before truncating
                overflow:
                    TextOverflow.ellipsis, // If text is too long, show "..."
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (currentQuestion > 0) {
                  setState(() {
                    currentQuestion--;
                    selectedAnswer = ""; // reset selection
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Implement navigation to question list screen
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                if (currentQuestion < totalQuestions - 1) {
                  setState(() {
                    currentQuestion++;
                    selectedAnswer = ""; // reset selection
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
