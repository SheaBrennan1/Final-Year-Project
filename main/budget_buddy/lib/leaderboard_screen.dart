import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Participant {
  final String userId;
  final String userName;
  final int score; // Assuming you are tracking scores

  Participant({
    required this.userId,
    required this.userName,
    required this.score,
  });
}

class LeaderboardScreen extends StatefulWidget {
  final String competitionId;
  final String competitionName;

  const LeaderboardScreen({
    Key? key,
    required this.competitionId,
    required this.competitionName,
  }) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Participant> participants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParticipants();
  }

  void fetchParticipants() async {
    setState(() => isLoading = true);

    final competitionRef = FirebaseFirestore.instance
        .collection('competitions')
        .doc(widget.competitionId);

    try {
      final competitionDoc = await competitionRef.get();
      if (!competitionDoc.exists) {
        throw Exception("Competition not found");
      }
      List<dynamic> participantIds =
          competitionDoc.data()?['participants'] ?? [];
      print("Participant IDs: $participantIds");

      for (String userId in participantIds) {
        final userSettingsRef =
            FirebaseFirestore.instance.collection('userSettings').doc(userId);

        final userSettingsDoc = await userSettingsRef.get();
        if (userSettingsDoc.exists) {
          Map<String, dynamic> userData = userSettingsDoc.data()!;
          String userName = userData['username'] ?? 'Unknown User';
          // Assuming the score is stored in Firestore under userSettings, otherwise adjust accordingly.
          int score = userData['score'] ?? 0;

          participants.add(
              Participant(userId: userId, userName: userName, score: score));
        } else {
          print("User settings not found in Firestore: $userId");
        }
      }
    } catch (e) {
      print('Error fetching participants: $e');
    }

    print("Participants fetched: ${participants.length}");
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.competitionName),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : participants.isEmpty
              ? Center(child: Text("No participants found."))
              : ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(participant.userName),
                      trailing: Text("${participant.score} pts"),
                    );
                  },
                ),
    );
  }
}
