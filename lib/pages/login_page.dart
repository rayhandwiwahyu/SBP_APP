import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isHiddenPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 30,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: const Row(
                children: [

                  Icon(
                    Icons.arrow_back,
                    color: Color(0xFF004B6B),
                    size: 30,
                  ),

                  SizedBox(width: 15),

                  Text(
                    "Sistem Pakar Bansos",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B6B),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                children: [

                  const SizedBox(height: 30),

                  // TITLE
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004B6B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Masuk untuk melanjutkan ke sistem pakar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // USERNAME LABEL
                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      "Username atau Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // USERNAME FIELD
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Masukkan username",

                      prefixIcon: const Icon(Icons.person_outline),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PASSWORD LABEL
                  const Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PASSWORD FIELD
                  TextField(
                    obscureText: isHiddenPassword,

                    decoration: InputDecoration(
                      hintText: "Masukkan password",

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        onPressed: () {

                          setState(() {
                            isHiddenPassword =
                                !isHiddenPassword;
                          });

                        },

                        icon: Icon(
                          isHiddenPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),

                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // FORGOT PASSWORD
                  const Align(
                    alignment: Alignment.centerRight,

                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Color(0xFF004B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,

                    child: ElevatedButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardPage(),
                          ),
                        );

                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008F5D),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        elevation: 5,
                      ),

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // REGISTER
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),

                      children: [

                        TextSpan(
                          text: "Belum punya akun? ",
                        ),

                        TextSpan(
                          text: "Daftar Sekarang",
                          style: TextStyle(
                            color: Color(0xFF004B6B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),

                    child: Image.network(
                      "https://cdn-icons-png.flaticon.com/512/4140/4140048.png",
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}