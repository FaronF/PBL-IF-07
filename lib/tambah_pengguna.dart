import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahPenggunaPage extends StatefulWidget {
  const TambahPenggunaPage({super.key});

  @override
  State<TambahPenggunaPage> createState() => _TambahPenggunaPageState();
}

class _TambahPenggunaPageState extends State<TambahPenggunaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kelasController = TextEditingController();
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String gender = 'Laki-laki';
 
  Future<void> tambahPengguna() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('students').add({
          'nama': namaController.text.trim(),
          'email': emailController.text.trim(),
          'kelas': kelasController.text.trim(),
          'nisn': nisnController.text.trim(),
          'password': passwordController.text.trim(),
          'gender': gender,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pengguna: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Email tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: kelasController,
                  decoration: const InputDecoration(labelText: 'Kelas'),
                  validator: (value) =>
                      value!.isEmpty ? 'Kelas tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nisnController,
                  decoration: const InputDecoration(labelText: 'NISN'),
                  validator: (value) =>
                      value!.isEmpty ? 'NISN tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        value: 'Laki-laki',
                        groupValue: gender,
                        title: const Text('Laki-laki'),
                        onChanged: (value) {
                          setState(() => gender = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        value: 'Perempuan',
                        groupValue: gender,
                        title: const Text('Perempuan'),
                        onChanged: (value) {
                          setState(() => gender = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: tambahPengguna,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}