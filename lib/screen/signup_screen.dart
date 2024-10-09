// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:io';

import 'package:flutter/material.dart';

import '../data/firebase_service/firebase_auth.dart';
import '../util/exeption.dart';
import '../util/imagepicker.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback show;
  const SignUpScreen(this.show, {super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  late FocusNode emailF = FocusNode();
  late FocusNode usernameF = FocusNode();
  late FocusNode bioF = FocusNode();
  late FocusNode passwordF = FocusNode();
  late FocusNode passwordConfirmF = FocusNode();
  File? _imageFile;

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    emailF = FocusNode();
    emailF.addListener(() {
      setState(() {});
    });

    usernameF = FocusNode();
    usernameF.addListener(() {
      setState(() {});
    });

    bioF = FocusNode();
    bioF.addListener(() {
      setState(() {});
    });

    passwordF = FocusNode();
    passwordF.addListener(() {
      setState(() {});
    });

    passwordConfirmF = FocusNode();
    passwordConfirmF.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    emailF.dispose();
    usernameF.dispose();
    bioF.dispose();
    passwordF.dispose();
    passwordConfirmF.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SignUpScreenLogo,
              SizedBoxSpacer.h60,
              _choiceProfilePictureWidget,
              SizedBoxSpacer.h50,
              _CustomTextField(emailController, Icons.email, 'Email', emailF),
              SizedBoxSpacer.h15,
              _CustomTextField(
                  usernameController, Icons.person, 'username', usernameF),
              SizedBoxSpacer.h15,
              _CustomTextField(bioController, Icons.abc, 'bio', bioF),
              SizedBoxSpacer.h15,
              _CustomTextField(
                  passwordController, Icons.lock, 'Password', passwordF),
              SizedBoxSpacer.h15,
              _CustomTextField(passwordConfirmController, Icons.lock,
                  'PasswordConfirm', passwordConfirmF),
              SizedBoxSpacer.h15,
              _signupButton,
              SizedBoxSpacer.h15,
              _login,
            ],
          ),
        ],
      )),
    );
  }

  Widget get _choiceProfilePictureWidget => Center(
        child: InkWell(
          onTap: () async {
            File? imageFilee = await ImagePickerr().uploadImage('gallery');
            setState(() {
              _imageFile = imageFilee;
            });
          },
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.grey,
            child: _imageFile == null
                ? CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: const AssetImage('images/person.png'),
                  )
                : CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ).image,
                  ),
          ),
        ),
      );

  Widget get _login => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Dont you have account?",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: widget.show,
              child: const Text(
                " Login",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

  Widget get _signupButton => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: () async {
            if (_validateInputs()) {
              try {
                await Authentication().signUp(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                    passwordConfirme: passwordConfirmController.text.trim(),
                    username: usernameController.text.trim(),
                    bio: bioController.text.trim(),
                    profile: _imageFile ?? File(''));
              } on exceptions catch (e) {
                _showSnackBar(e.massage);
              }
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
              'Sign up',
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

  Widget get _SignUpScreenLogo => Center(
        child: Image.asset('images/logo.jpg'),
      );

  Widget _CustomTextField(TextEditingController controller, IconData icon,
      String type, FocusNode focusNode) {
    bool isPassword = type.toLowerCase().contains('password');
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
          obscureText: isPassword &&
              ((type == 'Password' && !_isPasswordVisible) ||
                  (type == 'PasswordConfirm' && !_isPasswordConfirmVisible)),
          decoration: InputDecoration(
              hintText: type,
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus ? Colors.black : Colors.grey,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        (type == 'Password'
                                ? _isPasswordVisible
                                : _isPasswordConfirmVisible)
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (type == 'Password') {
                            _isPasswordVisible = !_isPasswordVisible;
                          } else {
                            _isPasswordConfirmVisible =
                                !_isPasswordConfirmVisible;
                          }
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

  bool _validateInputs() {
    if (emailController.text.isEmpty) {
      _showSnackBar('Please enter an email address.');
      return false;
    }
    if (passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long.');
      return false;
    }
    if (passwordController.text != passwordConfirmController.text) {
      _showSnackBar('Passwords do not match.');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class SizedBoxSpacer {
  static SizedBox get h10 => const SizedBox(height: 10);
  static SizedBox get h15 => const SizedBox(height: 15);
  static SizedBox get h50 => const SizedBox(height: 50);
  static SizedBox get h60 => const SizedBox(height: 60);
  static SizedBox get h120 => const SizedBox(height: 120);
  static SizedBox get h100w96 =>
      const SizedBox(height: 100, width: 96); // Özel genişlikte

  // İsteğe bağlı olarak daha fazla boyut ekleyebilirsin
}
