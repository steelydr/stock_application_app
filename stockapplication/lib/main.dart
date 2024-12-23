import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive and GraphQL cache
  await Hive.initFlutter();
  await initHiveForFlutter();

  // Open the GraphQL cache box
  await Hive.openBox('graphql');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create GraphQL client with Hive cache
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(
        'http://192.168.40.86/graphql/',
        defaultHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: MaterialApp(
          home: AuthWrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (!authService.initialized) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authService.isUserLoggedIn()) {
          return HomeScreen();
        }

        return LoginScreen();
      },
    );
  }
}