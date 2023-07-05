import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  var _rating;
  late double avgerageRate;
  bool isLoading = true;
  void initState() {
    super.initState();
    avgRate();
  }

  avgRate() {
    FirebaseFirestore.instance
        .collection('ratings')
        .get()
        .then((querySnapshot) {
      double total = 0;
      int count = 0;
      querySnapshot.docs.forEach((doc) {
        total += (doc.data()['rating'] as double);
        count++;
      });
      var AvgerageRate = total / count;
      setState(() {
        avgerageRate = AvgerageRate;
        isLoading = false;
      });
      print(avgerageRate);
    });
  }

  Future<void> postRating(double rating) async {
    String res = "Some error occured";
    try {
      if (rating >= 0) {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        var currentUser = _auth.currentUser;
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;

        await _firestore.collection('ratings').doc(currentUser?.email).set({
          'rating': rating,
          'name': currentUser!.email,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Empty Text');
      }
      res = "success";
    } catch (e) {
      res = e.toString();
      print(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Helmet Detection App"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  const Text(
                    "Please Rate Our App",
                    style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    'Total Rating: $avgerageRate ',
                    style: const TextStyle(fontSize: 25),
                  ),
                  if (_rating == null)
                    const Text(
                      'Your Rating: 0 ',
                      style: TextStyle(fontSize: 25),
                    )
                  else
                    Text(
                      'Your Rating: $_rating ',
                      style: const TextStyle(fontSize: 25),
                    ),
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                      postRating(rating);
                      print(_rating);
                    },
                  ),
                  TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered))
                              return Colors.blue.withOpacity(0.04);
                            if (states.contains(MaterialState.focused) ||
                                states.contains(MaterialState.pressed))
                              return Colors.blue.withOpacity(0.12);
                            return null; // Defer to the widget's default.
                          },
                        ),
                      ),
                      onPressed: () {
                        avgRate();
                      },
                      child: const Text(
                        'Submit Rate',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              ),
      ),
    );
  }
}
