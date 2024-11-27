import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahPengajarPage extends StatefulWidget {
  const TambahPengajarPage({super.key});

  @override
  State<TambahPengajarPage> createState() => _TambahPengajarPageState();
}

class _TambahPengajarPageState extends State<TambahPengajarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> tambahPengajar() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('teachers').add({
          'nama': namaController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajar berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan pengajar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengajar')),
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
                  decoration: const InputDecoration(labelText: 'Nama Guru'),
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
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: tambahPengajar,
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