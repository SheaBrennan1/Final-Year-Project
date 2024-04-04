import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TargetService {
  final DatabaseReference _targetsRef =
      FirebaseDatabase.instance.ref('targets');

  Future<void> setYearlyTarget(double target) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _targetsRef.child(user.uid).set({
        'yearlyTarget': target,
        'timestamp': ServerValue.timestamp, // To keep track of when it was set
      });
    }
  }

  Future<double> getYearlyTarget() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DataSnapshot snapshot = await _targetsRef.child(user.uid).get();
      if (snapshot.exists && snapshot.value is Map) {
        Map targetMap = snapshot.value as Map;
        return targetMap['yearlyTarget'] ?? 0.0;
      }
    }
    return 0.0;
  }
}
