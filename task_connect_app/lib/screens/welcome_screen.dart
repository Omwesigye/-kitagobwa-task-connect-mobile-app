import 'package:flutter/material.dart';
import 'package:task_connect_app/screens/signin_screen.dart';
import 'package:task_connect_app/screens/signup_screen.dart';
import 'package:task_connect_app/util/button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC), // light sky blue
              Color.fromARGB(255, 170, 198, 218), // softer fade
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IMAGE ------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  'assets/images/welcome.png',
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              // TITLE + SUBTITLE -------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome to Task Connect\n\n",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: "services next to your door step.",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // BUTTONS ----------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: WelcomeButton(
                        buttonText: "Sign In",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                          );
                        },
                        color: Colors.white,
                        textColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: "Sign Up",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        color: Colors.black54,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
