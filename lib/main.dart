import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dbsiswa_page.dart';
import 'edit_profile.dart';
import 'daftar_tugas.dart';
import 'daftar_quiz.dart';
import 'quiz_siswa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Application',
      debugShowCheckedModeBanner: false, // Menonaktifkan label Debug
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/daftar_tugas': (context) => DaftarTugasPage(),
        '/daftar_quiz': (context) => DaftarQuizPage(),
        '/quiz_siswa': (context) => QuizPage(),
      },
    );
  }
}
