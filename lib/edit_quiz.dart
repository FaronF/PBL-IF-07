import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditQuizPage extends StatefulWidget {
  final String quizId;
  final String initialTitle;
  final String initialKelas;
  final String initialDate;
  final String initialTime;
  final String initialStatus;
  final String initialPassword;
  final List<Map<String, dynamic>> initialQuestions;

  const EditQuizPage({
    Key? key,
    required this.quizId,
    required this.initialTitle,
    required this.initialKelas,
    required this.initialDate,
    required this.initialTime,
    required this.initialStatus,
    required this.initialPassword,
    required this.initialQuestions,
  }) : super(key: key);

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  late String title;
  late String kelas;
  late String date;
  late String time;
  late String status;
  late String password;
  List<Map<String, dynamic>> questions = [];
  List<String> kelasList = []; // Variabel untuk menyimpan daftar kelas

  @override
  void initState() {
    super.initState();
    title = widget.initialTitle;
    kelas = widget.initialKelas;
    date = widget.initialDate;
    time = widget.initialTime;
    status = widget.initialStatus;
    password = widget.initialPassword;
    questions = List.from(widget.initialQuestions);
    _fetchKelas(); // Memanggil fungsi untuk mengambil data kelas
  }

  void _fetchKelas() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Kelas').get();
    setState(() {
      kelasList = snapshot.docs
          .map((doc) => doc['kelas'] as String)
          .toList(); // Mengambil field 'kelas'
    });
  }

  void _updateQuiz() async {
    if (title.isNotEmpty &&
        kelas.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty &&
        password.isNotEmpty) {
      bool? confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah Anda yakin ingin menyimpan perubahan?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Simpan'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('quiz')
            .doc(widget.quizId)
            .update({
          'title': title,
          'kelas': kelas,
          'date': date,
          'time': time,
          'status': status,
          'password': password,
          'questions': questions,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diubah!')),
        );
        Navigator.pushNamed(context, '/kelolaquizsiswa');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
    }
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      questions[questionIndex]['answers'].add({'text': '', 'isCorrect': false});
    });
  }

  void _removeQuestion(int questionIndex) {
    setState(() {
      questions.removeAt(questionIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,
                '/kelolaquizsiswa'); // Navigasi ke halaman yang diinginkan
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                controller: TextEditingController(text: title),
              ),
              const SizedBox(height: 16),
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
                isExpanded: true,
                items: kelasList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  date = value;
                },
                controller: TextEditingController(text: date),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Waktu',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  time = value;
                },
                controller: TextEditingController(text: time),
              ),
              const SizedBox(height: 16),
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
                controller: TextEditingController(text: password),
              ),
              const SizedBox(height: 16),
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
              const Text('Soal dan Jawaban:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          controller:
                              TextEditingController(text: question['question']),
                        ),
                        const SizedBox(height: 8),
                        ...question['answers']
                            .asMap()
                            .entries
                            .map((answerEntry) {
                          int answerIndex = answerEntry.key;
                          Map<String, dynamic> answer = answerEntry.value;
                          return Row(
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
                                  controller: TextEditingController(
                                      text: answer['text']),
                                ),
                              ),
                              Radio(
                                value: answerIndex,
                                groupValue: question['correctAnswer'],
                                onChanged: (value) {
                                  setState(() {
                                    question['correctAnswer'] = answerIndex;
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _addAnswer(questionIndex),
                                style: ElevatedButton.styleFrom(),
                                child: const Icon(Icons.add),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _removeQuestion(questionIndex),
                                style: ElevatedButton.styleFrom(),
                                child: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    questions.add({
                      'question': '',
                      'answers': [],
                      'correctAnswer': null,
                    });
                  });
                },
                child: const Text('Tambah Soal'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                ),
                child: const Text('Simpan Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
