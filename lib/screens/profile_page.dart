import 'package:final_exam/provider/globalProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:final_exam/home_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not signed in
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInScreen(
                    providers: [EmailAuthProvider()],
                    actions: [
                      AuthStateChangeAction((context, state) {
                        if (state is SignedIn || state is UserCreated) {
                          // Switch to Shop tab after login/register
                          Provider.of<GlobalProvider>(
                            context,
                            listen: false,
                          ).changeCurrentIdx(0);
                          // Close SignInScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        }
                      }),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Нэвтрэх'),
          ),
        ),
      );
    } else {
      // User signed in
      return ProfileScreen(
        providers: [EmailAuthProvider()],
        actions: [
          SignedOutAction((context) {
            // Switch to Profile tab after sign out
            Provider.of<GlobalProvider>(
              context,
              listen: false,
            ).changeCurrentIdx(3);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          }),
        ],
      );
    }
  }
}
