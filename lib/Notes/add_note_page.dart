import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';

class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _clientName;
  String? _location;
  String? _details;

  final List<String> categories = [
    'Sofas',
    'Curtains',
    'Headboards',
    'Beds',
    'Custom Pieces'
  ];

  List<Map<String, String>> measures = [];

  void _addMeasure() {
    setState(() {
      measures.add({'name': '', 'value': ''});
    });
  }

  void _updateMeasure(int index, String field, String value) {
    setState(() {
      measures[index][field] = value;
    });
  }

  void _removeMeasure(int index) {
    setState(() {
      measures.removeAt(index);
    });
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final note = {
        'category': _selectedCategory!,
        'client': _clientName!,
        'location': _location!,
        'summary':
            measures.map((m) => '${m['name']}: ${m['value']}').join(', '),
        'details': _details!,
        'timestamp': FieldValue.serverTimestamp(), // Optional: add a timestamp
      };

      await FirebaseFirestore.instance.collection('notes').add(note);
      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightWoodcol,
      appBar: AppBar(
        title: Text('Add New Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    value: _selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _clientName = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the client\'s name'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _location = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the location'
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Measures',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: measures.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Measure Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  _updateMeasure(index, 'name', value);
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter a measure name'
                                        : null,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Measure Value',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  _updateMeasure(index, 'value', value);
                                },
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter a measure value'
                                        : null,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                _removeMeasure(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(cngreen)),
                    onPressed: _addMeasure,
                    child: Text(
                      'Add Measure',
                      style: TextStyle(color: col30),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Details',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        _details = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter details'
                        : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(cngreen)),
                    onPressed: _saveNote,
                    child: Text(
                      'Save Note',
                      style: TextStyle(color: col30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
