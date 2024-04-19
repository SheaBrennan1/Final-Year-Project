import 'package:budget_buddy/budget_screen.dart';
import 'package:budget_buddy/expense_model.dart';
import 'package:budget_buddy/home.dart';
import 'package:budget_buddy/statistics.dart';
import 'package:budget_buddy/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_buddy/features/app/ExpenseCategoriesScreen.dart';
import 'package:intl/intl.dart';

class Add_Screen extends StatefulWidget {
  final Expense? expense;

  const Add_Screen({super.key, this.expense});

  @override
  State<Add_Screen> createState() => Add_ScreenState();
}

class Add_ScreenState extends State<Add_Screen> {
  DateTime date = DateTime.now();
  String? selctedItem;
  String? selctedItemi;
  String? selectedCategory;
  String? selectedCategoryImage;
  TextEditingController expalin_C = TextEditingController();
  FocusNode ex = FocusNode();
  TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();
  DateTime? selectedDate;
  int index_color = 4;

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
    '30 seconds Before',
    '1 Day Before',
    '3 Days Before',
    '1 Week Before'
  ];

  Future<void> addExpense(Expense expense) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    await ref.child(userId).push().set(expense.toJson());
  }

  Widget inputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        labelStyle: TextStyle(color: Colors.blueGrey), // Updated color
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal), // Updated color
        ),
      ),
    );
  }

  Widget titledInputField(String title, Widget inputField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        SizedBox(height: 8),
        inputField,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        backgroundColor: Colors.blue,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.blue.shade200,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  nameField(),
                  SizedBox(height: 16),
                  explainField(),
                  SizedBox(height: 16),
                  amount(),
                  SizedBox(height: 16),
                  date_time(),
                  SizedBox(height: 16),
                  recurrenceField(),
                  SizedBox(height: 24),
                  save(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(4);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  _onItemTapped(0);
                }),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _onItemTapped(1);
                }),
            IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  _onItemTapped(2);
                }),
            IconButton(
                icon: Icon(Icons.account_circle),
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
      case 4:
        break;
    }
  }

  void saveExpense() async {
    print("Saving expense with recurrence: $selectedRecurrence");
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("expenses");
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    // Prepare the Expense object with correct type (either "Income" or "Expense")
    Expense expense = Expense(
      key: widget.expense?.key,
      category: selectedCategory!,
      amount: double.parse(amount_c.text),
      description: expalin_C.text,
      date: selectedDate!,
      type:
          selctedItemi!, // Correctly set the type to either "Income" or "Expense"
      recurrence: selectedRecurrence ?? 'Never',
      reminder: selectedReminder ?? 'Never',
    );

    if (expense.key != null) {
      // Updating an existing expense
      await ref
          .child(userId)
          .child(expense.key!)
          .update(expense.toJson())
          .then((_) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Expense updated successfully"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update expense: $error"))));
    } else {
      // Adding a new expense
      await ref
          .child(userId)
          .push()
          .set(expense.toJson())
          .then((_) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("New expense added successfully"))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to add new expense: $error"))));
    }

    Navigator.of(context).pop(); // Go back after saving
  }

  void updateExpenseInDatabase(Expense expense) {
    if (expense.key == null) {
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

  Widget save() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: saveExpense,
        child: Text('Save Expense', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String determineType(String categoryType) {
    return categoryType;
  }

  Widget date_time() {
    // TextEditingController to display the selected date
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(selectedDate!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            labelText: 'Date',
            suffixIcon: Icon(Icons.calendar_today, color: Colors.teal),
            border: InputBorder.none,
          ),
          onTap: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: selectedDate!,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Colors.teal,
                    colorScheme: ColorScheme.light(primary: Colors.teal),
                    buttonTheme:
                        ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
            );
            if (newDate != null) {
              setState(() {
                selectedDate = newDate;
                // Update the text field with the new date
                dateController.text = DateFormat('yyyy-MM-dd').format(newDate);
              });
            }
          },
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
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Amount',
          prefixText: '£ ',
          prefixStyle: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.grey.shade600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              width: 1,
              color: Color(0xFFC5C5C5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              width: 2,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }

  Padding explainField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFormField(
            focusNode: ex,
            controller: expalin_C,
            decoration: InputDecoration(
              hintText: 'Explain',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ),
    );
  }

  Widget nameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseCategoriesScreen()),
          );

          if (result != null && result is Map) {
            setState(() {
              selectedCategory = result['name'];
              selctedItemi = result['type'];
              selectedCategoryImage = result['image'];
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Color(0xffC5C5C5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (selectedCategoryImage != null &&
                  selectedCategoryImage!.isNotEmpty)
                categoryIcon(),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedCategory == null || selectedCategory!.isEmpty
                      ? "Select a Category"
                      : selectedCategory!,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryIcon() {
    if (selectedCategoryImage != null && selectedCategoryImage!.isNotEmpty) {
      return Image.asset(selectedCategoryImage!, height: 40);
    } else {
      return Icon(Icons.category, size: 40);
    }
  }

  Padding reminderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Reminder',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
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
      ),
    );
  }

  Padding recurrenceField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Recurrence',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2, color: Color(0xff368983)),
          ),
        ),
        value: selectedRecurrence,
        onChanged: (String? newValue) {
          setState(() {
            selectedRecurrence = newValue;
            print("Recurrence updated to: $newValue");
          });
        },
        items: recurrenceOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
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
