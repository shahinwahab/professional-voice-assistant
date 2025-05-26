import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';
import 'package:pro_voice_assistant/pages/signin_page.dart';
import 'package:pro_voice_assistant/services/auth_service.dart';
import 'package:pro_voice_assistant/widgets/custom_button.dart';
import 'package:pro_voice_assistant/widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  final AuthService _authService = AuthService();

  // Default country value
  String _selectedCountry = 'Iraq';

  @override
  void initState() {
    super.initState();
    _countryController.text = _selectedCountry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Check if password meets requirements
  bool _isPasswordValid(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // At least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // At least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // At least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // At least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  // Validate Iraqi phone number
  String? _validateIraqiPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }

    // Remove any whitespace
    String phoneNumber = value.trim().replaceAll(RegExp(r'\s+'), '');

    // Check if phone starts with 07xx (local format) or +964
    bool isValidIraqiFormat = false;

    if (phoneNumber.startsWith('07') && phoneNumber.length == 11) {
      // Local format: 07xx xxxxxxx (11 digits)
      isValidIraqiFormat = true;
    } else if ((phoneNumber.startsWith('+964') && phoneNumber.length == 13) ||
        (phoneNumber.startsWith('00964') && phoneNumber.length == 14)) {
      // International format: +964 xxx xxxxxxx
      isValidIraqiFormat = true;
    }

    if (!isValidIraqiFormat) {
      return 'Please enter a valid Iraqi phone number (07xx-xxxxxxx or +964-xxx-xxxxxxx)';
    }

    // Check that it only contains digits (and possibly the + sign)
    if (!RegExp(r'^(\+|00)?[0-9]+$').hasMatch(phoneNumber)) {
      return 'Phone number should only contain digits';
    }

    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        country: _countryController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _phoneNumberController,
                  hintText: 'Phone Number (07xx-xxxxxxx)',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                  validator: _validateIraqiPhoneNumber,
                  // Only allow numbers, +, and spaces
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                  ],
                ),

                // Country field with default value
                CustomTextField(
                  controller: _countryController,
                  hintText: 'Country',
                  prefixIcon:
                      const Icon(Icons.location_on, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                  readOnly:
                      true, // Make it read-only since we're defaulting to Iraq
                ),

                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password (8+ characters)',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isPasswordValid(value)) {
                      return 'Password must contain at least 8 characters including uppercase, lowercase, numbers, and special characters';
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      softWrap: true,
                    ),
                  ),

                const SizedBox(height: 20),

                CustomButton(
                  text: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _signUp,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Pallete.featureBoxColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
