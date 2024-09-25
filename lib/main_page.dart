import 'package:custom_creations/Notes/note_page.dart';

import 'package:custom_creations/add_product_page.dart';
import 'package:custom_creations/constants.dart';

import 'package:custom_creations/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_nav_bar/curved_bar/curved_action_bar.dart';
import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:curved_nav_bar/flutter_curved_bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      body: CurvedNavBar(
          actionButton: CurvedActionBar(
              onTab: (value) {},
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    const BoxDecoration(color: col30, shape: BoxShape.circle),
                child: const Icon(
                  Icons.chair_outlined,
                  size: 25,
                  color: cngreen,
                ),
              ),
              inActiveIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration:
                    const BoxDecoration(color: cdgreen, shape: BoxShape.circle),
                child: const Icon(
                  Icons.chair,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
              text: "Post"),
          activeColor: col60,
          navBarBackgroundColor: cdgreen,
          inActiveColor: Colors.black45,
          appBarItems: [
            FABBottomAppBarItem(
              activeIcon: Container(
                decoration: BoxDecoration(
                    color: col30, borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Icon(
                    Icons.home_outlined,
                    color: col60,
                  ),
                ),
              ),
              inActiveIcon: const Icon(
                Icons.home,
                color: Colors.black26,
              ),
              text: 'Home',
            ),
            FABBottomAppBarItem(
              activeIcon: Container(
                  decoration: BoxDecoration(
                      color: col30, borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Icon(
                      Icons.note_alt_outlined,
                      color: col60,
                    ),
                  )),
              inActiveIcon: const Icon(
                Icons.note_alt_rounded,
                color: Colors.black26,
              ),
              text: 'Note',
            ),
            FABBottomAppBarItem(
              activeIcon: Container(
                decoration: BoxDecoration(
                    color: col30, borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Icon(
                    Icons.sell,
                    color: col60,
                  ),
                ),
              ),
              inActiveIcon: const Icon(
                Icons.sell_rounded,
                color: Colors.black26,
              ),
              text: 'Stock',
            ),
            FABBottomAppBarItem(
                activeIcon: Container(
                  decoration: BoxDecoration(
                      color: col30, borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Icon(
                      Icons.local_convenience_store_outlined,
                      color: col60,
                    ),
                  ),
                ),
                inActiveIcon: const Icon(
                  Icons.local_convenience_store,
                  color: Colors.black26,
                ),
                text: 'Overall'),
          ],
          bodyItems: [
            const HomePage(),
            NotesPage(),
            Scaffold(
              backgroundColor: col30,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: cngreen,
                title: Text('Transactions'),
              ),
              body: Center(
                child: Text(
                  'Removed feature',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Scaffold(
              backgroundColor: col30,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: cngreen,
                title: Text('Overall'),
              ),
              body: Center(
                child: Text(
                  'Removed feature',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),

            // TransactionPage(),
            // OverallPage()
          ],
          actionBarView: AddProductPage()),
    );
  }
}
