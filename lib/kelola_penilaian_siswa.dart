import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Tasks {
  final String taskId;
  final String title;

  Tasks({
    required this.taskId,
    required this.title,
  });

  factory Tasks.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Tasks(
      taskId: doc.id,
      title: data['title'] ?? '',
    );
  }
}

class Submission {
  final String studentId;
  final String taskId;
  final String fileUrl;
  final DateTime submissionDate;

  Submission({
    required this.studentId,
    required this.taskId,
    required this.fileUrl,
    required this.submissionDate,
  });

  factory Submission.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Submission(
      studentId: data['studentId'] ?? '',
      taskId: data['taskId'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      submissionDate: (data['submissionDate'] as Timestamp).toDate(),
    );
  }
}

class Student {
  final String studentId;
  final String name;

  Student({
    required this.studentId,
    required this.name,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Student(
      studentId: doc.id,
      name: data['nama'] ?? '',
    );
  }
}

class KelolaPenilaianSiswa extends StatefulWidget {
  const KelolaPenilaianSiswa({super.key});

  @override
  _KelolaPenilaianSiswaState createState() => _KelolaPenilaianSiswaState();
}

class _KelolaPenilaianSiswaState extends State<KelolaPenilaianSiswa> {
  final int _selectedIndex = 1;

  List<Tasks> tasks = [];
  List<Submission> submissions = [];
  List<Submission> filteredSubmissions =
      []; // To hold submissions for selected task
  String selectedtaskId = ''; // To store selected task ID

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Tasks').get();
    setState(() {
      tasks = snapshot.docs.map((doc) => Tasks.fromFirestore(doc)).toList();
    });
  }

  void fetchSubmissions(String taskId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('submissions')
        .where('taskId', isEqualTo: taskId)
        .get();
    setState(() {
      filteredSubmissions =
          snapshot.docs.map((doc) => Submission.fromFirestore(doc)).toList();
      selectedtaskId = taskId; // Update selected task ID
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionsPage(taskId: taskId),
      ),
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
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 240, 69),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Kelola Penilaian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return buildTaskCard(context, tasks[index]);
                  },
                ),
              ),
            ],
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
    );
  }

  Widget buildTaskCard(BuildContext context, Tasks task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 8, // Menambahkan bayangan untuk efek kedalaman
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Membuat sudut card lebih bulat
      ),
      color: Colors.blue[300], // Mengatur warna latar belakang card
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16), // Menambahkan padding di dalam ListTile
        title: Text(
          task.title,
          style: const TextStyle(
            color: Colors.white, // Mengubah warna teks menjadi putih
            fontSize: 18, // Ukuran font yang lebih besar
            fontWeight: FontWeight.bold, // Menebalkan teks
          ),
        ),
        trailing: const Icon(
          Icons
              .arrow_forward, // Menambahkan ikon panah untuk menunjukkan interaksi
          color: Colors.white, // Mengubah warna ikon menjadi putih
        ),
        onTap: () {
          fetchSubmissions(
              task.taskId); // Fetch submissions for the selected task
        },
      ),
    );
  }
}

class SubmissionsPage extends StatelessWidget {
  final String taskId;

  const SubmissionsPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions for Task $taskId'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('Students')
            .get(), // Mengambil semua dokumen dari koleksi Students
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No submissions found.'));
          }

          // Loop through each student document
          final studentDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: studentDocs.length,
            itemBuilder: (context, index) {
              final studentDoc = studentDocs[index];

              // Mengambil reference ke sub-koleksi submissions
              CollectionReference<Map<String, dynamic>> submissionsRef =
                  studentDoc.reference.collection('submissions');

              // Mengambil submissions berdasarkan taskId
              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: submissionsRef.where('taskId', isEqualTo: taskId).get(),
                builder: (context, submissionSnapshot) {
                  if (submissionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (submissionSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${submissionSnapshot.error}'));
                  }

                  final submissionDocs = submissionSnapshot.data?.docs ?? [];
                  final fileUrls = submissionDocs
                      .map((doc) => doc.data()['fileUrl'])
                      .toList();

                  // Display student name and their submissions
                  return ListTile(
                    title: Text(studentDoc.data()['nama'] ?? 'Unknown Student'),
                    subtitle: submissionDocs.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < submissionDocs.length; i++)
                                SizedBox(
                                  width: double
                                      .infinity, // Make it take the full width
                                  child: Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            // Menggunakan Expanded di sini
                                            child: Row(
                                              children: [
                                                const Icon(Icons.picture_as_pdf,
                                                    color:
                                                        Colors.red), // PDF icon
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    submissionDocs[i]
                                                            ['taskTitle'] ??
                                                        'File ${i + 1}', // Menampilkan taskTitle
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow: TextOverflow
                                                        .ellipsis, // Menambahkan overflow
                                                    maxLines:
                                                        1, // Membatasi jumlah baris
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.file_download),
                                            onPressed: () async {
                                              // Launch the URL as a download
                                              await UrlLauncher.launch(
                                                fileUrls[i],
                                                headers: <String, String>{
                                                  'content-type':
                                                      'application/pdf', // or 'application/octet-stream'
                                                  'content-disposition':
                                                      'attachment',
                                                },
                                              );
                                            },
                                          ),
                                          // Add a TextField for grading
                                          SizedBox(
                                            width: 60,
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                labelText: 'Nilai',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onSubmitted: (value) async {
                                                // Save the grade to Firestore
                                                if (submissionDocs.isNotEmpty) {
                                                  await submissionsRef
                                                      .doc(submissionDocs[i].id)
                                                      .update({'grade': value});
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Grade saved!')),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : const Text('No submissions found.'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
