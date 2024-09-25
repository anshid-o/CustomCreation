import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'item_detail_page.dart';
import 'package:path/path.dart' as path;

class ItemsPage extends StatefulWidget {
  final String categoryName;

  ItemsPage({required this.categoryName});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Map<String, dynamic>> items = [];
  List<String> imageUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  // Fetch data from Firestore based on category name
  getData() async {
    await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.categoryName)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          var x = element.data();
          x['id'] = element.id;
          items.add(x);
          imageUrls.add(element['imageUrl']);
        });
      });
    });
  }

  Future<String> _saveImageLocally(String url) async {
    // Use the temporary directory for caching the image
    final tempDir = await getTemporaryDirectory();

    // Get the image file name from the URL
    final fileName = url.split('/').last;

    // Create a complete file path with the appropriate extension
    final filePath =
        path.join(tempDir.path, '${path.withoutExtension(fileName)}.png');

    final file = File(filePath);

    // Check if the file already exists; if yes, return the file path
    if (await file.exists()) {
      return filePath;
    }

    // If the file doesn't exist, download and save it
    final response = await http.get(Uri.parse(url));

    // Check if the HTTP request was successful
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download image: ${response.statusCode}');
    }

    return filePath;
  }

  // Share all images, saving them locally if not already saved
  Future<void> _shareAllImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<String> imagePaths = [];

      for (String url in imageUrls) {
        final filePath = await _saveImageLocally(url);
        imagePaths.add(filePath);
      }

      await Share.shareFiles(
        imagePaths,
        text: '',
      );
    } finally {
      setState(() {
        isLoading = false;
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
            icon: const Icon(
              Icons.share,
              color: Colors.green,
            ),
            onPressed: isLoading ? null : _shareAllImages,
          ),
        ],
        backgroundColor: cngreen, // Custom app bar color
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
                    final imageUrl = item['imageUrl'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(
                                item: item, cat: widget.categoryName),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  // Save image when first loaded
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) {
                                      _saveImageLocally(imageUrl);
                                      return child;
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${widget.categoryName} ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    item['price'].toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: cdgreen,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
