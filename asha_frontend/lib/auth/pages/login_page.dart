import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:asha_frontend/auth/providers/auth_provider.dart';
import 'package:asha_frontend/core/services/api_service.dart';
import 'package:provider/provider.dart';

const String _appBarTitle = 'ASHA Health Data Collector';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Create an instance of the ApiService
  final ApiService _apiService = ApiService();

  // A state variable to manage the loading indicator
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// The new login function with real authentication logic.
  Future<void> _login() async {
    // Prevent multiple login attempts while one is in progress
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the login method from our ApiService
      final response = await _apiService.login(
        _mobileController.text,
        _passwordController.text,
      );

      // It's good practice to check if the widget is still mounted before using its context
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        // --- SUCCESSFUL LOGIN ---
        final data = jsonDecode(response.body);
        // IMPORTANT: Adjust the key 'token' based on your actual API response
        final token = data['token'];

        // Use the AuthProvider to save the token and update the app state.
        // 'listen: false' is crucial here because we are inside a function.
        await Provider.of<AuthProvider>(context, listen: false).login(token);

        // The AuthWrapper in main.dart will automatically handle navigation
        // to the HomePage because the isAuthenticated state has changed.
        // So, we don't need a Navigator.push here anymore.

      } else {
        // --- FAILED LOGIN ---
        final errorData = jsonDecode(response.body);
        // Adjust 'message' key if your API sends a different error key
        final errorMessage = errorData['message'] ?? 'Login failed. Please check your credentials.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // --- NETWORK OR OTHER ERRORS ---
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      // Ensure the loading indicator is turned off, even if an error occurs
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5A9E),
        title: const Text(_appBarTitle, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_off, color: Colors.white),
            onPressed: () { /* TODO: Handle wifi off action */ },
          ),
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: () { /* TODO: Handle translate action */ },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Enter your details to proceed.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 30),
                    const Text("Mobile Number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(
                        hintText: 'Enter 10-digit number',
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_android),
                              SizedBox(width: 8),
                              Text('+91', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF2A5A9E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        // ... your signup gesture detector
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
