import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  // Enhanced Welcome Back Text with Gradient and Shadow
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => titleGradient.createShader(bounds),
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                  ),
                  SizedBox(height: 12),
                  // Enhanced Subtitle
                  Center(
                    child: Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 48),
                  // Enhanced Email Field
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
                  // Enhanced Password Field
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
                          if (value?.isEmpty ?? true) return 'Please enter your password';
                          if ((value?.length ?? 0) < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Enhanced Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple.shade300,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Enhanced Login Button
                  Container(
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
                                .login(emailController.text, passwordController.text);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Login Failed: $e'),
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
                          'Login',
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
                  SizedBox(height: 32),
                  // Enhanced Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.grey[300]!, Colors.transparent],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.grey[300]!, Colors.transparent],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Enhanced Google Sign In Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.g_mobiledata, size: 24, color: Colors.blue.shade400);
                        },
                      ),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() => _isLoading = true);
                        try {
                          await Provider.of<AuthService>(context, listen: false)
                              .signInWithGoogle();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-In Failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 32),
                  // Enhanced Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.purple.shade400,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}