import 'package:flutter/material.dart';

import '../data/firebase_service/firebase_auth.dart';
import '../widgets/sizedbox_spacer.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;
  const LoginScreen(this.show, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  late FocusNode emailF = FocusNode();
  final passwordController = TextEditingController();
  late FocusNode passwordF = FocusNode();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailF = FocusNode();
    emailF.addListener(() {
      setState(() {});
    });
    passwordF = FocusNode();
    passwordF.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailF.dispose();
    passwordF.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBoxSpacer.h100w96,
              _loginScreenLogo,
              SizedBoxSpacer.h120,
              _CustomTextField(emailController, Icons.email, 'Email', emailF),
              SizedBoxSpacer.h15,
              _CustomTextField(
                  passwordController, Icons.lock, 'Password', passwordF),
              SizedBoxSpacer.h10,
              _forgotPassword,
              SizedBoxSpacer.h10,
              _loginButton,
              SizedBoxSpacer.h10,
              _signup,
            ],
          ),
        ],
      )),
    );
  }

  Widget get _signup => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Dont't have account?",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: widget.show,
              child: const Text(
                "Signup",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

  Widget get _loginButton => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: () async {
            try {
              await Authentication().login(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim());
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Login failed. Please check your email and password.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Log in',
              style: TextStyle(
                  fontSize: 23,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

  Widget get _forgotPassword => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          'Forgot your password?',
          style: TextStyle(
              fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      );

  Widget get _loginScreenLogo => Center(
        child: Image.asset('images/logo.jpg'),
      );

  // ignore: non_constant_identifier_names
  Widget _CustomTextField(TextEditingController controller, IconData icon,
      String type, FocusNode focusNode) {
    bool isPassword = type.toLowerCase() == 'password';
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          style: const TextStyle(fontSize: 18, color: Colors.black),
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
              hintText: type,
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus ? Colors.black : Colors.grey,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              )),
        ),
      ),
    );
  }
}
