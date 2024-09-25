import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';

class NoteDetailsPage extends StatelessWidget {
  final Map<String, dynamic> note;
  final String note_id;

  NoteDetailsPage({required this.note, required this.note_id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${note['category']} for ${note['client']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${note['client']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Location: ${note['location']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Measures:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              note['summary'] ?? 'No measures provided',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              note['details'] ?? 'No details provided',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.delete,
                  color: col30,
                ),
                label: Text(
                  'Delete Note',
                  style: TextStyle(color: col30),
                ),
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Deletion'),
                        content:
                            Text('Are you sure you want to delete this note?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('notes')
                                  .doc(note_id)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Note deleted successfully.')),
                              );
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
