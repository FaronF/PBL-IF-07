import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPengajarPage extends StatefulWidget {
  final String pengajarId; // ID dokumen pengajar yang akan diedit

  const EditPengajarPage({super.key, required this.pengajarId});

  @override
  State<EditPengajarPage> createState() => _EditPengajarPageState();
}

class _EditPengajarPageState extends State<EditPengajarPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengajarData();
  }

  Future<void> fetchPengajarData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(widget.pengajarId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        namaController.text = data['nama'] ?? '';
        emailController.text = data['email'] ?? '';
        passwordController.text = data['password'] ?? '';
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data pengajar: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updatePengajar() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(widget.pengajarId)
            .update({
          'nama': namaController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pengajar berhasil diperbarui')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data pengajar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengajar')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration:
                            const InputDecoration(labelText: 'Nama Guru'),
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
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? 'Password tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updatePengajar,
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