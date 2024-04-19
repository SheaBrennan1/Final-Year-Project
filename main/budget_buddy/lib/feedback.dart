import 'package:budget_buddy/add.dart';
import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // For getting the platform

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String? _selectedTopic = 'Question';
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _titleController =
      TextEditingController(); // Controller for the feedback title
  int index_color = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Feedback Title:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback title...',
                  hintStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your feedback helps us improve. Please select a topic and provide as much detail as possible.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                'Select Topic:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTopic,
                    isExpanded: true,
                    items: <String>['Question', 'Bug Report', 'Request']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTopic = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  hintText: 'Write your details here...',
                  hintStyle: TextStyle(
                      color: Colors.black), // Change hint text color to black
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 5,
              ),
              SizedBox(height: 16),
              Text(
                'Your Environment:\n- Operating System: ${Platform.operatingSystem}\n- Version: ${Platform.operatingSystemVersion}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    submitFeedback();
                    print('Feedback Topic: $_selectedTopic');
                    print('Details: ${_detailsController.text}');
                    // Show a success message or handle the submission
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue, // Set the text color to black
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Submit Feedback'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Add_Screen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomAppBar(
        // Omitting shape property
        color: Colors.white, // Set your desired color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.home,
                ),
                onPressed: () {
                  _onItemTapped(0);
                }),
            IconButton(
                icon: Icon(Icons.bar_chart),
                onPressed: () {
                  _onItemTapped(1);
                }),
            IconButton(
                icon: Icon(Icons.savings_sharp),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle, color: Colors.blue),
                onPressed: () {
                  _onItemTapped(3);
                }),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      index_color = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        break;
      case 1:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Statistics()));
        break;
      case 2:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BudgetScreen()));
        break;
      case 3:
        break;
    }
  }

  Future<void> submitFeedback() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('feedback').add({
        'title': _titleController.text,
        'topic': _selectedTopic,
        'details': _detailsController.text,
        'environment': {
          'operatingSystem': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        },
        'timestamp':
            FieldValue.serverTimestamp(), // Captures the time of submission
      });
      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );
      _titleController.clear();
      _detailsController.clear();
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback. Please try again.')),
      );
    }

    @override
    void dispose() {
      _detailsController.dispose();
      _titleController.dispose(); // Dispose the controller
      super.dispose();
    }
  }
}
