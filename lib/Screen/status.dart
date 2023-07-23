import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detection/Screen/comment-section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Status extends StatefulWidget {
  const Status({Key? key}) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _textEditingController = TextEditingController();
  File? _imageFile;
  var currentPage = 1;
  var totalPage = 4;
  var limit = 2;
  dynamic start, end;
  @override
  void initState() {
    super.initState();

    // Set the initial state of the widget here
    start = limit * currentPage - limit;
    end = start + limit;
  }

  Future<void> _uploadStatus() async {
    String? imageUrl;

    // Upload the image to Firebase Storage if available
    if (_imageFile != null) {
      final String imagePath = 'images/${DateTime.now().toString()}.png';
      final Reference storageRef = _storage.ref().child(imagePath);
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;

    // Add the status to Firestore
    await _firestore.collection('statuses').add({
      'postBy': user!.email,
      'text': _textEditingController.text,
      'image': imageUrl,
      'timestamp': DateTime.now(),
      'likes': 0,
      'comments': 0,
      "likeBy": [],
    });

    // Clear the input fields
    _textEditingController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Status Page',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('statuses')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          var h = MediaQuery.of(context).size.height;
          var w = MediaQuery.of(context).size.width;
          totalPage = documents.length;
          totalPage = (totalPage / limit).ceil();
          //print("len = ${documents.length}");

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FractionallySizedBox(
                          widthFactor:
                              0.8, // Adjust the fraction as needed (e.g., 0.8 for 80% of available width)
                          child: SizedBox(
                            height: 150, // Set the desired height
                            child: TextField(
                              controller: _textEditingController,
                              decoration: const InputDecoration(
                                hintText: 'What\'s on your mind?',
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: _selectImage,
                              icon: const Icon(Icons.image),
                            ),
                            ElevatedButton(
                              onPressed: _uploadStatus,
                              child: const Text('Post Status'),
                            ),
                          ],
                        ),
                        if (_imageFile != null)
                          SizedBox(
                            height: 200,
                            child: Image.file(
                              _imageFile!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              for (var index = start; index < end; index++)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: _buildStatusCard(documents[index]),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Add your function for previous button here
                        currentPage != 1
                            ? setState(() {
                                currentPage = currentPage - 1;
                                start = limit * currentPage - limit;
                                end = start + limit;
                              })
                            : setState(() {});
                      },
                      child: Text(
                        'Prev',
                        style: currentPage == 1
                            ? const TextStyle(color: Colors.grey)
                            : const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  for (int i = 1; i <= totalPage; i++)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Add your function for page 1 button here
                          setState(() {
                            currentPage = i;
                            start = limit * currentPage - limit;
                            end = start + limit;
                          });
                        },
                        child: Text(
                          '$i',
                          style: currentPage == i
                              ? const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)
                              : const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Add your function for next button here
                        currentPage != 4
                            ? setState(() {
                                currentPage = currentPage + 1;
                                start = limit * currentPage - limit;
                                end = start + limit;
                              })
                            : setState(() {});
                      },
                      child: Text(
                        'Next',
                        style: currentPage == 4
                            ? const TextStyle(color: Colors.grey)
                            : const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(QueryDocumentSnapshot document) {
    final status = document.data() as Map<String, dynamic>;
    final statusId = document.id;
    final likedBy = status['likeBy'] as List<dynamic>?;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;
    final isLiked = likedBy?.contains(user!.email) ?? false;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${status['postBy']}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd MMM, yyyy HH:mm')
                    .format(status['timestamp'].toDate()),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                status['text'],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Container(
            child:
                status['image'] != null ? Image.network(status['image']) : null,
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up),
                color: isLiked ? Colors.blue : Colors.grey,
                onPressed: () {
                  if (!isLiked) {
                    FirebaseFirestore.instance
                        .collection('statuses')
                        .doc(statusId)
                        .update({
                      'likes': FieldValue.increment(1),
                      'likeBy': FieldValue.arrayUnion([user!.email]),
                    });
                    print("if");
                  } else {
                    FirebaseFirestore.instance
                        .collection('statuses')
                        .doc(statusId)
                        .update({
                      'likes': FieldValue.increment(-1),
                      'likeBy': FieldValue.arrayRemove([user!.email]),
                    });
                    print("else");
                  }
                },
              ),
              Text(
                "${status['likes']} Likes  ",
                style: const TextStyle(color: Colors.grey),
              ),
              IconButton(
                icon: const Icon(Icons.comment_bank_outlined),
                color: Colors.grey,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentSection(url: statusId)));
                },
              ),
              status['comments'] == 0
                  ? const Text(
                      "0 Comments  ",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Text(
                      "${status['comments']} Comments",
                      style: const TextStyle(color: Colors.grey),
                    )
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
