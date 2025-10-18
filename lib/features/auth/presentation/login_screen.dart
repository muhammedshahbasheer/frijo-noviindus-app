import 'package:flutter/material.dart';
import 'package:frijo_noviindus_app/features/auth/presentation/auth_controller.dart';
import 'package:frijo_noviindus_app/features/home/presentation/homescreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phonecontroller = TextEditingController();
  String Selectedcode = "+91";
  final List<String> countryCode = ["+91", "+971", "+974"];
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Text(
            "Enter Your\nMobile Number",
            style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white),
          ),
          Text(
            "orem ipsum dolor sit amet consectetur. Porta at id hac \n vitae. Et tortor at vehicula euismod mi viverra.",
            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: Selectedcode,
                items: countryCode.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(
                      code,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    Selectedcode = value!;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: phonecontroller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: "enter phone number"),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: context.read<AuthController>().isLoading
                ? null
                : () async {
                    final phone = phonecontroller.text.trim();
                    if (phone.isEmpty || phone.length < 9) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("please enter a valid number"),
                        ),
                      );
                      return;
                    }
                    final success = await context.read<AuthController>().login(
                      countrycode: Selectedcode,
                      phone: phone,
                    );
                    if (success && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Homescreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120,50,)),
            child: Consumer<AuthController>(
              builder: (context, auth, _) {
                return auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Login");
              },
            ),
          ),
        ],
      ),
    );
  }
}
