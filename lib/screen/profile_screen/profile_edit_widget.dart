// ignore_for_file: invalid_use_of_protected_member, camel_case_types

import 'package:flutter/material.dart';

import 'profile_screen.dart';

class yoursStateTrueProfileCenterBarVisibility extends StatelessWidget {
  const yoursStateTrueProfileCenterBarVisibility({
    super.key,
    required this.yours,
  });

  final bool yours;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: yours,
      child: GestureDetector(
        onTap: () {
          final state = context.findAncestorStateOfType<ProfileScreenState>();
          if (state != null) {
            state.setState(() {
              state.isEditing = true;
              state.bioController.text = state.userr!.bio;
              state.usernameController.text = state.userr!.username;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            alignment: Alignment.center,
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            child: const Text(
              'Edit Your Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
