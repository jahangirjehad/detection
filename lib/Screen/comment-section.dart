import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommentSection extends StatefulWidget {
  final url;

  const CommentSection({Key? key, required this.url}) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      color: Colors.black,
      border: Border.all(width: 3.0),
      borderRadius: const BorderRadius.all(
          Radius.circular(5.0) //                 <--- border radius here
          ),
    );
  }

  final TextEditingController _commentController = TextEditingController();
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> postComment(String text) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        var currentUser = _auth.currentUser;
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        await _firestore
            .collection('posts')
            .doc(widget.url)
            .collection('comments')
            .doc()
            .set({
          'text': text,
          'name': currentUser!.email,
          'datePublished': DateTime.now(),
        });

        final DocumentReference documentRef =
            FirebaseFirestore.instance.collection('statuses').doc(widget.url);

        documentRef.update({'comments': FieldValue.increment(1)}).then((_) {
          print('Document updated successfully!');
        }).catchError((error) {
          print('Error updating document: $error');
        });
      } else {}
      res = "success";
    } catch (e) {
      res = e.toString();
    }
  }

  List filedata = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: const Text('Comment'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(widget.url)
              .collection('comments')
              .orderBy('datePublished', descending: true)
              .snapshots(),
          builder: (context, snapshot)
              //Cheap Trick--> Mention Type of dynamic qqueue
              {
            var data = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (_, index) {
                  DocumentSnapshot _documentSnapshot =
                      snapshot.data!.docs[index];
                  var text = _documentSnapshot['text'];
                  var name = _documentSnapshot['name'];
                  var date = _documentSnapshot['datePublished'].toDate();
                  String datetime = date.year.toString() +
                      "/" +
                      date.month.toString() +
                      "/" +
                      date.day.toString();
                  print(datetime);

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () async {
                              // Display the image in large form.
                              print("Comment Clicked");
                            },
                            child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: new BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: new BorderRadius.all(
                                      Radius.circular(50))),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                    "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=1024x1024&w=is&k=20&c=-mUWsTSENkugJ3qs5covpaj-bhYpxXY-v9RDpzsw504="),
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Text(text),
                          trailing: Text(datetime,
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black)),
                        ),
                      )
                    ],
                  );
                });
          }),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.grey,
          height: 50,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=1024x1024&w=is&k=20&c=-mUWsTSENkugJ3qs5covpaj-bhYpxXY-v9RDpzsw504="),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Comment',
                    border: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  await postComment(_commentController.text);
                  setState(() {
                    _commentController.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
