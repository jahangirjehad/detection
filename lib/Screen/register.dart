import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:detection/Screen/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var authcrd = null;
  String username = '';
  bool isUsernameUnique = true;
  File? _image;
  final imgPicker = ImagePicker();

  UploadTask? task;
  File? file;
  var imgDownload;

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
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
      uploadFile();
    } catch (err) {
      print("exception");
      print(err);
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
  }

  Future<void> checkUsernameUniqueness(String username) async {
    //print(username);
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    setState(() {
      isUsernameUnique = snapshot.docs.isEmpty;
    });
  }

  String? selectedDivision;
  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    final divisions = ['Dhaka', 'Chittagong', 'Khulna', 'Rajshahi', 'Barisal'];
    List<String> districts = [];

    if (selectedDivision == null)
      districts.add('');
    else if (selectedDivision == 'Dhaka') {
      districts.addAll(['Gazipur', 'Narayanganj', 'Dhaka', 'Sylhet']);
    } else if (selectedDivision == 'Chittagong') {
      districts.addAll(['Chattogram', 'Coxs Bazar', 'Cumilla']);
    } else if (selectedDivision == 'Khulna') {
      districts.addAll(['Khulna', 'Jessore', 'Bagerhat']);
    } else if (selectedDivision == 'Rajshahi') {
      districts.addAll(['Rajshahi', 'Pabna', 'Natore']);
    } else if (selectedDivision == 'Barisal') {
      districts.addAll(['Barisal', 'Patuakhali', 'Bhola']);
    }

    return Container(
      /*decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/register.png'), fit: BoxFit.cover),
      ),*/
      child: Scaffold(
        appBar: AppBar(
          //backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.white10,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.blueGrey,
            padding: EdgeInsets.only(
                right: 35,
                left: 35,
                top: MediaQuery.of(context).size.height * 0.27),
            child: Container(
              color: Colors.blueGrey,
              child: Center(
                child: Column(children: [
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      hintText: 'User Name',
                      hintStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                      checkUsernameUniqueness(value);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (username == "")
                    const Text(
                      'enter an unique user name',
                      style: TextStyle(color: Colors.white),
                    )
                  else if (isUsernameUnique)
                    const Text(
                      'Username is unique!',
                      style: TextStyle(color: Colors.green),
                    )
                  else
                    const Text(
                      'Username is already taken!',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    //width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DateTimePicker(
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      initialValue: '',
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: const Icon(
                        Icons.event,
                        size: 40,
                        color: Colors.white,
                      ),
                      dateLabelText: 'BirthDate',
                      onChanged: (val) => {},
                      validator: (val) {
                        return null;
                      },
                      onSaved: (val) => {},
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    //width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.location_city,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          hint: const Text(
                            'Select a division',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          value: selectedDivision,
                          items: divisions.map((division) {
                            return DropdownMenuItem(
                              value: division,
                              child: Text(division),
                            );
                          }).toList(),
                          onChanged: (division) {
                            setState(() {
                              selectedDivision = division;
                              selectedDistrict = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  selectedDivision != null
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                                hint: const Text('Select district'),
                                value: selectedDistrict,
                                items: districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  );
                                }).toList(),
                                onChanged: (district) {
                                  setState(() {
                                    selectedDistrict = district;
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    controller: _emailController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white),
                      prefixIcon: const Icon(
                        Icons.password_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image != null ? Image.file(_image!) : Container(),
                      Text(imgDownload ?? ''),
                      ElevatedButton(
                        onPressed: selectFile,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(12.0)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8.0),
                            _image != null
                                ? const Text('Uploaded',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white))
                                : const Text('Upload Profile Picture',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xff4c505b),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () async {
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text);
                                await userCredential.user
                                    ?.sendEmailVerification();
                                var authCredential = userCredential.user;
                                print(authCredential!.uid);
                                final FirebaseFirestore _firestore =
                                    FirebaseFirestore.instance;

                                await _firestore
                                    .collection('users')
                                    .doc(_emailController.text)
                                    .set({
                                  'username': username,
                                  'email': _emailController.text,
                                  'image': imgDownload,
                                });
                                authcrd = authCredential.uid;

                                if (authCredential.uid.isNotEmpty) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const Login()));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Something is wrong");
                                }
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  Fluttertoast.showToast(
                                      msg:
                                          "The password provided is too weak.");
                                } else if (e.code == 'email-already-in-use') {
                                  Fluttertoast.showToast(
                                      msg:
                                          "The account already exists for that email.");
                                }
                              } catch (e) {
                                print(e);
                              }
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ]),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'login');
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
