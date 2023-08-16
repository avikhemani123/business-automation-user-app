import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';


class  FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}



class _FeedbackScreenState extends State<FeedbackScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  double? _ratingValue;

  Future writeOrderDetailsForSeller() async
  {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(sharedPreferences!.getString("orderID"))
        .update({
      "Feed back": feedbackController.text.trim(),
      "Rating": _ratingValue.toString(),});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khemani Iron & Cement Store',
      home: Scaffold(

        appBar: AppBar(
          title: Text('Khemani Iron & Cement Store'),
          backgroundColor: Colors.green,
        ),
        backgroundColor: Colors.lightGreen,
        body: Center(
          child:Column(
            children: [
              CustomTextField(
            data: Icons.email,
            controller: feedbackController,
            hintText: "Please write your Feedback",
            isObsecre: false,
          ),
              ElevatedButton(
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),

              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
              ),
              onPressed: ()
                {
                  user = auth.currentUser;
                  writeOrderDetailsForSeller();
                  Fluttertoast.showToast(
                    msg: "Thankyou for your valuable feedback!!!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 20.0,

                  );
                  Navigator.pop(context);
                  //send user to homePage
                  Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
                  Navigator.pushReplacement(context, newRoute);
                }
              ),
              const SizedBox(height: 25),
              // implement the rating bar
              RatingBar(
                  initialRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.blue),
                      half: const Icon(
                        Icons.star_half,
                        color: Colors.black,
                      ),
                      empty: const Icon(
                        Icons.star_outline,
                        color: Colors.black,
                      )),
                  onRatingUpdate: (value) {
                    setState(() {
                      _ratingValue = value;
                    });
                  }),
              const SizedBox(height: 70),
              // Display the rate in number
              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                    color: Colors.cyan, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  _ratingValue != null ? _ratingValue.toString() : 'Rate Your Visit',
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                ),
              )
            ],
        ),
      ),
    ),
    );
  }
}
