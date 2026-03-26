import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'inbox_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controllers grab the text the user types into the text fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. An instance of the engine we built in the last step
  final AuthService _authService = AuthService();

  // 3. A variable to track if we should show a loading spinner
  bool _isLoading = false;

  // 4. The function that runs when the user taps "Login"
  void _attemptLogin() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true; // Turn on the loading spinner
    });

    // Send the data to Python!
    final success = await _authService.login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );

    // Python responded! Turn off the spinner.
    setState(() {
      _isLoading = false;
    });

    // Did Python give us a 200 OK or a 401 Unauthorized?
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful! VIP Pass Secured.')),
      );

      // Navigate to the Inbox!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InboxScreen()),
      );
      // TODO: Navigate to the Inbox/Chat Screen here!
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Check your credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 40),

              // Phone Number Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true, // Hides the text (bullets)
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button (or Loading Spinner)
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _attemptLogin,
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Register Button (Just a placeholder for now)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Registration Screen
                  print("Navigate to register");
                },
                child: const Text("Don't have an account? Register here."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
