import 'package:budget_buddy/leaderboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_competition_screen.dart';

class Competition {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final int maxParticipants;
  final List<String> participants;

  Competition({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.maxParticipants,
    required this.participants,
  });

  factory Competition.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Competition(
      id: doc.id,
      name: data['name'],
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      createdBy: data['created_by'],
      maxParticipants: data['max_participants'],
      participants: List<String>.from(data['participants']),
    );
  }
}

class CompetitionsScreen extends StatefulWidget {
  @override
  _CompetitionsScreenState createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  List<Competition> competitions = [];

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
  }

  void fetchCompetitions() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('competitions').get();
      setState(() {
        competitions = querySnapshot.docs
            .map((doc) => Competition.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print("Error fetching competitions: $e");
      // Optionally, show an error message to the user
    }
  }

  void _createCompetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateCompetitionScreen()),
    );
  }

  void _joinCompetition() {
    // Placeholder: Navigate to the Join Competition Screen or Dialog
    print('Join competition');
  }

  Widget _buildCompetitionList(bool isCurrent) {
    final now = DateTime.now();
    List<Competition> filteredCompetitions = competitions.where((comp) {
      return isCurrent
          ? comp.startDate.isBefore(now) && comp.endDate.isAfter(now)
          : comp.endDate.isBefore(now);
    }).toList();

    if (filteredCompetitions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          isCurrent ? 'No current competitions.' : 'No ended competitions.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredCompetitions.length,
      itemBuilder: (context, index) {
        Competition comp = filteredCompetitions[index];
        return ListTile(
          title: Text(comp.name),
          subtitle: Text('Ends on: ${comp.endDate.toLocal()}'),
          onTap: () {
            if (isCurrent) {
              // Navigate to LeaderboardScreen if the competition is active
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(
                    competitionName: comp.name,
                    competitionId: comp
                        .id, // Ensure you have an 'id' field in your Competition model
                  ),
                ),
              );
            } else {
              // Optionally handle tap for ended competitions
              print('This competition has ended.');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Competitions'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: _createCompetition,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
              child: Text('Create Competition'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinCompetition,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
              child: Text('Join Competition'),
            ),
            SizedBox(height: 40),
            Text('Current Competitions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildCompetitionList(true),
            SizedBox(height: 20),
            Text('Ended Competitions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildCompetitionList(false),
          ],
        ),
      ),
    );
  }
}
