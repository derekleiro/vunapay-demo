import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vunapay_demo/services/firestore.dart';
import 'package:intl/intl.dart';

import 'numberPadBottomSheet.dart';

class HomeExtendedFAB extends StatelessWidget {
  final int amountOwed;
  const HomeExtendedFAB({super.key, required this.amountOwed});

  @override
  Widget build(BuildContext context) {
    return (FloatingActionButton.extended(
      onPressed: () async {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Ensures the keyboard is fully visible
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => NumberPadBottomSheet(amountOwed: amountOwed),
        );
      },
      label: const Text(
        "Request for Payment",
        style: TextStyle(fontFamily: "Poppins"),
      ),
      icon: const Icon(Icons.payments_outlined),
      backgroundColor: const Color.fromRGBO(73, 189, 119, 1.0),
      // Customize the color
      foregroundColor: Colors.white, // Text & icon color
    ));
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return (AppBar(
      toolbarHeight: 120,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              fontFamily: "Poppins",
              color: Colors.black,
            ),
          ),
          Text(
            'Samuel Njoroge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "Cormorant",
              color: Colors.black,
            ),
          ),
        ],
      ),
    ));
  }
}

class ChatExtendedFAB extends StatelessWidget {
  const ChatExtendedFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return (FloatingActionButton.extended(
      onPressed: () async {
        // Go to the chat page
      },
      label: const Text(
        "Start a new chat",
        style: TextStyle(fontFamily: "Poppins"),
      ),
      icon: const Icon(Icons.payments_outlined),
      backgroundColor: const Color.fromRGBO(73, 189, 119, 1.0),
      // Customize the color
      foregroundColor: Colors.white, // Text & icon color
    ));
  }
}

class TranscationsList extends StatefulWidget {
  const TranscationsList({super.key});

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TranscationsList> {
  final FirestoreService firestoreService = FirestoreService();
  int _amountOwed = 0;
  int _amountOwes = 0;

  List<Map<String, dynamic>> transactionsList = [];

  @override
  void initState() {
    super.initState();

    // Listen for real-time updates
    firestoreService.listenToAmountOwed((newAmount) {
      setState(() {
        _amountOwed = newAmount;
      });
    });

    firestoreService.listenToAmountOwes((newAmount) {
      setState(() {
        _amountOwes = newAmount;
      });
    });

    // Listen for new transactions
    firestoreService.getTransactionsStream((updatedTransactions) {
      setState(() {
        transactionsList = updatedTransactions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Card(
                  color: Color.fromRGBO(73, 189, 119, 1.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amount owed",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "KES $_amountOwed",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Card(
                  color: Color.fromRGBO(168, 44, 44, 1.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("I owe", style: TextStyle(color: Colors.white)),
                        Text(
                          "KES $_amountOwes",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: transactionsList.length,
                    itemBuilder: (context, index) {
                      final data = transactionsList[index];

                      Map<String, dynamic> transaction = data["transaction"];
                      Timestamp timestamp = data["timestamp"];

                      // Convert Firestore Timestamp to DateTime
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                          timestamp.seconds * 1000);

                      // Format the date
                      String formattedDate =
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                      print("what da dawg doin?");
                      print(timestamp);

                      return Column(
                        children: [
                          TransactionTile(
                              amount: transaction['amount'].toString(),
                              type: transaction['type'],
                              note: transaction['note'],
                              timestamp: formattedDate),
                          if ((index + 1) != transactionsList.length)
                            Divider(
                              color: Colors.grey.shade200,
                            )
                        ],
                      );
                    },
                  ),
                  if (transactionsList.isEmpty)
                    Text("You don't have any transactions.")
                  else
                    Container()
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 85,
        )
        // Container(
        //   child: ,
        // )
      ],
    ));
  }
}

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  ChatInterfaceState createState() => ChatInterfaceState();
}

class ChatInterfaceState extends State<ChatInterface> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      firestoreService.newChatMessage(text);
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen for new messages
    firestoreService.listenToChat("1", (updatedMessages) {
      setState(() {
        messages = updatedMessages;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight(BuildContext context) {
      final double totalHeight = MediaQuery.of(context).size.height;
      final double appBarHeight = kToolbarHeight; // Default AppBar height
      final double statusBarHeight = MediaQuery.of(context).padding.top;
      final double bottomNavBarHeight =
          kBottomNavigationBarHeight; // Default Bottom Nav Bar height

      return totalHeight - appBarHeight - statusBarHeight - bottomNavBarHeight;
    }

    return (Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Chat messages
        SizedBox(
            height: screenHeight(context) - 160,
            child: messages.length > 0
                ? ListView.builder(
                    reverse: true, // Newest messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[
                          messages.length - 1 - index]; // Reverse index
                      return Align(
                        alignment: message["sender"] == "user"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message["sender"] == "user"
                                ? const Color.fromRGBO(44, 168, 79, 1.0)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message["text"],
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                color: message["sender"] == "user"
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "What question do you have today?",
                      style: TextStyle(fontFamily: "Cormorant", fontSize: 18),
                    ),
                  )),
        // Message Input Field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "What is the estimated yeild for coffeee?",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: sendMessage,
                child: const Icon(Icons.send, color: Colors.white),
                backgroundColor: const Color.fromRGBO(44, 168, 79, 1.0),
              ),
            ],
          ),
        ),
        SizedBox(height: 100)
      ],
    ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _amountOwed = 0;
  final FirestoreService firestoreService = FirestoreService();

  static final List<Widget> _pages = <Widget>[
    TranscationsList(),
    ChatInterface(),
  ];

  static final List<Widget> _appBars = <Widget>[HomeAppBar(), Container()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    firestoreService.listenToAmountOwed((newAmount) {
      setState(() {
        _amountOwed = newAmount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: _pages[_selectedIndex],
      ),
      appBar: PreferredSize(
          preferredSize: _selectedIndex == 0
              ? const Size.fromHeight(120)
              : const Size.fromHeight(75),
          child: _selectedIndex == 0
              ? HomeAppBar()
              : AppBar(
                backgroundColor: Colors.white,
                  title: Padding(padding: EdgeInsets.only(top: 15), child: Text(
                    "Chat",
                    style: TextStyle(
                        fontFamily: 'Cormorant',
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),),
                )),
      floatingActionButton: _selectedIndex == 0
          ? HomeExtendedFAB(amountOwed: _amountOwed)
          : Container(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromRGBO(73, 189, 119, 1.0),
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: const Color.fromRGBO(255, 240, 205, 1.0),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.home_outlined, color: Colors.black),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
            selectedIcon: Icon(Icons.home_outlined, color: Colors.black),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  const InvoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.insert_drive_file, color: textColor),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}

enum PaymentType { send, receive }

class TransactionTile extends StatelessWidget {
  final String amount;
  final String type;
  final String note;
  final String timestamp;

  const TransactionTile(
      {super.key,
      required this.amount,
      required this.note,
      required this.type,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final Color color = type == "send"
        ? const Color.fromRGBO(168, 44, 44, 1.0)
        : const Color.fromRGBO(44, 168, 79, 1.0);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color.fromRGBO(255, 240, 205, 1.0),
        child: Icon(
          type == "send" ? Icons.receipt : Icons.payments_outlined,
          color: color,
        ),
      ),
      title: Text(
        type == "send" ? "INTEREST" : "PAYMENT",
        style: TextStyle(
          color: color,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(note),
        SizedBox(
          height: 10,
        ),
        Text(
          timestamp,
          style: TextStyle(fontSize: 12),
        )
      ]),
      trailing: Text(
        type == "send" ? "KES -$amount" : "KES +$amount",
        style: TextStyle(color: color, fontFamily: "Poppins", fontSize: 16),
      ),
    );
  }
}
