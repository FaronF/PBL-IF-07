import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                      final String deadline = task['due_to'] ?? 'No Due Date';

                      return TaskItem(
                        title: title,
                        description: description,
                        taskClass: taskClass,
                        deadline: deadline,
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
            Navigator.pushReplacementNamed(context, '/dashboard');
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
  final String title;
  final String description;
  final String taskClass;
  final String deadline;

  const TaskItem({
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
            builder: (context) => PdfUploadScreen(taskTitle: title),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kelas: $taskClass',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Flexible(
                  child: Text(
                    'Due to: $deadline',
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PdfUploadScreen extends StatefulWidget {
  final String taskTitle;

  PdfUploadScreen({required this.taskTitle});

  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  String? uploadedFileURL;
  String? uploadedFileName;
  String? selectedFileName;
  Uint8List?
      selectedFileBytes; // Variabel untuk menyimpan bytes file yang dipilih

  Future<void> selectPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      // Set nama file dan bytes yang dipilih
      setState(() {
        selectedFileName = file.name; // Simpan nama file ke variabel
        selectedFileBytes = file.bytes; // Simpan bytes file ke variabel
      });
    }
  }

  Future<void> uploadPdf() async {
    if (selectedFileBytes != null) {
      // Pastikan ada file yang dipilih
      try {
        // Upload file ke Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('pdfs/$selectedFileName')
            .putData(selectedFileBytes!); // Gunakan bytes yang sudah disimpan

        TaskSnapshot taskSnapshot = await uploadTask;

        // Dapatkan URL dari file yang diunggah
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          uploadedFileURL = downloadUrl; // Simpan URL file yang diunggah
          uploadedFileName = selectedFileName; // Simpan nama file yang diunggah
          selectedFileName = null; // Reset nama file yang dipilih
          selectedFileBytes = null; // Reset bytes setelah diunggah
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      } catch (e) {
        print("Error uploading file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } else {
      // Jika tidak ada file yang dipilih, berikan notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih file terlebih dahulu.')),
      );
    }
  }

  Future<void> deletePdf() async {
    if (uploadedFileURL != null) {
      try {
        // Ambil referensi ke file yang akan dihapus
        await FirebaseStorage.instance.refFromURL(uploadedFileURL!).delete();

        // Reset variabel setelah dihapus
        setState(() {
          uploadedFileURL = null;
          uploadedFileName = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File deleted successfully!')),
        );
      } catch (e) {
        print("Error deleting file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada file yang diunggah untuk dihapus.')),
      );
    }
  }

  void openPdf(String url) async {
    await OpenFile.open(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unggah PDF: ${widget.taskTitle}',
            style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.amber[600],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jika ada URL yang diunggah, tampilkan informasi file
              uploadedFileURL != null
                  ? Card(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'File yang diunggah: $uploadedFileName',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.picture_as_pdf,
                                    color: Colors.red, size: 30),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Tombol untuk membuka file PDF yang diunggah
                            ElevatedButton.icon(
                              onPressed: () => openPdf(uploadedFileURL!),
                              icon: Icon(Icons.open_in_new),
                              label: Text(
                                'Buka File PDF',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 251, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Tombol untuk menghapus file PDF yang diunggah
                            ElevatedButton.icon(
                              onPressed: deletePdf,
                              icon: Icon(Icons.delete),
                              label: Text(
                                'Hapus File PDF',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                backgroundColor: Colors.red[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Tombol Pilih PDF
                        ElevatedButton.icon(
                          onPressed: selectPdf, // Fungsi untuk memilih file PDF
                          icon: Icon(Icons.upload_file),
                          label: Text(
                            'Pilih PDF untuk diunggah',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            backgroundColor: Colors.amber[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Menampilkan nama file yang dipilih
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
                                  // Tombol Kirim untuk mengunggah PDF ke Firebase
                                  ElevatedButton.icon(
                                    onPressed:
                                        uploadPdf, // Fungsi untuk mengunggah file ke Firebase
                                    icon: Icon(Icons.send),
                                    label: Text(
                                      'Kirim',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 251, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Belum ada file yang dipilih',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
