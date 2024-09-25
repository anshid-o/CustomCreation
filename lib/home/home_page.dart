import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:custom_creations/home/category_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  setData() async {
    await FirebaseFirestore.instance.collection('data').get().then(
      (value) {
        if (mounted) {
          setState(() {
            name = value.docs.first.data()['name'];
          });
        }
      },
    );
  }

  @override
  void initState() {
    setData();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: col30,
          centerTitle: true,
          title: const Text(
            'Home',
            style: TextStyle(
                color: cngreen, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        backgroundColor: col30,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: size.height * .8,
            decoration: BoxDecoration(
              color: cngreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of cards in a row
                  crossAxisSpacing: 16.0, // Spacing between cards horizontally
                  mainAxisSpacing: 16.0, // Spacing between cards vertically
                  childAspectRatio: size.width > 750
                      ? 9 / 4
                      : size.width > 650
                          ? 7 / 4
                          : 3 / 2, // Aspect ratio of each card
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    categoryName: categories[index],
                    imagePath:
                        'assets/cat/${index == 4 ? 'CustomPieces' : categories[index]}.png',
                  );
                },
              ),
            ),
          ),
        ));
  }
}
