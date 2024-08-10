import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
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
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockCount = TextEditingController();
  TextEditingController _customizationController = TextEditingController();
  TextEditingController _deliveryController = TextEditingController();

  String _category = 'Sofas';
  bool _isCustomizationRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockCount.dispose();
    _customizationController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 2.0, // Adjust border width here
          color: Colors.grey, // Border color (optional)
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 3.0, // Adjust border width here
          color: Colors.black, // Border color (optional)
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          width: 3.0, // Adjust border width here
          color: Colors.blue, // Border color when focused (optional)
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: cdgreen,
      appBar: AppBar(
        backgroundColor: cdgreen,
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
          decoration: BoxDecoration(
              color: lightWoodcol, borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  imageUrl != ''
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
                                )),
                            IconButton(
                                onPressed: () async {
                                  await _showOptionsDialog(context);
                                  await _uploadImage();
                                },
                                icon: Icon(
                                  Icons.change_circle_outlined,
                                  size: 50,
                                  color: cngreen,
                                ))
                          ],
                        )
                      : GestureDetector(
                          onTap: () async {
                            await _showOptionsDialog(context);
                            await _uploadImage();
                          },
                          child: Container(
                            height: size.height * .2,
                            decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: cngreen, width: 3),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Center(
                                child: Icon(
                              Icons.add_a_photo,
                              size: 80,
                            )),
                          ),
                        ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Product Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
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
                  TextFormField(
                    controller: _stockCount,
                    decoration: _inputDecoration('Count'),
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
                  TextFormField(
                    controller: _customizationController,
                    decoration: _inputDecoration('Customization Options'),
                    maxLines: 2,
                    enabled: _isCustomizationRequired,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _deliveryController,
                    decoration: _inputDecoration('Delivery & Installation'),
                    maxLines: 2,
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
                  CheckboxListTile(
                    title: Text('Customization Required'),
                    value: _isCustomizationRequired,
                    onChanged: (value) {
                      setState(() {
                        _isCustomizationRequired = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (imageUrl.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please choose an image');
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection("products")
                            .add({
                          'name': _nameController.text,
                          'description': _descriptionController.text,
                          'price': double.parse(_priceController.text),
                          'category': _category,
                          'stock': int.parse(_stockCount.text),
                          'customization': _isCustomizationRequired
                              ? _customizationController.text
                              : '',
                          'delivery': _deliveryController.text,
                          'imageUrl': imageUrl,
                          'time': DateTime.now()
                        });

                        Fluttertoast.showToast(msg: 'Product Added');
                        setState(() {
                          _nameController.text = '';
                          _descriptionController.text = '';
                          _priceController.text = '';
                          _category = 'Sofas';
                          _isCustomizationRequired = false;
                          _deliveryController.text = '';
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
      print(referenceImageToUpload.fullPath);
      i.File imageFile = i.File(file!.path);
      print(imageFile.path);

      try {
        print('in try');
        await referenceImageToUpload.putFile(imageFile);
        print('ok1');
        String url = await referenceImageToUpload.getDownloadURL();
        print('url ok $url');
        setState(() {
          imageUrl = url;
        });
      } catch (e) {
        print(e.toString());
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
