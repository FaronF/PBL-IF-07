import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'daftar_quiz.dart'; // Pastikan untuk mengimpor halaman DaftarQuizPage

class FeedbackPage extends StatelessWidget {
  final int score;

  const FeedbackPage({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

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
                        "Feedback",
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
              const SizedBox(height: 20),
              Text(
                'Skor Anda: $score',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Berikan umpan balik:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tulis umpan balik Anda di sini...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String feedback = feedbackController.text;

                  // Save feedback to Firestore
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    String userId = currentUser.uid;

                    await FirebaseFirestore.instance
                        .collection('Students')
                        .doc(userId)
                        .collection('Feedbacks') // Ganti ke koleksi Feedbacks
                        .doc() // Create a new document
                        .set({
                      'feedback': feedback, // Hanya simpan field feedback
                    }).then((_) {
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Umpan balik berhasil disimpan!')),
                      );
                      // Navigate to DaftarQuizPage after saving feedback
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DaftarQuizPage()),
                      );
                    }).catchError((error) {
                      print("Failed to save feedback: $error");
                    });
                  } else {
                    print("No user is currently signed in.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 253, 240, 69), // Warna latar belakang kuning
                  foregroundColor: Colors.black, // Warna teks tombol
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
