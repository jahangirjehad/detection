import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Pagination extends StatefulWidget {
  const Pagination({Key? key}) : super(key: key);

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  TextEditingController name = TextEditingController();
  File? _image;
  File? file;
  UploadTask? task;
  var imgDownload;
  final int pageSize = 3;
  List<DocumentSnapshot> documents = [];
  int currentPage = 1;
  DocumentSnapshot<Object?>? firstDocument;
  DocumentSnapshot<Object?>? lastDocument;
  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    QuerySnapshot querySnapshot;

    if (lastDocument == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('email')
          .limit(pageSize)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('email')
          .startAfterDocument(lastDocument!)
          .limit(pageSize)
          .get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        if (lastDocument == null) {
          documents = querySnapshot.docs;
          firstDocument = querySnapshot.docs.first;
        } else {
          documents.addAll(querySnapshot.docs);
        }
        lastDocument = querySnapshot.docs.last;
      });
    }
  }

  Future<void> fetchPreviousPage() async {
    if (firstDocument != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('email')
          .endBeforeDocument(firstDocument!)
          .limitToLast(pageSize)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          documents = querySnapshot.docs;
          firstDocument = querySnapshot.docs.first;
          lastDocument = querySnapshot.docs.last;
        });
      }
    }
  }

  Future<void> goToPreviousPage() async {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        documents.clear();
      });
      fetchPreviousPage();
    }
  }

  Future<void> goToNextPage() async {
    setState(() {
      currentPage++;
      documents.clear();
    });
    fetchDocuments();
  }

  Future selectFile() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.getImage(source: ImageSource.gallery);
      final pickedImageFile = File(pickedImage!.path);
      setState(() {
        _image = pickedImageFile;
        file = pickedImageFile;
      });
      print("complete select image ");
      print(file);
    } catch (err) {
      print("exception");
      print(err);
    }
  }

  static UploadTask? uploadingFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  Future uploadFile() async {
    if (_image == null) return;

    final fileName = basename(_image!.path);
    final destination = 'files//$fileName';
    print("file = " + fileName);
    //file = fileName as File?;

    task = uploadingFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    imgDownload = await snapshot.ref.getDownloadURL();
    //imgDownload = urlDownload;

    print('Download-Link: $imgDownload');
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection("products");
    var email = currentUser?.email;
    print(currentUser?.email);
    print(_collectionRef);
    _collectionRef
        .doc()
        .set({
          "email": name.text,
          "img": imgDownload,
        })
        .whenComplete(() => print("complete"))
        .catchError((error) => print("somethimg is wrong. $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('helmet Detection App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final document = documents[index];
                print(document);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(document['img']),
                  ),
                  title: Text(document['email']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (firstDocument != null)
            FloatingActionButton(
              onPressed: fetchPreviousPage,
              child: Icon(Icons.arrow_back),
            ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: fetchDocuments,
            child: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
