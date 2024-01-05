import 'package:budget_buddy/data/model/add_date.dart';
import 'package:hive/hive.dart';

int totals = 0;

final box = Hive.box<Add_data>('data');

int total() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income'
        ? int.parse(history2[i].amount)
        : int.parse(history2[i].amount) * -1);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

int income() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income' ? int.parse(history2[i].amount) : 0);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

int expenses() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income' ? 0 : int.parse(history2[i].amount) * -1);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}
