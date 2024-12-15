import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_quiz.dart';

class KelolaQuizSiswa extends StatefulWidget {
  const KelolaQuizSiswa({Key? key}) : super(key: key);

  @override
  _KelolaQuizSiswaState createState() => _KelolaQuizSiswaState();
}

class _KelolaQuizSiswaState extends State<KelolaQuizSiswa> {
  List<QueryDocumentSnapshot> quizzes = [];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/teacherpage');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/kelolaakademik');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/kelolamateri');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/daftarsiswa');
    }
  }

  Future<void> _fetchQuizzes() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('quiz').get();

      setState(() {
        quizzes = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching quizzes: $e');
    }
  }

  void _navigateToAddQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddQuizPage()),
    );
  }

  void showDeleteConfirmation(String quizId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus quiz ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteQuiz(quizId);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteQuiz(String quizId) async {
    try {
      await FirebaseFirestore.instance.collection('quiz').doc(quizId).delete();
      _fetchQuizzes(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting quiz: $e');
    }
  }

  void _navigateToEditQuiz(String quizId) {
    FirebaseFirestore.instance
        .collection('quiz')
        .doc(quizId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> quizData =
            documentSnapshot.data() as Map<String, dynamic>;

        List<Map<String, dynamic>> questions = (quizData['questions'] as List?)
                ?.map((q) => Map<String, dynamic>.from(q))
                .toList() ??
            [];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditQuizPage(
              quizId: quizId,
              initialTitle: quizData['title'] ?? '',
              initialKelas: quizData['kelas'] ?? '',
              initialDate: quizData['date'] ?? '',
              initialTime: quizData['time'] ?? '',
              initialPassword: quizData['password'] ?? '', // Pastikan ini ada
              initialStatus: quizData['status'] ?? '',
              initialQuestions: questions,
            ),
          ),
        ).then((_) => _fetchQuizzes());
      }
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
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 253, 240, 69),
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
                        "Kelola Quiz",
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('quiz').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Tidak ada quiz tersedia.'));
                    }

                    final quizzes = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        final quizId = quizzes[index].id;

                        return QuizCard(
                          title: quiz['title'] ?? 'Tanpa Judul',
                          kelas: quiz['kelas'] ?? 'Kelas Tidak Diketahui',
                          date: quiz['date'] ?? 'Tanggal Tidak Diketahui',
                          time: quiz['time'] ?? 'Waktu Tidak Diketahui',
                          status: quiz['status'] ?? 'Status Tidak Diketahui',
                          quizId: quizId,
                          onDelete: showDeleteConfirmation,
                          onEdit: (
                            title,
                            kelas,
                            date,
                            time,
                            quizId,
                          ) {
                            _navigateToEditQuiz(
                                quizId); // Panggil metode untuk navigasi
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuiz,
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add, size: 32),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AddQuizPage extends StatefulWidget {
  const AddQuizPage({Key? key}) : super(key: key);

  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  String title = '';
  String kelas = '';
  String date = '';
  String time = '';
  String password = ''; // Tambahkan field password
  String status = 'Dibuka'; // Default status
  List<Map<String, dynamic>> questions = [];
  List<String> kelasOptions = []; // List untuk menyimpan opsi kelas

  // Controllers untuk TextField
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKelasOptions(); // Fetch kelas options on init
  }

  Future<void> _fetchKelasOptions() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Kelas').get();
      setState(() {
        kelasOptions =
            querySnapshot.docs.map((doc) => doc['kelas'] as String).toList();
      });
    } catch (e) {
      print('Error fetching kelas options: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        date = DateFormat('dd MMMM yyyy')
            .format(pickedDate); // Format tanggal menjadi dd-MMMM-yyyy
        dateController.text = date; // Update controller
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        time = pickedTime.format(context); // Simpan waktu yang dipilih
        timeController.text = time; // Update controller
      });
    }
  }

  void _addQuestion() {
    setState(() {
      questions.add({
        'question': '',
        'answers': [],
        'correctAnswer': null,
      });
    });
  }

  void _removeQuestion(int questionIndex) {
    setState(() {
      questions.removeAt(questionIndex);
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      questions[questionIndex]['answers'].add({'text': '', 'isCorrect': false});
    });
  }

  void _removeAnswer(int questionIndex, int answerIndex) {
    setState(() {
      questions[questionIndex]['answers'].removeAt(answerIndex);
      // Reset correctAnswer if the removed answer was the correct one
      if (questions[questionIndex]['correctAnswer'] == answerIndex) {
        questions[questionIndex]['correctAnswer'] = null;
      } else if (questions[questionIndex]['correctAnswer'] != null &&
          questions[questionIndex]['correctAnswer'] > answerIndex) {
        questions[questionIndex]['correctAnswer']--;
      }
    });
  }

  void _setCorrectAnswer(int questionIndex, int answerIndex) {
    setState(() {
      questions[questionIndex]['correctAnswer'] = answerIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, // Menyembunyikan toolbar AppBar
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(children: [
          Column(
            children: <Widget>[
              // Header setengah lingkaran
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
              const SizedBox(height: 10), // Memberi jarak setelah header
              Expanded(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10), // Memberi jarak dari atas
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Judul Quiz',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                      controller: titleController,
                    ),
                    const SizedBox(height: 16),
                    // Dropdown untuk Kelas
                    DropdownButtonFormField<String>(
                      value: kelas.isNotEmpty ? kelas : null,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Pilih Kelas'),
                      onChanged: (String? newValue) {
                        setState(() {
                          kelas = newValue!;
                        });
                      },
                      isExpanded: true, // Agar dropdown mengisi lebar
                      items: kelasOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Tombol untuk memilih tanggal
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: date.isEmpty ? 'Pilih Tanggal' : date,
                            suffixIcon: const Icon(
                                Icons.calendar_today), // Ikon kalender di kanan
                          ),
                          controller: dateController, // Menggunakan controller
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Waktu',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Format: HH:MM', // Petunjuk format waktu
                            suffixIcon: const Icon(
                                Icons.access_time), // Ikon jam di kanan
                          ),
                          controller: timeController, // Menggunakan controller
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Input untuk Password
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Dropdown untuk Status
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          status = newValue!;
                        });
                      },
                      isExpanded: true,
                      items: <String>['Dibuka', 'Ditutup']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Masukkan Soal dan Jawaban:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...questions.asMap().entries.map((entry) {
                      int questionIndex = entry.key;
                      Map<String, dynamic> question = entry.value;
                      return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Soal ${questionIndex + 1}',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      question['question'] = value;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Menampilkan jawaban
                                  ...question['answers']
                                    .asMap()
                                    .entries
                                    .map((answerEntry) {
                                      int answerIndex = answerEntry.key;
                                      Map<String, dynamic> answer = answerEntry.value;
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Opsi ${answerIndex + 1}',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    answer['text'] = value;
                                                  },
                                                ),
                                              ),
                                              Radio(
                                                value: answerIndex,
                                                groupValue: question['correctAnswer'],
                                                onChanged: (value) {
                                                  _setCorrectAnswer(questionIndex, answerIndex);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  _removeAnswer(questionIndex, answerIndex);
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10), // Jarak antar opsi
                                        ],
                                      );
                                    }).toList(),
                                  const SizedBox(height: 8),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            _addAnswer(questionIndex),
                                        style: ElevatedButton.styleFrom(),
                                        child: const Icon(
                                            Icons.add), // Hanya ikon tambah
                                      ),
                                      const SizedBox(
                                          width: 16), // Spasi antara tombol
                                      ElevatedButton(
                                        onPressed: () =>
                                            _removeQuestion(questionIndex),
                                        style: ElevatedButton.styleFrom(),
                                        child: const Icon(
                                            Icons.delete), // Hanya ikon hapus
                                      ),
                                    ],
                                  ),
                                ]),
                          ));
                    }).toList(),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Mengatur ukuran minimum dari Row
                        children: const [
                          Icon(Icons.add), // Ikon tambah
                          SizedBox(width: 8), // Spasi antara ikon dan teks
                          Text('Tambah Soal'), // Teks soal
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (title.isNotEmpty &&
                            kelas.isNotEmpty &&
                            date.isNotEmpty &&
                            time.isNotEmpty &&
                            password.isNotEmpty &&
                            questions.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('quiz')
                              .add({
                            'title': title,
                            'kelas': kelas,
                            'date': date,
                            'time': time,
                            'questions': questions,
                            'status': status, // Simpan status
                            'password': password, // Simpan password
                          });
                          Navigator.of(context)
                              .pop(); // Close the add quiz page
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Semua field harus diisi!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.yellow, // Warna latar belakang tombol
                      ),
                      child: const Text('Simpan Quiz'),
                    ),
                  ],
                ),
              ))
            ],
          ),
          // Teks di tengah atas
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 50.0), // Mengatur jarak dari atas
              child: Text(
                'Tambah Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Tombol panah kembali di kiri atas
          Positioned(
              top: 40, // Posisi vertikal dari tombol
              left: 16, // Jarak dari kiri
              child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  }))
        ]));
  }
}

class QuizCard extends StatelessWidget {
  final String title;
  final String kelas;
  final String date;
  final String time;
  final String status;
  final String quizId;
  final Function(String) onDelete;
  final Function(String, String, String, String, String) onEdit;

  const QuizCard({
    Key? key,
    required this.title,
    required this.kelas,
    required this.date,
    required this.time,
    required this.status,
    required this.quizId,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  kelas,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('quiz')
                          .doc(quizId)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          onEdit(title, kelas, date, time, quizId);
                        }
                      });
                    },
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      onDelete(quizId);
                    },
                    color: Colors.white,
                  ),
                ],
              ),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
