import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method to handle login action
  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Simple validation
    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and Password cannot be empty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade300,
              Colors.lightBlue.shade500,
              Colors.lightBlue.shade700,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Replace with your logo path
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 40),
                _buildTextField(_emailController, 'Email', Icons.email, false),
                const SizedBox(height: 16),
                _buildTextField(
                    _passwordController, 'Password', Icons.lock, true),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.lightBlue.shade700,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to the registration page
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType:
          label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
    );
  }
}
