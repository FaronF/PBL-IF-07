import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'profile_page.dart';

class DaftarTugasPage extends StatelessWidget {
  DaftarTugasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -30,
                  left: 15,
                  width: 200,
                  height: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo-ulilalbab.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 25,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Konten Utama
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Tasks').snapshots(),
                builder: (context, snapshot) {
                  print("Connection State: ${snapshot.connectionState}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("Snapshot Error: ${snapshot.error}");
                    return const Center(
                      child: Text('Error fetching tasks'),
                    );
                  }

                  if (!snapshot.hasData) {
                    print("No Data in Snapshot");
                    return const Center(child: Text('No tasks available'));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    print("No Documents in Collection");
                    return const Center(child: Text('No tasks available'));
                  }

                  // Check if data is being received correctly
                  print("Snapshot Data: ${snapshot.data!.docs}");

                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index].data() as Map<String, dynamic>;

                      final String title = task['title'] ?? 'No Title';
                      final String description =
                          task['description'] ?? 'No Description';
                      final String taskClass = task['class'] ?? 'No Class';
                      final Timestamp? dueToTimestamp =
                          task['due_to'] as Timestamp?;
                      final String deadline = dueToTimestamp != null
                          ? DateFormat('dd-mm-yyyy HH:mm')
                              .format(dueToTimestamp.toDate())
                          : 'No Due Date';

                      final String taskId =
                          tasks[index].id; // Get the document ID as taskId

                      return TaskItem(
                        title: title,
                        description: description,
                        taskClass: taskClass,
                        deadline: deadline,
                        taskId: taskId, // Pass the taskId here
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/studentpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/materi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/quiz');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Tugas',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 234, 0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}

// Define TaskItem class below DaftarTugasPage
class TaskItem extends StatelessWidget {
  final String taskId;
  final String title;
  final String description;
  final String taskClass;
  final String deadline;

  const TaskItem({
    required this.taskId,
    required this.title,
    required this.description,
    required this.taskClass,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfUploadScreen(
              taskTitle: title,
              taskId: taskId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 216, 212, 212),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelas: $taskClass',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4), // Jarak antara kelas dan deadline
            Text(
              'Due to: $deadline',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfUploadScreen extends StatefulWidget {
  final String taskTitle;
  final String taskId;

  PdfUploadScreen({required this.taskTitle, required this.taskId});

  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  String? uploadedFileURL;
  String? uploadedFileName;
  String? selectedFileName;
  Uint8List? selectedFileBytes;

  Future<void> selectPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        selectedFileName = file.name;
        selectedFileBytes = file.bytes;
      });
    }
  }

  Future<void> uploadPdf() async {
    if (selectedFileBytes != null) {
      try {
        String filePath =
            'submissions/${FirebaseAuth.instance.currentUser?.uid}/${widget.taskTitle}/$selectedFileName';
        UploadTask uploadTask =
            FirebaseStorage.instance.ref(filePath).putData(selectedFileBytes!);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        String? studentId = FirebaseAuth.instance.currentUser?.uid;

        if (studentId != null) {
          DocumentReference studentDoc =
              FirebaseFirestore.instance.collection('Students').doc(studentId);
          CollectionReference submissions =
              studentDoc.collection('submissions');

          // Add taskId to the submission data
          await submissions.add({
            'taskTitle': widget.taskTitle,
            'submissionDate': Timestamp.now(),
            'fileUrl': downloadUrl,
            'status': 'submitted',
            'taskId': widget.taskId, // Include the taskId here
          });

          setState(() {
            uploadedFileURL = downloadUrl;
            uploadedFileName = selectedFileName;
            selectedFileName = null;
            selectedFileBytes = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User  is not authenticated.')),
          );
        }
      } catch (e) {
        print("Error uploading file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file first.')),
      );
    }
  }

  Future<void> deletePdf(String fileUrl, String documentId) async {
    if (fileUrl.isNotEmpty) {
      try {
        // Get reference to the file to delete
        await FirebaseStorage.instance.refFromURL(fileUrl).delete();

        // Delete the corresponding Firestore document
        String? studentId = FirebaseAuth.instance.currentUser?.uid;
        if (studentId != null) {
          DocumentReference studentDoc =
              FirebaseFirestore.instance.collection('Students').doc(studentId);
          await studentDoc.collection('submissions').doc(documentId).delete();
        }

        // Reset variables after deletion
        setState(() {
          uploadedFileURL = null;
          uploadedFileName = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission deleted successfully!')),
        );
      } catch (e) {
        print("Error deleting file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file uploaded to delete.')),
      );
    }
  }

  void openPdf(String url) async {
    await OpenFile.open(url);
  }

  @override
  Widget build(BuildContext context) {
    String? studentId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the user is authenticated
    if (studentId == null) {
      return Center(child: Text('User  is not authenticated. Please log in.'));
    }

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
              // Konten utama
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Check for existing submissions
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Students')
                            .doc(studentId)
                            .collection('submissions')
                            .where('taskId', isEqualTo: widget.taskId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Column(
                              children: [
                                // Upload options if no submission exists
                                selectedFileName != null
                                    ? Column(
                                        children: [
                                          Text(
                                            'File dipilih: $selectedFileName',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            onPressed: uploadPdf,
                                            icon: Icon(Icons.send),
                                            label: Text(
                                              'Kirim',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24, vertical: 12),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 255, 251, 40),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: selectPdf,
                                        icon: Icon(
                                          Icons.upload_file,
                                          color: Colors
                                              .black, // Mengubah warna ikon menjadi hitam
                                        ),
                                        label: Text(
                                          'Pilih PDF untuk diunggah',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors
                                                .black, // Mengubah warna teks menjadi hitam
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                          backgroundColor: Colors.blue[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                              ],
                            );
                          } else {
                            // If a submission exists, show the uploaded file info
                            var submission = snapshot.data!.docs.first;
                            String documentId =
                                submission.id; // Get the document ID
                            String fileUrl = submission['fileUrl'];
                            Timestamp submissionDate =
                                submission['submissionDate'];
                            String status = submission['status'];

                            return Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'File yang diunggah: ${submission['taskTitle']}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Dikirim pada: ${submissionDate.toDate().toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Status: $status',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () => openPdf(fileUrl),
                                      icon: Icon(
                                        Icons.open_in_new,
                                        color: Colors
                                            .black, // Mengubah warna ikon menjadi hitam
                                      ),
                                      label: Text(
                                        'Buka File PDF',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 251, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          deletePdf(fileUrl, documentId),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors
                                            .black, // Mengubah warna ikon menjadi hitam
                                      ),
                                      label: Text(
                                        'Hapus File',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        backgroundColor: Colors.red[500],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/studentpage');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/materi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/quiz');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Tugas',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 234, 0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}
