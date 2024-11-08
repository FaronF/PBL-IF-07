import 'package:flutter/material.dart';

class KelolaQuizSiswa extends StatefulWidget {
  @override
  _KelolaQuizSiswaState createState() => _KelolaQuizSiswaState();
}

class _KelolaQuizSiswaState extends State<KelolaQuizSiswa> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/teacherpage');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/kelolatugas');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/kelolamateri');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/daftarsiswa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(50),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Kelola Quiz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                QuizCard(
                  title: 'Genetika',
                  kelas: '10 MIPA C',
                  date: 'Selasa 15 September',
                  time: '13.00–14.30',
                  status: 'Dibuka',
                ),
                QuizCard(
                  title: 'Virus',
                  kelas: '10 MIPA D',
                  date: 'Kamis 12 Agustus',
                  time: '09.45–12.00',
                  status: 'Selesai',
                ),
                QuizCard(
                  title: 'Mutasi',
                  kelas: '10 MIPA B',
                  date: 'Senin 27 Agustus',
                  time: '10.00–12.00',
                  status: 'Selesai',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete),
                  color: Colors.blue,
                  iconSize: 40,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  color: Colors.blue,
                  iconSize: 40,
                ),
              ],
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
            icon: Icon(Icons.list_alt_rounded),
            label: 'Manage Tasks',
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
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 253, 240, 69),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final String title;
  final String kelas;
  final String date;
  final String time;
  final String status;

  QuizCard({
    required this.title,
    required this.kelas,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                kelas,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            children: [
              if (status == 'Dibuka')
                Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
