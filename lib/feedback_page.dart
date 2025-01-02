import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mapel_quiz.dart';

class FeedbackPage extends StatelessWidget {
  final int score;
  final String quizId; // Tambahkan quizId untuk menyimpan feedback terkait kuis

  const FeedbackPage({Key? key, required this.score, required this.quizId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Menyembunyikan tinggi AppBar default
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                // Header berbentuk setengah lingkaran dengan teks
                Stack(
                  children: [
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color:
                            Color.fromARGB(255, 253, 240, 69), // Warna header
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .yellow, // Mengatur warna latar belakang tombol menjadi kuning
                    foregroundColor: Colors
                        .black, // Mengatur warna teks tombol menjadi hitam
                  ),
                  onPressed: () async {
                    String feedback = feedbackController.text;

                    // Validasi feedback
                    if (feedback.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback tidak boleh kosong!'),
                        ),
                      );
                      return; // Hentikan eksekusi jika feedback kosong
                    } else if (feedback.length > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Feedback tidak boleh lebih dari 30 karakter!'),
                        ),
                      );
                      return; // Hentikan eksekusi jika feedback terlalu panjang
                    }

                    // Simpan feedback ke Firestore di QuizAttempts
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      String userId = currentUser.uid;

                      // Referensi ke dokumen
                      DocumentReference docRef = FirebaseFirestore.instance
                          .collection('Students')
                          .doc(userId)
                          .collection('QuizAttempts')
                          .doc(
                              quizId); // Gunakan quizId untuk mereferensikan dokumen

                      // Perbarui dokumen dengan feedback
                      await docRef.update({
                        'feedback': feedback, // Simpan feedback
                        'timestamp':
                            FieldValue.serverTimestamp(), // Simpan timestamp
                      });

                      // Navigasi ke halaman MapelQuizPage setelah menyimpan feedback
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapelQuizPage(
                              successMessage: 'Feedback berhasil disimpan.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Kirim Feedback'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
