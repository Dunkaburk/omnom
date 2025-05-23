import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omnom/src/features/auth/data/auth_repository.dart';
import 'package:omnom/src/routing/app_router.dart'; // To access goRouterProvider for redirection

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Predefined users for easy login - consider a dropdown or other UI for selection
  final Map<String, String> _predefinedUsers = {
    'omnom_louise@gmail.com': 'Louise',
    'omnom_jonathan@gmail.com': 'Jonathan',
  };
  String? _selectedUserEmail;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedUserEmail == null && _emailController.text.isEmpty) {
        setState(() {
            _errorMessage = 'Please select a user or enter an email.';
        });
        return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final emailToUse = _selectedUserEmail ?? _emailController.text;

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithEmailAndPassword(
        emailToUse,
        _passwordController.text,
      );
      // Navigation to home will be handled by the router based on auth state
      // No need to explicitly navigate here if GoRouter handles redirection
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

 @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Culinary Couple',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 40),
                // Optional: Dropdown to select predefined user
                if (_predefinedUsers.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select User (Optional)',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedUserEmail,
                    hint: const Text('Or type email below'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedUserEmail = newValue;
                        if (newValue != null) {
                          _emailController.clear(); // Clear manual email if user selected
                        }
                      });
                    },
                    items: _predefinedUsers.entries.map<DropdownMenuItem<String>>((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value), // Display name
                      );
                    }).toList(),
                  ),
                if (_predefinedUsers.isNotEmpty) const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Your email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (_selectedUserEmail == null && (value == null || value.isEmpty)) {
                      return 'Please enter your email';
                    }
                    if (_selectedUserEmail == null && !value!.contains('@')) {
                        return 'Please enter a valid email';
                    }
                    return null;
                  },
                  enabled: _selectedUserEmail == null, // Disable if a user is selected from dropdown
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Your Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        child: const Text('Enter Our Culinary World', style: TextStyle(color: Colors.white)),
                      ),
                const SizedBox(height: 16),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 