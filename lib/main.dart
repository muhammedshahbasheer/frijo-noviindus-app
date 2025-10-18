import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/auth/presentation/auth_controller.dart';
import 'package:frijo_noviindus_app/features/auth/presentation/login_screen.dart';
import 'package:provider/provider.dart';

void main() async{WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (context) => AuthController(),)],child: const MyApp(),));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,home: LoginScreen(),);
  }
}
