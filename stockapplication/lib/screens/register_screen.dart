import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Define gradients
  final Gradient inputGradient = LinearGradient(
    colors: [
      Colors.blue.shade300,
      Colors.purple.shade300,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  final Gradient titleGradient = LinearGradient(
    colors: [
      Colors.blue.shade400,
      Colors.purple.shade400,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create your Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade400,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.purple.shade400),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Enhanced Header
                    Container(
                      margin: EdgeInsets.only(bottom: 48),
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => titleGradient.createShader(bounds),
                            child: Text(
                              'Get Started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Create your account to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form fields with gradient borders
                    Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          // Email Field
                          Container(
                            decoration: BoxDecoration(
                              gradient: inputGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100.withOpacity(0.5),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  labelStyle: TextStyle(color: Colors.grey[600]),
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.blue.shade300),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please enter your email';
                                  if (!value!.contains('@')) return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              gradient: inputGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.shade100.withOpacity(0.5),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                  labelStyle: TextStyle(color: Colors.grey[600]),
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.purple.shade300),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please enter a password';
                                  if ((value?.length ?? 0) < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Confirm Password Field
                          Container(
                            decoration: BoxDecoration(
                              gradient: inputGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100.withOpacity(0.5),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  labelStyle: TextStyle(color: Colors.grey[600]),
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.purple.shade300),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Please confirm your password';
                                  if (value != passwordController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 32),

                          // Enhanced Register Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: inputGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade100.withOpacity(0.5),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() => _isLoading = true);
                                  try {
                                    await Provider.of<AuthService>(context, listen: false)
                                        .register(emailController.text, passwordController.text);
                                    Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Registration Failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Enhanced Terms and Privacy Policy
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'By creating an account, you agree to our Terms of Service and Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                height: 1.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}