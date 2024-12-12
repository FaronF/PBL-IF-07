import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin_page.dart';
import 'kelola_pengajar.dart';
import 'kelola_pengguna.dart';
import 'materi_page.dart';
import 'teacher_page.dart';
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
import 'profile_admin.dart';
import 'quiz_main.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning PBL IF-07',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Mengatur font menjadi Poppins
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        //Halaman Siswa
        '/studentpage': (context) => const StudentPage(),
        '/edit_profile': (context) => const ProfilePage(),
        '/daftar_tugas': (context) => const DaftarTugasPage(),
        '/daftar_quiz': (context) => const DaftarQuizPage(),
        '/quiz_siswa': (context) => const QuizPage(),
        '/materi': (context) => const MateriPage(),
        '/quiz_main': (context) => const QuizMainPage(quizId: 'quizIdAnda'),

        //Halaman Guru
        '/teacherpage': (context) => const TeacherPage(),
        '/profileguru': (context) => const ProfileGuruPage(),
        '/kelolaakademik': (context) => const KelolaAkademikPage(),
        '/daftarsiswa': (context) => const DaftarSiswaPage(),
        '/kelolamateri': (context) => const KelolaMateriPage(),
        '/kelolatugassiswa': (context) => const KelolaTugasSiswa(),
        '/kelolaquizsiswa': (context) => const KelolaQuizSiswa(),
        '/kelolapenilaiansiswa': (context) => const KelolaPenilaianSiswa(),

        // Halaman Admin
        '/adminpage': (context) => const AdminPage(),
        '/profileadmin': (context) => const ProfileAdminPage(),
        '/kelolapengguna': (context) => const KelolaPenggunaPage(),
        '/kelolapengajar': (context) => const KelolaPengajarPage(),
      },
    );
  }
}
