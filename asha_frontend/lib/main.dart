import 'package:flutter/material.dart';
import 'package:asha_frontend/auth/pages/login_page.dart';
import 'package:asha_frontend/auth/providers/auth_provider.dart';
import 'package:asha_frontend/features/home/ui/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Wrap the entire application in a ChangeNotifierProvider.
    // This creates an instance of AuthProvider that can be accessed by any widget
    // down the tree.
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASHA Health Data Collector',
      theme: ThemeData(
        primaryColor: const Color(0xFF2A5A9E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A5A9E),
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), // We use a wrapper to decide which page to show.
    );
  }
}

/// A wrapper widget that listens to the authentication state and directs
/// the user to the appropriate page.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes in AuthProvider.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If the provider is still trying to load the token from storage,
        // show a loading screen.
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the user is authenticated (token exists), show the HomePage.
        if (authProvider.isAuthenticated) {
          return const HomePage();
        }

        // Otherwise, the user is not authenticated, so show the LoginPage.
        return const LoginPage();
      },
    );
  }
}



