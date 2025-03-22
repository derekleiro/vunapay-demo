import 'package:cloud_firestore/cloud_firestore.dart';

import '../home.dart';

class PaymentTransaction {
  final String note;
  final PaymentType type;
  final int amount;

  PaymentTransaction({
    required this.note,
    required this.type,
    required this.amount,
  });

  @override
  String toString() {
    return 'Payment(note: $note, type: $type, amount: $amount)';
  }
}

class FirestoreService {
  // Get collection of transactions
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE: Add a new transaction
  Future<void> addTransaction(Map<String, dynamic> transaction) {
    final CollectionReference transactions =
        _firestore.collection('transactions');

    return transactions.add({
      'transaction': transaction,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get transactions from database
  void getTransactionsStream(
      void Function(List<Map<String, dynamic>>) onUpdate) async {
    _firestore
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> transactions = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'timestamp': doc['timestamp'] ?? Timestamp.now(),
              'transaction': {
                'amount': doc['transaction']['amount'],
                'note': doc['transaction']['note'],
                'type': doc['transaction']['type'],
              }
            };
          }).toList();

          print("📩 New transactions received: ${transactions.length}");
          onUpdate(transactions); // Update UI with new transactions
        } else {
          print("📭 No messages yet in this chat.");
          onUpdate([]);
        }
      },
      onError: (error) {
        print("❌ Error listening to messages: $error");
      },
    );
    ;
  }

  // LISTEN: Amount Owed
  void listenToAmountOwed(void Function(int) onUpdate) {
    _firestore.collection('amountOwed').doc('root').snapshots().listen(
      (DocumentSnapshot doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final int amountOwed = (data['owed'] ?? 0) as int;

          print(
              "It is my (VunayPay) atmost pleasure to give you your owings!: $amountOwed");
          onUpdate(amountOwed);
        } else {
          print("Document does not exist.");
          onUpdate(0);

          // Testing purposes
          _firestore.collection('amountOwed').doc('root').set({'owed': 85000});
        }
      },
      onError: (error) {
        print("Error listening to amount owed: $error");
      },
    );
  }

  // LISTEN: Amount Owes
  void listenToAmountOwes(void Function(int) onUpdate) {
    _firestore.collection('owe').doc('root').snapshots().listen(
      (DocumentSnapshot doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          final int amountOwes = (data['owes'] ?? 0) as int;

          print(
              "Hear ye, hear ye, the honourable customer has incurred some interest! : $amountOwes");
          onUpdate(amountOwes); // Pass the updated value to a callback
        } else {
          print("Document does not exist.");
          onUpdate(0);
        }
      },
      onError: (error) {
        print("Error listening to amount owes: $error");
      },
    );
  }

  // UPDATE: Add interest
  Future<void> processPaymentRequest(int requestedAmount, int interest,
      void Function(bool, String) onProcessed) async {
    try {
      // Get the current values from Firestore
      DocumentSnapshot owedDoc =
          await _firestore.collection('amountOwed').doc('root').get();
      DocumentSnapshot owesDoc =
          await _firestore.collection('owe').doc('root').get();

      int currentOwed = (owedDoc.exists && owedDoc.data() != null)
          ? (owedDoc.data() as Map<String, dynamic>)['owed'] ?? 0
          : 0;

      int currentOwes = (owesDoc.exists && owesDoc.data() != null)
          ? (owesDoc.data() as Map<String, dynamic>)['owes'] ?? 0
          : 0;

      if (currentOwed == 0 || requestedAmount > currentOwed) {
        onProcessed(false, "You don't have enough in your account");
        return;
      }

      if (interest > requestedAmount) {
        onProcessed(
            false, "Something wen't wrong, we are working to fix this issue");
      }

      int newOwed =
          (currentOwed - requestedAmount).clamp(0, double.infinity).toInt();
      int newOwes = currentOwes + interest;

      // Update Firestore in a batch (ensures atomic updates)
      WriteBatch batch = _firestore.batch();

      batch.update(
          _firestore.collection('amountOwed').doc('root'), {'owed': newOwed});
      batch.update(_firestore.collection('owe').doc('root'), {'owes': newOwes});

      await batch.commit();

      print("Transaction successful!");
      onProcessed(true, "Transaction successful");
    } catch (e) {
      print("Error processing request: $e");
    }
  }

  // CREATE: A new chat message
  Future<void> newChatMessage(String message) async {
    await _firestore
        .collection("chats")
        .doc("1") // Chat ID
        .collection("messages")
        .add({
      "text": message,
      "sender": "user",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // LISTEN: To chat messages in a chat room
  void listenToChat(
      String chatId, void Function(List<Map<String, dynamic>>) onUpdate) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp',
            descending: false) // Ensure messages are ordered correctly
        .snapshots()
        .listen(
      (QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> messages = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'text': doc['text'] ?? '',
              'sender': doc['sender'] ?? 'unknown',
              'timestamp': doc['timestamp'] ?? Timestamp.now(),
            };
          }).toList();

          print("📩 New messages received: ${messages.length}");
          onUpdate(messages); // Update UI with new messages
        } else {
          print("📭 No messages yet in this chat.");
          onUpdate([]);
        }
      },
      onError: (error) {
        print("❌ Error listening to messages: $error");
      },
    );
  }
}
