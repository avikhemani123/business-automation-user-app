import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/assistantMethods/cart_Item_counter.dart';
import 'assistantMethods/address_changer.dart';
import 'assistantMethods/total_amount.dart';
import 'global/global.dart';
import 'splashScreen/splash_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  Stripe.publishableKey = 'pk_test_51NIuMUAHYybf6aLdfjpjA5NYbAyrQjnmGZ3xaMU0N8OjCKazj9ky0Nqcfmlu3zMNW0jmb1woXO3q2RajOHwPYC0H00BAlrqmRx';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}



class MyApp extends StatelessWidget
{


  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c)=> CartItemCounter()),
        ChangeNotifierProvider(create: (c)=> TotalAmount()),
        ChangeNotifierProvider(create: (c)=> AddressChanger()),
      ],
      child: MaterialApp(
        title: 'Riders App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MySplashScreen(),
      ),
    );
  }
}


