import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EditQuizPage extends StatefulWidget {
  final String quizId;
  final String initialTitle;
  final String initialKelas;
  final String initialDate;
  final String initialTime;
  final String initialStatus;
  final String initialPassword;
  final String initialDuration;
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
    required this.initialDuration,
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
  late String duration;
  List<Map<String, dynamic>> questions = [];
  List<String> kelasList = []; // Variabel untuk menyimpan daftar kelas

  // Controllers untuk TextField
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController hourController =
      TextEditingController(); // Controller untuk jam
  final TextEditingController minuteController =
      TextEditingController(); // Controller untuk menit

  String durationError = '';

  @override
  void initState() {
    super.initState();
    title = widget.initialTitle;
    kelas = widget.initialKelas;
    date = widget.initialDate;
    time = widget.initialTime;
    status = widget.initialStatus;
    password = widget.initialPassword;
    duration = widget.initialDuration; // Inisialisasi durasi
    questions = List.from(widget.initialQuestions);
    _fetchKelas(); // Memanggil fungsi untuk mengambil data kelas

// Set initial values for controllers
    titleController.text = title;
    dateController.text = date;
    timeController.text = time;
    passwordController.text = password;

    // Set initial values for hour and minute controllers
    if (duration.isNotEmpty) {
      final parts = duration.split(':');
      if (parts.length == 2) {
        hourController.text = parts[0].replaceAll('j', ''); // Ambil jam
        minuteController.text = parts[1].replaceAll('m', ''); // Ambil menit
      }
    }
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

  bool updateDuration() {
    String hours = hourController.text.isNotEmpty ? hourController.text : '00';
    String minutes =
        minuteController.text.isNotEmpty ? minuteController.text : '00';

    // Validasi durasi
    if (hours.length == 2 && minutes.length == 2) {
      duration = '$hours:$minutes'; // Format durasi menjadi hh:mm
      durationError = ''; // Reset error
      return true; // Durasi valid
    } else {
      durationError = 'Format durasi harus hh:mm (4 angka)';
      return false; // Durasi tidak valid
    }
  }

  void _updateQuiz() async {
    // Panggil updateDuration dan simpan hasilnya
    bool isDurationValid = updateDuration();

    // Jika durasi tidak valid, tampilkan pesan kesalahan dan hentikan eksekusi
    if (!isDurationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(durationError)),
      );
      return; // Hentikan eksekusi jika durasi tidak valid
    }

    if (title.isNotEmpty &&
        kelas.isNotEmpty &&
        date.isNotEmpty &&
        time.isNotEmpty &&
        duration.isNotEmpty &&
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
          'duration': duration, // Simpan durasi dalam format hh:mm
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
            Navigator.pushNamed(context, '/kelolaquizsiswa');
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
                controller: titleController,
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

              // Tombol untuk memilih waktu
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Waktu',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: time.isEmpty
                          ? 'Format: HH:MM'
                          : time, // Petunjuk format waktu
                      suffixIcon:
                          const Icon(Icons.access_time), // Ikon jam di kanan
                    ),
                    controller: timeController, // Menggunakan controller
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field untuk Durasi
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hourController,
                      decoration: const InputDecoration(
                        labelText: 'Jam (hh)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (value) {
                        setState(() {
                          updateDuration();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: minuteController,
                      decoration: const InputDecoration(
                        labelText: 'Menit (mm)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (value) {
                        setState(() {
                          updateDuration();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (durationError.isNotEmpty)
                Text(
                  durationError,
                  style: TextStyle(color: Colors.red),
                ),
              Text(
                'Durasi Quiz: ${duration.isNotEmpty ? duration : ''}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                controller: passwordController, // Menggunakan controller
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
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            question['question'] = value;
                          },
                          controller:
                              TextEditingController(text: question['question']),
                        ),
                        const SizedBox(height: 16),
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
                                        border: const OutlineInputBorder(),
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
                              ),
                              const SizedBox(
                                  height: 10), // Menambahkan jarak antar opsi
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
