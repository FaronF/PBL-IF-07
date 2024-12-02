import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditQuizPage extends StatefulWidget {
  final String quizId;
  final String initialTitle;
  final String initialKelas;
  final String initialDate;
  final String initialTime;
  final List<Map<String, dynamic>> initialQuestions;

  const EditQuizPage({
    Key? key,
    required this.quizId,
    required this.initialTitle,
    required this.initialKelas,
    required this.initialDate,
    required this.initialTime,
    required this.initialQuestions,
  }) : super(key: key);

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  // Controllers untuk field utama
  late TextEditingController _titleController;
  late TextEditingController _kelasController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  // Controllers untuk pertanyaan dan jawaban
  late List<TextEditingController> _questionControllers;
  late List<List<TextEditingController>> _answerControllers;

  // State quiz
  late String title;
  late String kelas;
  late String date;
  late String time;
  late List<Map<String, dynamic>> questions;

  // Scroll controller untuk optimasi scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Inisialisasi data awal
    _initializeData();

    // Inisialisasi controllers
    _initializeControllers();
  }

  void _initializeData() {
    title = widget.initialTitle;
    kelas = widget.initialKelas;
    date = widget.initialDate;
    time = widget.initialTime;
    questions = List.from(widget.initialQuestions);
  }

  void _initializeControllers() {
    // Controller untuk field utama
    _titleController = TextEditingController(text: title);
    _kelasController = TextEditingController(text: kelas);
    _dateController = TextEditingController(text: date);
    _timeController = TextEditingController(text: time);

    // Controller untuk pertanyaan
    _questionControllers = questions
        .map((q) => TextEditingController(text: q['question']))
        .toList();

    // Controller untuk jawaban
    _answerControllers = questions
        .map((q) => (q['answers'] as List)
            .map((a) => TextEditingController(text: a['text']))
            .toList())
        .toList();
  }

  @override
  void dispose() {
    // Bersihkan semua controllers
    _titleController.dispose();
    _kelasController.dispose();
    _dateController.dispose();
    _timeController.dispose();

    _questionControllers.forEach((controller) => controller.dispose());
    _answerControllers.forEach((answers) {
      answers.forEach((controller) => controller.dispose());
    });

    _scrollController.dispose();
    super.dispose();
  }

  void _setCorrectAnswer(int questionIndex, int answerIndex) {
    setState(() {
      questions[questionIndex]['correctAnswer'] = answerIndex;
    });
  }

  void _addAnswer(int questionIndex) {
    setState(() {
      questions[questionIndex]['answers'].add({
        'text': '',
        'isCorrect': false,
      });

      // Tambah controller untuk jawaban baru
      _answerControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeAnswer(int questionIndex, int answerIndex) {
    setState(() {
      // Hapus jawaban
      questions[questionIndex]['answers'].removeAt(answerIndex);

      // Hapus controller jawaban
      _answerControllers[questionIndex][answerIndex].dispose();
      _answerControllers[questionIndex].removeAt(answerIndex);
    });
  }

  void _addQuestion() {
    setState(() {
      // Tambah pertanyaan baru
      questions.add({
        'question': '',
        'answers': [
          {'text': '', 'isCorrect': false},
          {'text': '', 'isCorrect': false},
        ],
        'correctAnswer': null,
      });

      // Tambah controller untuk pertanyaan baru
      _questionControllers.add(TextEditingController());

      // Tambah controller untuk jawaban
      _answerControllers.add([
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _removeQuestion(int questionIndex) {
    setState(() {
      // Hapus pertanyaan
      questions.removeAt(questionIndex);

      // Hapus controller pertanyaan
      _questionControllers[questionIndex].dispose();
      _questionControllers.removeAt(questionIndex);

      // Hapus controller jawaban
      _answerControllers[questionIndex]
          .forEach((controller) => controller.dispose());
      _answerControllers.removeAt(questionIndex);
    });
  }

  Future<void> _saveQuiz() async {
    // Update data dari controllers
    for (int i = 0; i < questions.length; i++) {
      questions[i]['question'] = _questionControllers[i].text;

      for (int j = 0; j < questions[i]['answers'].length; j++) {
        questions[i]['answers'][j]['text'] = _answerControllers[i][j].text;
      }
    }

    // Validasi data
    if (_validateQuizData()) {
      try {
        await FirebaseFirestore.instance
            .collection('quiz')
            .doc(widget.quizId)
            .update({
          'title': _titleController.text,
          'kelas': _kelasController.text,
          'date': _dateController.text,
          'time': _timeController.text,
          'questions': questions,
          'status': 'Dibuka',
        });
        Navigator.of(context).pop();
      } catch (e) {
        _showErrorSnackBar('Gagal menyimpan quiz: ${e.toString()}');
      }
    }
  }

  bool _validateQuizData() {
    if (_titleController.text.isEmpty ||
        _kelasController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        questions.isEmpty) {
      _showErrorSnackBar('Semua field harus diisi!');
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              // Header setengah lingkaran
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
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Quiz',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _kelasController,
                        decoration: const InputDecoration(
                          labelText: 'Kelas',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            kelas = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            date = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Waktu',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            time = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Masukkan Soal dan Jawaban:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Daftar Pertanyaan
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
                                  controller:
                                      _questionControllers[questionIndex],
                                  decoration: InputDecoration(
                                    labelText: 'Soal ${questionIndex + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      question['question'] = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Daftar Jawaban
                                ...question['answers']
                                    .asMap()
                                    .entries
                                    .map((answerEntry) {
                                  int answerIndex = answerEntry.key;
                                  Map<String, dynamic> answer =
                                      answerEntry.value;
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              _answerControllers[questionIndex]
                                                  [answerIndex],
                                          decoration: InputDecoration(
                                            labelText:
                                                'Opsi ${answerIndex + 1}',
                                            border: const OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              answer['text'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Radio(
                                        value: answerIndex,
                                        groupValue: question['correctAnswer'],
                                        onChanged: (value) {
                                          _setCorrectAnswer(
                                              questionIndex, answerIndex);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _removeAnswer(
                                              questionIndex, answerIndex);
                                        },
                                      ),
                                    ],
                                  );
                                }).toList(),

                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _addAnswer(questionIndex),
                                      child: const Icon(Icons.add),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _removeQuestion(questionIndex),
                                      child: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                      // Tombol Tambah Soal
                      ElevatedButton(
                        onPressed: _addQuestion,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Tambah Soal'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tombol Simpan
                      ElevatedButton(
                        onPressed: _saveQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                        ),
                        child: const Text('Simpan Quiz'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Judul Halaman
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text(
                'Edit Quiz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Tombol Kembali
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }
}
