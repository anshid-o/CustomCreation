import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart'; // Assuming your color constants are here
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as i;

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  XFile? file;
  String imageUrl = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _deliveryController = TextEditingController();

  String _category = 'Sofas';

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cngreen), // Use your custom color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 2.0,
          color: Colors.grey,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 2.5,
          color: Colors.black,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 2.5,
          color: cngreen, // Color on focus
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: cngreen,
      appBar: AppBar(
        backgroundColor: cngreen,
        centerTitle: true,
        title: Text(
          'Add Product',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: size.height * .75,
          decoration: BoxDecoration(
            color: col30,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _isLoading
                      ? Center(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: cngreen, width: 5)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.image),
                                Text('Image Loading... ',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(
                                    width:
                                        10), // Small spacing between text and loader
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        )
                      : imageUrl.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.height * .2,
                                  width: size.width * .4,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await _showOptionsDialog(context);
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await _uploadImage();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 30,
                                    color:
                                        cngreen, // Custom green color for the edit icon
                                  ),
                                )
                              ],
                            )
                          : GestureDetector(
                              onTap: () async {
                                await _showOptionsDialog(context);
                                setState(() {
                                  _isLoading = true;
                                });
                                await _uploadImage();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              child: Container(
                                height: size.height * .15,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: cngreen, width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Description'),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('Price'),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Category'),
                    value: _category,
                    items: [
                      'Sofas',
                      'Curtains',
                      'Headboards',
                      'Beds',
                      'Custom Pieces'
                    ].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cngreen, // Use your custom green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (imageUrl.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please choose an image');
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection("products")
                            .add({
                          'description': _descriptionController.text,
                          'price': double.parse(_priceController.text),
                          'category': _category,
                          'imageUrl': imageUrl,
                          'time': DateTime.now(),
                        });

                        Fluttertoast.showToast(msg: 'Product Added');
                        setState(() {
                          _descriptionController.clear();
                          _priceController.clear();
                          _category = 'Sofas';
                          _deliveryController.clear();
                          imageUrl = '';
                        });
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (file != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('product_images');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);
      i.File imageFile = i.File(file!.path);

      try {
        await referenceImageToUpload.putFile(imageFile);
        String url = await referenceImageToUpload.getDownloadURL();
        setState(() {
          imageUrl = url;
        });
      } catch (e) {
        print(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showOptionsDialog(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an image'),
          actions: [
            TextButton(
              child: Text('Camera'),
              onPressed: () async {
                file = await imagePicker.pickImage(source: ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () async {
                file = await imagePicker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
