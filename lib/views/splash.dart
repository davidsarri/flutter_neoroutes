import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neoroutes/styles/app_styles.dart';
import 'package:neoroutes/views/search_view.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String status = "Carregant aplicació...";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, init);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NeoRoutes',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppStyles.charcoal,
              ),
            ),
            SizedBox(height: 24),
            Text(status),
          ],
        ),
      ),
    );
  }

  Future<void> init() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                  clientId: "719731019479-vdu6ado4a3s9e3u1nr19vp54c8giqck2"),
            ],
            actions: [
              AuthStateChangeAction<UserCreated>((context, state) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SearchView()));
              }),
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SearchView()));
              }),
            ],
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SearchView()));
    }
  }
}
