import 'package:budget_buddy/data/model/add_date.dart';
import 'package:budget_buddy/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';

class Add_Screen extends StatefulWidget {
  final Expense? expense; // Add this line

  const Add_Screen({super.key, this.expense});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  late Box<Add_data> box;
  DateTime date = DateTime.now();
  String? selctedItem;
  String? selctedItemi;
  String? selectedCategory;
  TextEditingController expalin_C = TextEditingController();
  FocusNode ex = FocusNode();
  TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and other fields with existing expense data if available
    expalin_C = TextEditingController(text: widget.expense?.description ?? '');
    amount_c =
        TextEditingController(text: widget.expense?.amount.toString() ?? '');
    selectedCategory = widget.expense?.category ?? '';
    selctedItemi = widget.expense?.type ?? 'Expense'; // Default to 'Expense'
    selectedDate = widget.expense?.date ?? DateTime.now();
    selectedRecurrence = widget.expense?.recurrence ?? 'Never';
    selectedReminder = widget.expense?.reminder ?? 'Never';
    // ... Other initializations
  }

  final List<String> _item = [
    "Food",
    "Transfer",
    "Transportation",
    "Education"
  ];
  final List<String> _itemei = [
    'Income',
    'Expense',
  ];
  String? selectedRecurrence;
  String? selectedReminder;
  final List<String> recurrenceOptions = [
    'Never',
    'Every Minute',
    'Every Day',
    'Every 3 Days',
    'Every Week'
  ];
  final List<String> reminderOptions = [
    'Never',
    '1 Minute Before',
    '1 Day Before'
  ];

  Future<void> addExpense(Expense expense) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await ref.child(userId).push().set(expense.toJson());
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
            child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            background_container(context),
            Positioned(
              top: 120,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                height: 550,
                width: 340,
                child: Column(
                  children: [
                    SizedBox(height: 35),
                    nameField(),
                    SizedBox(height: 20),
                    expalin(),
                    SizedBox(height: 20),
                    amount(),
                    SizedBox(height: 20),
                    date_time(),
                    SizedBox(height: 20),
                    recurrenceField(),
                    SizedBox(height: 20),
                    reminderField(),
                    Spacer(),
                    save(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        )));
  }

  void saveExpense() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    if (widget.expense != null && widget.expense!.key != null) {
      // Updating an existing expense
      Expense updatedExpense = Expense(
        key: widget.expense!.key!, // Asserting non-null
        category: selectedCategory!,
        amount: double.parse(amount_c.text),
        description: expalin_C.text,
        date: selectedDate!,
        type: determineType(selectedCategory!), // Add type determination
        recurrence: selectedRecurrence ?? 'Never',
        reminder: selectedReminder ?? 'Never',
      );

      // Debug print
      print('Updating Expense: ${updatedExpense.toJson()}');

      // Update the expense in the database
      await ref
          .child(userId)
          .child(widget.expense!.key!)
          .update(updatedExpense.toJson())
          .then((_) => print("Expense updated successfully"))
          .catchError((error) => print("Failed to update expense: $error"));
    } else {
      // Adding a new expense
      Expense newExpense = Expense(
        category: selectedCategory!,
        amount: double.parse(amount_c.text),
        description: expalin_C.text,
        date: selectedDate!,
        type: determineType(selectedCategory!), // Add type determination
        recurrence: selectedRecurrence ?? 'Never',
        reminder: selectedReminder ?? 'Never',
      );

      // Debug print
      print('Adding New Expense: ${newExpense.toJson()}');

      // Add the new expense to the database
      await ref
          .child(userId)
          .push()
          .set(newExpense.toJson())
          .then((_) => print("New expense added successfully"))
          .catchError((error) => print("Failed to add new expense: $error"));
    }

    Navigator.of(context).pop(); // Go back after saving
  }

  void updateExpenseInDatabase(Expense expense) {
    if (expense.key == null) {
      // Handle the error or return early
      print("Expense key is null. Cannot update the expense in the database.");
      return;
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    ref.child(userId).child(expense.key!).update(expense.toJson()).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Expense updated successfully")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update expense: $error")),
      );
    });
  }

  void addExpenseToDatabase(Expense expense) {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    ref.child(userId).push().set(expense.toJson()).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Expense added successfully")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add expense: $error")),
      );
    });
  }

  DateTime? calculateNextDueDate(String recurrence) {
    DateTime now = DateTime.now();
    switch (recurrence) {
      case 'Every Minute':
        return now.add(Duration(minutes: 1));
      case 'Every Day':
        return now.add(Duration(days: 1));
      case 'Every 3 Days':
        return now.add(Duration(days: 3));
      case 'Every Week':
        return now.add(Duration(days: 7));
      case 'Never':
      default:
        return null; // Return null for 'Never' or unrecognized recurrence
    }
  }

  GestureDetector save() {
    return GestureDetector(
      onTap: () {
        // Ensure both selectedCategory and amount have valid non-empty values
        if (selectedCategory?.isEmpty ?? true || amount_c.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Category or amount is missing.")),
          );
          return;
        }

        // Proceed if all required fields are not null and not empty
        try {
          var expense = Expense(
            category:
                selectedCategory!, // Non-nullable assertion used after check
            type:
                selctedItemi!, // Determine if it's an income or expense based on category
            amount: double.parse(amount_c.text),
            description: expalin_C.text,
            date: date,
            recurrence: selectedRecurrence ?? 'Never',
            reminder: selectedReminder ?? 'Never',
          );
          addExpense(expense);
          Navigator.of(context).pop();
        } catch (e) {
          // If parsing fails or any other error occurs
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("There was an error saving the expense.")),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xff368983),
        ),
        width: 120,
        height: 50,
        child: Text(
          'Save',
          style: TextStyle(
            fontFamily: 'f',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  String determineType(String categoryType) {
    return categoryType; // Simply return the type passed with the category
  }

  Widget date_time() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (newDate == Null) return;
          setState(() {
            date = newDate!;
          });
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Padding how() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selctedItemi,
          onChanged: ((value) {
            setState(() {
              selctedItemi = value!;
            });
          }),
          items: _itemei
              .map((e) => DropdownMenuItem(
                    child: Container(
                        child: Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          e,
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    )),
                    value: e,
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => _itemei
              .map((e) => Row(
                    children: [SizedBox(width: 5), Text(e)],
                  ))
              .toList(),
          hint: Text(
            'Income or Expense',
            style: TextStyle(color: Colors.grey),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_,
        controller: amount_c,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Padding expalin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        focusNode: ex,
        controller: expalin_C,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'explain',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  GestureDetector nameField() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ExpenseCategoriesScreen()),
        );

        // Handle the result here
        if (result != null && result is Map) {
          setState(() {
            selectedCategory = result['name'];
            selctedItemi = result['type']; // Capture the type here
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xffC5C5C5)),
        ),
        child: Text(selectedCategory ?? "Tap to select a category"),
      ),
    );
  }

  Padding reminderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5)),
        ),
        child: DropdownButton<String>(
          value: selectedReminder,
          onChanged: (String? newValue) {
            setState(() {
              selectedReminder = newValue!;
            });
          },
          items: reminderOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding recurrenceField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5)),
        ),
        child: DropdownButton<String>(
          value: selectedRecurrence,
          onChanged: (String? newValue) {
            setState(() {
              selectedRecurrence = newValue!;
            });
          },
          items:
              recurrenceOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xff368983),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    'Adding',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Icon(
                    Icons.attach_file_outlined,
                    color: Colors.white,
                  )
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}
