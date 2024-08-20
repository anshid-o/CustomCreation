import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'item_detail_page.dart';

class ItemsPage extends StatefulWidget {
  final String categoryName;

  ItemsPage({required this.categoryName});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Map<String, dynamic>> items = [];
  List<String> imageUrls = [];
  bool isLoading = false; // Loading state

  getData() async {
    await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.categoryName)
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            setState(() {
              items.add(element.data());
              imageUrls.add(element['imageUrl']);
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> _shareAllImages() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      List<String> imagePaths = [];

      for (String url in imageUrls) {
        final response = await http.get(Uri.parse(url));
        final bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final fileName = url.split('/').last;

        // Ensure the file extension is valid
        final extension = fileName.split('.').last.toLowerCase();
        final validExtension =
            ['jpg', 'jpeg', 'png'].contains(extension) ? extension : 'jpg';

        final path = '${tempDir.path}/$fileName.$validExtension';

        await File(path).writeAsBytes(bytes);
        imagePaths.add(path);
      }

      await Share.shareFiles(
        imagePaths,
        text: 'Check out these items from ${widget.categoryName} category!',
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: isLoading
                ? null
                : _shareAllImages, // Disable button while loading
          ),
        ],
      ),
      body: Stack(
        children: [
          items.isEmpty
              ? const Center(child: Text('No products found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(item: item),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12)),
                                child: Image.network(
                                  item['imageUrl'], // Use network image
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['name'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    item['price'].toString(),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.green),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.numbers),
                                  Text(
                                    item['stock'].toString(),
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.yellow, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '3 (34 reviews)',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(), // Show loading indicator
            ),
        ],
      ),
    );
  }
}
