import 'package:detection/Screen/comment-section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final int _itemsPerPage = 5;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _items = [];
  int _currentPage = 1;
  int _totalPages = 0;
  int t = 0;

  Future<void> _loadData(bool nextPage) async {
    CollectionReference itemsRef =
        FirebaseFirestore.instance.collection("detection");
    QuerySnapshot q = await itemsRef.get();
    t = q.size;

    Query query = itemsRef.orderBy('date').limit(_itemsPerPage);

    if (!nextPage && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      if (!nextPage) {
        _items.clear();
        _currentPage = 1;
      } else {
        _currentPage++;
      }

      _items.addAll(querySnapshot.docs);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadData(true);
    _countTotalPages();
  }

  void _countTotalPages() {
    _totalPages = (t / _itemsPerPage).ceil();
    print("total = $_totalPages");
  }

  @override
  Widget build(BuildContext context) {
    final List<int> pageNumbers =
        List.generate(_totalPages, (index) => index + 1);

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("detection")
                            .snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          var data = snapshot.data;
                          if (data == null) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final FirebaseAuth _auth = FirebaseAuth.instance;
                              var user = _auth.currentUser;
                              print((user?.email));
                              DocumentSnapshot _documentSnapshot =
                                  snapshot.data!.docs[index];
                              var email = _documentSnapshot['email'];
                              var date = _documentSnapshot['date'].toDate();
                              var detection_label = _documentSnapshot['label'];
                              var like = _documentSnapshot['like'];
                              var url = _documentSnapshot['img'];
                              var id = _documentSnapshot.id;
                              final likedBy =
                                  _documentSnapshot['likeBy'] as List<dynamic>?;
                              final isLiked =
                                  likedBy?.contains(user!.email) ?? false;
                              print(isLiked);
                              print(likedBy);
                              String datetime = date.year.toString() +
                                  "/" +
                                  date.month.toString() +
                                  "/" +
                                  date.day.toString();

                              return Card(
                                margin: EdgeInsets.only(bottom: 30),
                                color: Colors.black,
                                elevation: 10,
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .55,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(url),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 7),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          height: 40,
                                          child: Text(
                                            "Date: ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          height: 30,
                                          child: Text(
                                            "$datetime",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 7),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          height: 40,
                                          child: Text(
                                            "Email: ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          height: 30,
                                          child: Text(
                                            "$email",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 7),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          height: 40,
                                          child: Text(
                                            "Detection Result: ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          height: 30,
                                          child: Text(
                                            "$detection_label",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.favorite),
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.white,
                                          onPressed: () {
                                            if (!isLiked) {
                                              FirebaseFirestore.instance
                                                  .collection('detection')
                                                  .doc(id)
                                                  .update({
                                                'like': FieldValue.increment(1),
                                                'likeBy': FieldValue.arrayUnion(
                                                    [user!.email]),
                                              });
                                              print("if");
                                            } else {
                                              FirebaseFirestore.instance
                                                  .collection('detection')
                                                  .doc(id)
                                                  .update({
                                                'like':
                                                    FieldValue.increment(-1),
                                                'likeBy':
                                                    FieldValue.arrayRemove(
                                                        [user!.email]),
                                              });
                                              print("else");
                                            }
                                          },
                                        ),
                                        Text(
                                          "${like} likes",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.comment),
                                          color: Colors.white,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentSection(
                                                            url: id)));
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () {
                              _loadData(false);
                            }
                          : null,
                    ),
                    SizedBox(width: 16),
                    for (int pageNumber = 1;
                        pageNumber <= _totalPages;
                        pageNumber++)
                      IconButton(
                        icon: Text('Page $pageNumber'),
                        onPressed: () {
                          _loadDataByPage(pageNumber);
                        },
                      ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _items.length == _itemsPerPage
                          ? () {
                              _loadData(true);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadDataByPage(int pageNumber) {
    _currentPage = pageNumber;
    _loadData(true);
  }
}
