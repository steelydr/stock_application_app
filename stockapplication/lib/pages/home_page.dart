import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../screens/tabs_section.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userService = await UserService.getInstance();
    setState(() {
      userData = userService.getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 5),
              Text(
                userData?['email'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 5),
              Divider(color: Colors.grey[500]),
            ],
          ),
        ),
        Expanded(
          child: TabsSection(userData: userData),
        ),
      ],
    );
  }
}
