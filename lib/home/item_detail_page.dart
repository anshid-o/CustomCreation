import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final String cat;
  ItemDetailsPage({required this.item, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cat),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ), // Delete icon
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Deletion'),
                    content: Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          _deleteItem(item['id'],
                              context); // Pass the item ID to delete
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.green,
            ),
            onPressed: () {
              _shareItem();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                item['imageUrl'], // Use network image
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(
                '\$${item['price'].toString()}',
                style: TextStyle(fontSize: 22, color: Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                item['description'] ?? 'No description available.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareItem() async {
    final String imageUrl = item['imageUrl'];
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final fileName = '${item['name']}.jpg';
    final path = '${tempDir.path}/$fileName';

    await File(path).writeAsBytes(bytes);

    final String shareText = '''
Check out this amazing item from CustomCreations!

Name: ${item['name']}
Price: \$${item['price']}
Description: ${item['description'] ?? 'No description available.'}

Contact us for more details or to make a purchase.
''';

    await Share.shareFiles(
      [path],
      text: shareText,
    );
  }

  Future<void> _deleteItem(String itemId, BuildContext context) async {
    try {
      // Delete the item from Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(itemId)
          .delete();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully.')),
      );
      // Optionally, pop the page to go back to the previous screen
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }
}
