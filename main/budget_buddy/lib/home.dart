import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'expense_model.dart'; // Replace with the path to your Expense model

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("expenses");
  List<Expense> expenses = [];
  String userName = 'User'; // Variable to hold the user's name

  @override
  void initState() {
    super.initState();
    setUserName();
    listenToExpenses();
  }

  void setUserName() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print("Logged in user: ${currentUser.email}"); // Debug print
      userName = currentUser.displayName ?? 'User';
    } else {
      print("No user logged in."); // Debug print
      userName = 'User';
    }
  }

  void listenToExpenses() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    dbRef.child(userId).onValue.listen((event) {
      var data = event.snapshot.value;

      // Check if data is a Map and safely cast it
      if (data is Map<dynamic, dynamic>) {
        final expensesData = data.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );

        final newExpenses = expensesData.entries
            .map((e) =>
                Expense.fromJson(Map<String, dynamic>.from(e.value), e.key))
            .toList();

        setState(() {
          expenses = newExpenses;
        });
      }
    });
  }

  Future<void> removeExpense(String key) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await dbRef.child(userId).child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: 340, child: _head()),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions History',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final history = expenses[index];
                  return getList(history, index);
                },
                childCount: expenses.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getList(Expense history, int index) {
    // Fallback key value if history.key is null
    String keyValue = history.key ?? 'default_key_$index';

    return Dismissible(
      key: Key(keyValue),
      onDismissed: (direction) {
        // Check if key is not null before calling removeExpense
        if (history.key != null) {
          removeExpense(history.key!);
        }
      },
      child: get(index, history),
    );
  }

  ListTile get(int index, Expense history) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset('images/${history.category}.png', height: 40),
      ),
      title: Text(
        history.category,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${history.date.day}/${history.date.month}/${history.date.year}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Text(
        '\$${history.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: history.type == 'Income' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _head() {
    // Calculate the total balance, income, and expenses from the Firebase data
    double totalIncome = expenses
        .where((item) => item.type == 'Income')
        .fold(0, (sum, item) => sum + item.amount);
    double totalExpenses = expenses
        .where((item) => item.type == 'Expense')
        .fold(0, (sum, item) => sum + item.amount);
    double totalBalance = totalIncome - totalExpenses;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                  color: Color(0xff368983),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              child: Stack(
                children: [
                  Positioned(
                      top: 35,
                      left: 340,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                              height: 40,
                              width: 40,
                              color: Color.fromRGBO(250, 250, 250, 0.1),
                              child: Icon(
                                Icons.notification_add_outlined,
                                size: 30,
                                color: Colors.white,
                              )))),
                  Padding(
                    padding: EdgeInsets.only(top: 35, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good afternoon',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color.fromARGB(255, 224, 223, 223),
                          ),
                        ),
                        Text(
                          userName, // Removed 'const' keyword
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 140,
          left: 37,
          child: Container(
            height: 170,
            width: 320,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(47, 125, 121, 0.3),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 6,
                )
              ],
              color: const Color.fromARGB(255, 47, 125, 121),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        '£ ${totalBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(Icons.arrow_downward,
                                color: Colors.white, size: 19),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color.fromARGB(255, 216, 216, 216),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(Icons.arrow_upward,
                                color: Colors.white, size: 19),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color.fromARGB(255, 216, 216, 216),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 7),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '£ ${totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '£ ${totalExpenses.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
