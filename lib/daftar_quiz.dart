import 'package:flutter/material.dart';

class DaftarQuizPage extends StatelessWidget {
  final List<Map<String, String>> quizzes = [
    {
      'title': 'Mikroorganisme',
      'description': 'Quiz tentang Mikroorganisme.',
      'deadline': '10 Oktober 2024',
      'status': 'Ditutup',
    },
    {
      'title': 'Molekul',
      'description': 'Quiz mengenai Molekul.',
      'deadline': '12 Oktober 2024',
      'status': 'Dibuka',
    },
    {
      'title': 'Virus',
      'description': 'Quiz tentang Virus.',
      'deadline': '15 Oktober 2024',
      'status': 'Belum Dibuka',
    },
  ];

  DaftarQuizPage({super.key});

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
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Tampilkan alert dialog ketika tombol logout ditekan
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda Ingin Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Batal", tutup dialog
                          Navigator.of(context).pop();
                        },
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Jika memilih "Ya", lakukan logout dan redirect ke halaman login
                          Navigator.of(context)
                              .pop(); // Tutup dialog terlebih dahulu
                          Navigator.pushReplacementNamed(
                              context, '/login'); // Redirect ke login
                        },
                        child: const Text("Ya"),
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
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return QuizItem(
              title: quiz['title']!,
              description: quiz['description']!,
              deadline: quiz['deadline']!,
              status: quiz['status']!,
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

class QuizItem extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final String status;

  const QuizItem({super.key, 
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (status == 'Dibuka') {
          // Jika quiz dibuka, minta password untuk mengaksesnya
          _showPasswordDialog(context);
        } else if (status == 'Terkunci') {
          // Jika quiz terkunci, berikan informasi bahwa quiz terkunci
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Quiz "$title" Terkunci. Silakan coba lagi nanti.')),
          );
        } else if (status == 'Ditutup') {
          // Jika quiz ditutup, berikan informasi bahwa quiz telah ditutup
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "$title" Telah Ditutup.')),
          );
        } else {
          // Status default jika ada masalah
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status quiz tidak diketahui.')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left section: title, description, deadline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 8),
                  Text(
                    'Deadline: $deadline',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            // Right section: status
            Container(
              alignment: Alignment.bottomRight,
              child: Text(
                status == 'Dibuka'
                    ? 'Dibuka'
                    : (status == 'Ditutup' ? 'Ditutup' : 'Belum Dibuka'),
                style: TextStyle(
                  // Menentukan warna sesuai status
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menentukan warna berdasarkan status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dibuka':
        return Colors.green;
      case 'Belum Dibuka':
      case 'Terkunci': // Jika ada status terkunci
        return Colors.grey;
      case 'Ditutup':
        return Colors.red;
      default:
        return Colors.black; // Warna default jika status tidak diketahui
    }
  }

  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Here, you would normally check the password entered
                // For simplicity, we assume it's always correct
                if (passwordController.text == '1234') {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password benar. Quiz dibuka!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password salah.')),
                  );
                }
              },
              child: const Text('Start attempt'),
            ),
          ],
        );
      },
    );
  }
}
