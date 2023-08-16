import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/assistantMethods/assistant_methods.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/mainScreens/feedback_screen.dart';
import 'package:user_app/mainScreens/payment_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import '../widgets/custom_text_field.dart';

class PlacedOrderScreen extends StatefulWidget
{
  String? addressID;
  double? totalAmount;
  String? sellerUID;

  PlacedOrderScreen({this.sellerUID, this.totalAmount, this.addressID});

  @override
  _PlacedOrderScreenState createState() => _PlacedOrderScreenState();
}

class _PlacedOrderScreenState extends State<PlacedOrderScreen>
{
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  TextEditingController titleController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  ValueNotifier<bool> isButtonActive = ValueNotifier<bool>(false);
  Map<String, dynamic>? paymentIntentData;
  String? paymentStatus;
  String? accountTitle;
  String? accountNumber;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isButtonActive.addListener(() {
      setState(() {

      });
    });
  }
  addOrderDetails()
  {
    writeOrderDetailsForUser({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": paymentStatus,
      "orderTime": orderId,
      "isSuccess": true,
      "accountTitle":accountTitle,
      "accountNumber":accountNumber,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    });

    writeOrderDetailsForSeller({
      "addressID": widget.addressID,
      "totalAmount": widget.totalAmount,
      "orderBy": sharedPreferences!.getString("uid"),
      "productIDs": sharedPreferences!.getStringList("userCart"),
      "paymentDetails": paymentStatus,
      "orderTime": orderId,
      "isSuccess": true,
      "accountTitle":accountTitle,
      "accountNumber":accountNumber,
      "sellerUID": widget.sellerUID,
      "riderUID": "",
      "status": "normal",
      "orderId": orderId,
    }).whenComplete((){
      clearCartNow(context);
      setState(() {
        orderId="";
        accountNumber = null;
        accountTitle  = null;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()));
        //Fluttertoast.showToast(msg: "Congratulations, Order has been placed successfully.");
      });
    });
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sharedPreferences!.getString("uid"))
        .collection("orders")
        .doc(orderId)
        .set(data);
  }

  Future writeOrderDetailsForSeller(Map<String, dynamic> data) async
  {
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderId)
        .set(data);
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("orderID", orderId);
  }
  void showFullDialogue()
  {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 10,
              height: MediaQuery.of(context).size.height -  80,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),

                  )
                ],
              ),
            ),
          );
        });
  }
 void Cash()
 {
   showDialog(
       context: context,
       builder: (BuildContext context) {
         return Dialog(
           shape: RoundedRectangleBorder(
               borderRadius:
               BorderRadius.circular(20.0)), //this right here
           child: Container(
             height: 350,
             child: Padding(
               padding: const EdgeInsets.all(12.0),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
               Container(
               margin: const EdgeInsets.symmetric(horizontal: 40.0),
                 child:  Text("Payment Details", textAlign: TextAlign.center, style: TextStyle(color: Colors.black,fontSize: 25.0,),),
               ),
               CustomTextField(
                     data: Icons.person,
                     controller: titleController,
                     hintText: "Enter Your Name",
                     isObsecre: false,
                   ),
                   CustomTextField(
                     data: Icons.numbers,
                     controller: numberController,
                     hintText: "Enter Phone Number",
                     isObsecre: false,
                   ),
                   SizedBox(
                     width: 320.0,
                     child: ElevatedButton(
                       onPressed: () {
                         accountTitle = titleController.text.trim();
                         accountNumber = numberController.text.trim();
                         isButtonActive.value = true;
                         Navigator.pop(context);
                       },
                       child: Text(
                         "Save",
                         style: TextStyle(color: Colors.white),
                       ),
                     ),
                   )
                 ],
               ),
             ),
           ),
         );
       });
 }
  void ShowDialog()
  {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      child:  Text("Payment Details", textAlign: TextAlign.center, style: TextStyle(color: Colors.black,fontSize: 25.0,),),
                    ),
                    CustomTextField(
                      data: Icons.person,
                      controller: titleController,
                      hintText: "Enter Account Title",
                      isObsecre: false,
                    ),
                    CustomTextField(
                      data: Icons.numbers,
                      controller: numberController,
                      hintText: "Enter Account Number",
                      isObsecre: false,
                    ),
                    SizedBox(
                      width: 320.0,
                      child: ElevatedButton(
                        onPressed: () {
                          accountTitle = titleController.text.trim();
                          accountNumber = numberController.text.trim();
                          isButtonActive.value = true;
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
  @override
  Widget build(BuildContext context)
  {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.amber,
              ],
              begin:  FractionalOffset(0.0, 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Payment Method :", textAlign: TextAlign.left, style: TextStyle(color: Colors.white,fontSize: 35.0,),),

          Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Image.asset('images/img_bank.png'),
              iconSize: 80,
              //onPressed: () {
                //ShowDialogue();
                //Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
              //  onTap:
                onPressed: () async {
                  paymentStatus = "Payment By Card";
                  // final paymentMethod = await Stripe.instance.createPaymentMethod(
                  //     params: const PaymentMethodParams.card(
                  //         paymentMethodData: PaymentMethodData()));
                  await makePayment();
                },

            ),
            IconButton(
              icon: Image.asset('images/img_jazz.png'),
              iconSize: 80,
              onPressed: () {
                paymentStatus = "Payment By Jazz Cash";
                ShowDialog();
              },
            ),
            IconButton(
              icon: Image.asset('images/img_easypaisa.png'),
              iconSize: 80,
              onPressed: () {
                paymentStatus = "Payment By Easy Paisa";
                ShowDialog();
              },
            ),

          ],
        ),
            IconButton(
              icon: Image.asset('images/img_money.png'),
              iconSize: 80,
              onPressed: () {
                paymentStatus = "Payment By Cash";
                Cash();
              },
            ),
            Image.asset("images/delivery.png",height: 150,
              width: 150,),
            ElevatedButton(
              child: const Text("Place Order", style: TextStyle(color: Colors.white,fontSize: 20.0,),),
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
              ),
              onPressed: isButtonActive.value
                ?(){
                addOrderDetails();
              }
              :null,
            ),
        ],
      ),
      ),
    );
  }


  Future<void> makePayment() async {
    try {
      paymentIntentData =
      await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              setupIntentClientSecret: 'Your Secret Key',
              paymentIntentClientSecret:
              paymentIntentData!['client_secret'],
              //applePay: PaymentSheetApplePay.,
              //googlePay: true,
              //testEnv: true,
              customFlow: true,
              style: ThemeMode.dark,
              // merchantCountryCode: 'US',
              merchantDisplayName: 'Khemani'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
        //       parameters: PresentPaymentSheetParameters(
        // clientSecret: paymentIntentData!['client_secret'],
        // confirmPayment: true,
        // )
      )
          .then((newValue) {
        Stripe.instance.confirmPaymentSheetPayment();
        print('payment intent' + paymentIntentData!['id'].toString());
        print('payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        accountTitle = sharedPreferences!.getString("name");
        accountNumber = paymentIntentData!['id'].toString();
        paymentIntentData = null;
        isButtonActive.value = true;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ' + 'sk_test_51NIuMUAHYybf6aLdquLcsp8txHyuz0GjcZjQZQfLlyoPGzmypV2iH3XZUC7ieOMO8iTojUlr7hB6K75CofTJu2Ui00kJK3JNav',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}
