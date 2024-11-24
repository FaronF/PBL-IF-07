import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KelolaTugasSiswa extends StatefulWidget {
  @override
  KelolaTugasSiswaState createState() => KelolaTugasSiswaState();
}

class KelolaTugasSiswaState extends State<KelolaTugasSiswa> {
  int _selectedIndex = 1;

  // Reference to Firestore collection
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection('Tasks');

  // Fungsi untuk menghapus tugas dari Firebase Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tugas berhasil dihapus')),
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
          title: Text('Hapus Tugas'),
          content: Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Hapus tugas dan tutup dialog
                deleteTask(taskId).then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to add a new task
  Future<String> addTask(String title, String className, String description,
      DateTime dueTo) async {
    DocumentReference docRef = await tasksCollection.add({
      'title': title,
      'class': className,
      'description': description,
      'due_to': Timestamp.fromDate(dueTo),
    });
    return docRef.id; // Return the generated taskId
  }

  // Function to update a task
  Future<void> updateTask(String taskId, String title, String className,
      String description, DateTime dueTo) {
    return tasksCollection.doc(taskId).update({
      'title': title,
      'class': className,
      'description': description,
      'due_to': Timestamp.fromDate(dueTo),
    });
  }

  // Show form for adding/editing tasks
  void showTaskForm(
      {String? taskId,
      String? currentTitle,
      String? currentClass,
      String? currentDescription,
      DateTime? currentDueTo}) {
    final _formKey = GlobalKey<FormState>();
    String title = currentTitle ?? '';
    String className = currentClass ?? '';
    String description = currentDescription ?? '';
    DateTime dueTo = currentDueTo ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(taskId == null ? 'Tambah Tugas' : 'Edit Tugas'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: InputDecoration(labelText: 'Judul'),
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
                  TextFormField(
                    initialValue: className,
                    decoration: InputDecoration(labelText: 'Kelas'),
                    onChanged: (value) {
                      className = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kelas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Deskripsi'),
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
                  TextFormField(
                    initialValue: DateFormat('dd-MM-yyyy HH:mm').format(dueTo),
                    decoration: InputDecoration(labelText: 'Deadline'),
                    onChanged: (value) {
                      dueTo = DateFormat('dd-MM-yyyy HH:mm').parse(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jatuh tempo tidak boleh kosong';
                      }
                      return null;
                    },
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
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (taskId == null) {
                    // Add task and capture taskId
                    String newTaskId =
                        await addTask(title, className, description, dueTo);

                    // Show a confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Tugas berhasil ditambahkan dengan ID: $newTaskId')),
                    );
                  } else {
                    // Update task
                    updateTask(taskId, title, className, description, dueTo);
                    // Show a confirmation message for update
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tugas berhasil diedit')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(taskId == null ? 'Tambah' : 'Update'),
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
                      return Center(child: CircularProgressIndicator());
                    }

                    final tasks = snapshot.data!.docs;

                    if (tasks.isEmpty) {
                      return Center(
                        child: Text('Tidak ada tugas yang tersedia.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];

                        // Ambil due_to sebagai Timestamp dan ubah menjadi DateTime
                        Timestamp dueToTimestamp = task['due_to'];
                        DateTime dueTo = dueToTimestamp.toDate();

                        return Column(children: [
                          _buildContentCard(
                            task.id, // taskId
                            task['title'], // Judul Tugas
                            task['class'], // Kelas
                            task['description'], // Deskripsi
                            dueTo, // Tanggal jatuh tempo yang di-convert dari Timestamp
                          ),
                          SizedBox(
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
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 40.0), // Mengatur jarak dari atas
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
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 253, 240, 69),
      ),
    );
  }

  Widget _buildContentCard(String taskId, String title, String className,
      String description, DateTime dueTo) {
    String formattedDueTo = DateFormat('dd-MM-yyyy HH:mm').format(dueTo);

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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(className, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Due: $formattedDueTo', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Buka form untuk mengedit tugas
                showTaskForm(
                  taskId: taskId,
                  currentTitle: title,
                  currentClass: className,
                  currentDescription: description,
                  currentDueTo: dueTo,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
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
