import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fan_page_app/model/message_model.dart';
import 'package:fan_page_app/model/user_model.dart';
import 'package:fan_page_app/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? user = FirebaseAuth.instance.currentUser;
  var currentUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      currentUser = UserModel.fromMap(value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("messages")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    return Expanded(
                      child: _buildList(snapshot.requireData),
                    );
                  },
                ),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (currentUser.role == Role.admin.name)
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add a new message',
                    onPressed: () {
                      _showPostMessageDialog();
                    },
                  ),
                ActionChip(
                  label: const Text("Logout"),
                  onPressed: () => {
                    _showConfirmLogoutDialog(),
                  },
                ),
              ]),
        ),
      ),
    );
  }

  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.docs[index];
        return ListTile(
          title: Text(
            doc["message"],
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Future<void> _showPostMessageDialog() async {
    final TextEditingController _textFieldController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Post a message"),
          content: TextField(
            controller: _textFieldController,
            decoration:
                const InputDecoration(hintText: "Enter your message here"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Post"),
              onPressed: () {
                _publishFirestoreDetails(_textFieldController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _publishFirestoreDetails(final String message) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    MessageModel messageModel = MessageModel(
      mid: const Uuid().v1(),
      message: message,
    );

    await firestore
        .collection("messages")
        .doc(messageModel.mid)
        .set(messageModel.toMap());

    Fluttertoast.showToast(msg: "Message posted successfully!");
  }

  Future<void> _showConfirmLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text("Are you sure you want to logout?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
