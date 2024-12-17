import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/edit_profile_page.dart';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const CustomDrawer({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: userData == null
          ? SizedBox() // Return an empty widget if userData is null
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0), // Added top padding
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: userData?['photoURL'] != null
                          ? ClipOval(
                        child: Image.network(
                          userData!['photoURL'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData?['displayName'] ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    userData?['email'] ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.access_time, color: Colors.grey[700]),
                      title: Text(
                        'Last Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        userData?['lastLoginAt'] != null
                            ? DateTime.parse(userData!['lastLoginAt'])
                            .toLocal()
                            .toString()
                            .split('.')[0]
                            : 'N/A',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.account_circle, color: Colors.grey[700]),
                      title: Text(
                        'User ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        userData?['uid'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Divider(color: Colors.grey),
                    ListTile(
                      leading: Icon(Icons.logout, color: Theme.of(context).primaryColor),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () async {
                        await Provider.of<AuthService>(context, listen: false).logout();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                      title: Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
