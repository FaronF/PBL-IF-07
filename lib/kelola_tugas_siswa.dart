import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaTugasSiswa extends StatefulWidget {
  const KelolaTugasSiswa({super.key});

  @override
  KelolaTugasSiswaState createState() => KelolaTugasSiswaState();
}

class KelolaTugasSiswaState extends State<KelolaTugasSiswa> {
  final int _selectedIndex = 1;

  // Reference to Firestore collection
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('Tasks');
  final CollectionReference classesCollection =
      FirebaseFirestore.instance.collection('Kelas'); // Koleksi kelas

  String? selectedClass; // Variabel untuk menyimpan kelas yang dipilih

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Controller untuk tanggal dan waktu
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked; // Update selectedDate
        dateController.text = DateFormat('dd MMMM yyyy')
            .format(selectedDate); // Update controller
      });
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked; // Update selectedTime
        timeController.text = selectedTime.format(context); // Update controller
      });
    }
  }

  // Fungsi untuk menghapus tugas dari Firebase Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      await tasksCollection.doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus tugas: $e')),
      );
    }
  }

  // Function to show delete confirmation dialog
  void showDeleteConfirmationDialog(String taskId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tugas'),
          content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Hapus tugas dan tutup dialog
                deleteTask(taskId).then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to add a new task
  Future<String> addTask(String title, String className, String description,
      String date, String time) async {
    DocumentReference docRef = await tasksCollection.add({
      'title': title,
      'class': className,
      'description': description,
      'date': date, // Simpan tanggal sebagai string
      'time': time, // Simpan waktu sebagai string
    });
    return docRef.id; // Return the generated taskId
  }

  // Function to update a task
  Future<void> updateTask(String taskId, String title, String className,
      String description, String date, String time) async {
    return tasksCollection.doc(taskId).update({
      'title': title,
      'class': className,
      'description': description,
      'date': date, // Simpan tanggal sebagai string
      'time': time, // Simpan waktu sebagai string
    });
  }

  // Show form for adding/editing tasks
  void showTaskForm(
      {String? taskId,
      String? currentTitle,
      String? currentClass,
      String? currentDescription,
      String? currentDate,
      String? currentTime}) {
    final formKey = GlobalKey<FormState>();
    String title = currentTitle ?? '';
    String description = currentDescription ?? '';

    // Inisialisasi tanggal dan waktu
    selectedDate = currentDate != null
        ? DateFormat('dd MMMM yyyy')
            .parse(currentDate) // Parse string to DateTime
        : DateTime.now(); // Set selectedDate to now if currentDate is null

    selectedTime = currentTime != null
        ? TimeOfDay.fromDateTime(
            DateFormat('HH:mm').parse(currentTime)) // Parse string to TimeOfDay
        : TimeOfDay.now(); // Set selectedTime to now if currentTime is null

    // Update controller dengan nilai awal
    dateController.text = DateFormat('dd MMMM yyyy').format(selectedDate);
    timeController.text = selectedTime.format(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskId == null ? 'Tambah Tugas' : 'Edit Tugas'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    onChanged: (value) {
                      title = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  // Dropdown untuk memilih kelas
                  FutureBuilder<QuerySnapshot>(
                    future: classesCollection.get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      final classes = snapshot.data!.docs;

                      return DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(labelText: 'Kelas'),
                        items: classes.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc['kelas'],
                            child: Text(doc['kelas']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedClass = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Kelas tidak boleh kosong';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    minLines: 3, // Atur jumlah baris minimal
                    maxLines:
                        null, // Biarkan pengguna menambahkan baris sebanyak yang diinginkan
                    onChanged: (value) {
                      description = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  // Field untuk tanggal
                  TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true, // Membuat field ini hanya bisa dibaca
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'Waktu',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                    readOnly: true, // Membuat field ini hanya bisa dibaca
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String dateString =
                      DateFormat('dd MMMM yyyy').format(selectedDate);
                  String timeString = selectedTime.format(context);

                  if (taskId == null) {
                    // Tambah tugas dan ambil taskId
                    String newTaskId = await addTask(
                      title,
                      selectedClass!,
                      description,
                      dateString, // Kirim tanggal sebagai string
                      timeString, // Kirim waktu sebagai string
                    );
                    // Tampilkan pesan konfirmasi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Tugas berhasil ditambahkan dengan ID: $newTaskId'),
                      ),
                    );
                  } else {
                    // Perbarui tugas
                    await updateTask(
                      taskId,
                      title,
                      selectedClass!,
                      description,
                      dateString, // Kirim tanggal sebagai string
                      timeString, // Kirim waktu sebagai string
                    );
                    // Tampilkan pesan konfirmasi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tugas berhasil diperbarui')),
                    );
                  }
                  Navigator.of(context).pop(); // Tutup dialog setelah menyimpan
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Mengatur tinggi toolbar
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
                  color: Color.fromARGB(255, 253, 240, 69), // Warna header
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Memberi jarak setelah header

              // Menggunakan StreamBuilder untuk mengambil data dari Firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: tasksCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tasks = snapshot.data!.docs;

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada tugas yang tersedia.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];

                        return Column(children: [
                          _buildContentCard(
                            task.id, // taskId
                            task['title'], // Judul Tugas
                            task['class'], // Kelas
                            task['description'], // Deskripsi
                            task['date'], // Tanggal jatuh tempo sebagai string
                            task['time'], // Waktu jatuh tempo sebagai string
                          ),
                          const SizedBox(
                              height:
                                  20), // Menambahkan jarak 20 pixels antara setiap tugas
                        ]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Teks di tengah atas
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 40.0), // Mengatur jarak dari atas
              child: Text(
                'Kelola Tugas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
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
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/teacherpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/kelolaakademik');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/kelolamateri');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/daftarsiswa');
          }
        },
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Buka form untuk menambahkan tugas
          showTaskForm();
        },
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContentCard(String taskId, String title, String className,
      String description, String dueDate, String dueTime) {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(className, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Due: $dueDate $dueTime',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Buka form untuk mengedit tugas
                showTaskForm(
                  taskId: taskId,
                  currentTitle: title,
                  currentClass: className,
                  currentDescription: description,
                  currentDate: dueDate, // Kirim dueDate sebagai string
                  currentTime: dueTime, // Kirim dueTime sebagai string
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDeleteConfirmationDialog(taskId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
