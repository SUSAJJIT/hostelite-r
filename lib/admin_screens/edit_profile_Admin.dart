import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostelite/admin_screens/alerts_admin.dart';
import 'package:hostelite/admin_screens/exit-recordsAdmin.dart';
import 'package:hostelite/admin_screens/home_screen_Admin.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:hostelite/models/user_model.dart';

class EditProfileAdmin extends StatefulWidget {
  const EditProfileAdmin({Key key}) : super(key: key);

  @override
  _EditProfileAdminState createState() => _EditProfileAdminState();
}

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

firebase_storage.Reference ref = storage.ref().child('dps');

class _EditProfileAdminState extends State<EditProfileAdmin> {
  var imageUrl = 'str';
  File _pickedImage;
  var picsdb = FirebaseFirestore.instance
      .collection('displayPics')
      .doc(FirebaseAuth.instance.currentUser.uid);
  String ImgUrl = "";

  File img;
  getImage() async {
    ImagePicker _picker = ImagePicker();
    final XFile image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        img = File(image.path);
      });
    }
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController username = TextEditingController();
  final TextEditingController mobileNumber = TextEditingController();
  final TextEditingController email = TextEditingController();
  Future buildUpdateProfile() async {
    FirebaseFirestore.instance
        .collection("adminUsers")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      "username": username.text,
      "mobileNumber": mobileNumber.text,
      "emailAddress": email.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 50, 15, 15),
              child: Column(children: [
                Row(children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text('Edit Profile',
                      style: TextStyle(fontSize: 24, color: Color(0xff747475))),
                ]),
                SizedBox(
                  height: 35,
                ),
                GestureDetector(
                  onTap: () async {
                    firebase_storage.UploadTask uploadedImg = ref
                        .child(
                            DateTime.now().microsecondsSinceEpoch.toString() +
                                '.png')
                        .putFile(img);
                    await uploadedImg.whenComplete(() => null);

                    String url = "";

                    await ref.getDownloadURL().then((value) {
                      url = value;
                    });
                    db
                        .collection('dps')
                        .doc(_auth.currentUser.uid)
                        .set({"dpUrl": url});
                  },
                  child: Container(
                    child: GestureDetector(
                      onTap: () {
                        ImagePicker()
                            .pickImage(source: ImageSource.gallery)
                            .then((value) async {
                          _pickedImage = File(value.path);
                          Reference reference = FirebaseStorage.instance
                              .ref()
                              .child('images')
                              .child('dps')
                              .child(DateTime.now()
                                      .microsecondsSinceEpoch
                                      .toString() +
                                  '.jpg');
                          UploadTask task = reference.putFile(_pickedImage);
                          task.whenComplete(() {
                            reference.getDownloadURL().then((url) {
                              setState(() {
                                ImgUrl = url;
                              });
                              print(url);

                              picsdb.set({
                                'dpUrl': url,
                                'userUid': FirebaseAuth.instance.currentUser.uid
                              });
                            });
                          });
                        });
                      },
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('displayPics')
                              .where("userUid",
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String dataUrl = snapshot.data.docs[0]["dpUrl"];
                            return !snapshot.hasData
                                ? CircularProgressIndicator()
                                : CircleAvatar(
                                    radius: 85,
                                    backgroundColor: Colors.orange[100],
                                    backgroundImage: dataUrl != " "
                                        ? NetworkImage(dataUrl)
                                        : AssetImage('assets/nodppic.jfif'),
                                  );
                          }),
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    hintText: _auth.currentUser.displayName,
                    labelText: 'Name',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 1.0)),
                  ),
                ),
                SizedBox(
                  height: 28,
                ),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    hintText: _auth.currentUser.email,
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 1.0)),
                  ),
                ),
                SizedBox(
                  height: 28,
                ),
                TextFormField(
                  controller: mobileNumber,
                  decoration: InputDecoration(
                    hintText: _auth.currentUser.phoneNumber,
                    labelText: 'Mobile number',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 1.0)),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  width: 130,
                  height: 50,
                  child: MaterialButton(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      color: Colors.purple,
                      minWidth: 100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () async {
                        if (username.text.isEmpty ||
                            email.text.isEmpty ||
                            mobileNumber.text.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error updating profile"),
                                  content: Text("Please fill all fields"),
                                  actions: [
                                    TextButton(
                                      child: Text("Ok"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                          return;
                        }

                        buildUpdateProfile();
                        print("1.-------------------");
                        //code to update email in firebase auth

                        User firebaseUser = FirebaseAuth.instance.currentUser;
                        firebaseUser.updateDisplayName(username.text);
                        await firebaseUser.updateEmail(email.text);
                        print("2.-------------------");
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => HomeScreenAdmin()));
                      }),
                ),
              ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey[300],
          ),
        ),
        height: 45,
        width: 380,
        child: Row(
          children: <Widget>[
            Spacer(),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return HomeScreenAdmin();
                  }),
                );
              },
              child: Icon(
                Icons.home_filled,
              ),
            ),
            Spacer(),
            //SizedBox(width: 10),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ExitListAdmin();
                  }),
                );
              },
              child: Icon(
                Icons.graphic_eq,
              ),
            ),
            Spacer(),
            //SizedBox(width: 10),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Alerts();
                  }),
                );
              },
              child: Icon(
                Icons.add_alert,
              ),
            ),
            Spacer(),
            //SizedBox(width: 10),
            MaterialButton(
              onPressed: () {},
              child: Icon(
                Icons.person,
                color: Color(0xffF989E7),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
