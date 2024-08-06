import 'package:custom_creations/constants.dart';
import 'package:custom_creations/main_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the next page after 2.5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MainPage(), // Replace with your target page
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (MediaQuery.of(context).size.height < 950) {
      setState(() {
        isPhone = true;
      });
    }
    return Scaffold(
      backgroundColor: cgreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset('assets/furniture.json',
              height: 300,
              width: double.infinity,
              frameRate: const FrameRate(60)),
          SizedBox(
            width: size.width,
            height: 20,
          ),
          SizedBox(
            height: size.height * .025,
          ),
          Text(
            'Welcome to CustomCreations',
            style: TextStyle(
                color: col60,
                fontSize: isPhone ? 24 : 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 30.0, horizontal: size.width * .08),
            child: Text(
              'Where Elegance Meets Craftsmanship. Your Perfect Products, Just a Tap Away. ',
              style: TextStyle(
                  color: col60,
                  fontSize: isPhone ? 18 : 26,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
