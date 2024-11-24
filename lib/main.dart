import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tester/materi_page.dart';
import 'package:tester/teacher_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'student_page.dart';
import 'profile_page.dart';
import 'daftar_tugas.dart';
import 'daftar_quiz.dart';
import 'quiz_page.dart';
import 'daftar_siswa.dart';
import 'kelola_materi_page.dart';
import 'kelola_akademik_page.dart';
import 'kelola_tugas_siswa.dart';
import 'kelola_quiz_siswa.dart';
import 'kelola_penilaian_siswa.dart';
import 'profile_guru.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase untuk platform web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDEfBtaQnT6s2xXiA6hj9bXXUiEdhuHvoc",
        projectId: "pbl-if-07-a80a9",
        storageBucket: "pbl-if-07-a80a9.appspot.com",
        messagingSenderId: "982195135418",
        appId: "1:982195135418:android:1e98ea88f921faa5203383",
      ),
    );
  } else {
    // Inisialisasi Firebase untuk platform mobile (Android/iOS)
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning PBL IF-07',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/studentpage': (context) => StudentPage(),
        '/teacherpage': (context) => TeacherPage(),
        '/edit_profile': (context) => ProfilePage(),
        '/profileguru': (context) => ProfileGuruPage(),
        '/daftar_tugas': (context) => DaftarTugasPage(),
        '/daftar_quiz': (context) => DaftarQuizPage(),
        '/quiz_siswa': (context) => QuizPage(),
        '/materi': (context) => MateriPage(),
        '/kelolaakademik': (context) => KelolaAkademikPage(),
        '/daftarsiswa': (context) => DaftarSiswaPage(),
        '/kelolamateri': (context) => KelolaMateriPage(),
        '/kelolatugassiswa': (context) => KelolaTugasSiswa(),
        '/kelolaquizsiswa': (context) => KelolaQuizSiswa(),
        '/kelolapenilaiansiswa': (context) => KelolaPenilaianSiswa(),
      },
    );
  }
}
