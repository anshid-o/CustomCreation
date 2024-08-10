import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ItemDetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;

  ItemDetailsPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // Handle favorite action
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Handle add to cart action
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
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
              SizedBox(height: 16),
              Text(
                item['name'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '\$${item['price'].toString()}',
                style: TextStyle(fontSize: 22, color: Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Stocks Available: ${item['stock'].toString()}',
                style: TextStyle(fontSize: 22, color: Colors.orange),
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
              Text(
                'Customization Options:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                item['customizationOptions'] ??
                    'No customization options available.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Delivery & Installation:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                item['delivery'] ?? 'No delivery information available.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Related Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Add related items here
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
Customization Options: ${item['customizationOptions'] ?? 'No customization options available.'}
Delivery & Installation: ${item['delivery'] ?? 'No delivery information available.'}

Contact us for more details or to make a purchase.
''';

    await Share.shareFiles(
      [path],
      text: shareText,
    );
  }
}
