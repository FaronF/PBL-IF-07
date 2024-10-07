import 'package:flutter/material.dart';

class DaftarTugasPage extends StatelessWidget {
  DaftarTugasPage({super.key});
  final List<Map<String, String>> tasks = [
    {
      'title': 'Tugas Mikroorganisme',
      'description': 'Kumpulkan soal latihan halaman 20-25',
      'class': 'Kelas 11 MIPA 2',
      'deadline': '10 Oktober 2024',
    },
    {
      'title': 'Tugas Molekul',
      'description': 'Laporan praktikum mengenai molekul',
      'class': 'Kelas 12 MIPA 1',
      'deadline': '12 Oktober 2024',
    },
    {
      'title': 'Tugas Virus',
      'description': 'Kerjakan soal materin virus pada buku halaman 50-55',
      'class': 'Kelas 10 MIPA 3',
      'deadline': '15 Oktober 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'SMA IT ULIL ALBAB',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/edit_profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Tampilkan alert dialog ketika tombol logout ditekan
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Logout"),
                    content: Text("Apakah Anda Ingin Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Batal", tutup dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Ya", lakukan logout dan redirect ke halaman login
                          Navigator.of(context)
                              .pop(); // Tutup dialog terlebih dahulu
                          Navigator.pushReplacementNamed(
                              context, '/login'); // Redirect ke login
                        },
                        child: Text("Ya"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskItem(
              title: task['title']!,
              description: task['description']!,
              taskClass: task['class']!,
              deadline: task['deadline']!,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/pelajaran');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/edit_profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Pelajaran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

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
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Unggah Tugas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Silakan unggah file tugas untuk "$title"'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File berhasil diunggah!'),
                        ),
                      );
                    },
                    child: const Text('Pilih File'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
              ],
            );
          },
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
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Deadline: $deadline',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
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
