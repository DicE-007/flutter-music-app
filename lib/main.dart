import 'package:flutter/material.dart';
import 'package:runomusic/pages/getStarted.dart';
import 'package:runomusic/pages/loading.dart';
import './pages/home_page.dart';
import './constants/constants.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/" :(context)=>Loading() ,
          GetStarted.path:(context)=>GetStarted(),
          Home_Page.path:(context) => Home_Page(),
        },
        theme: ThemeData(
          fontFamily: "Rubik",
          scaffoldBackgroundColor: Colors.black,
          primaryColor: widgetColor,
          textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: 22,color: Colors.white),
              bodyMedium: TextStyle(fontSize: 18,color: Colors.white),
            bodySmall: TextStyle(fontSize: 15,color: Colors.grey),
          )
        ),

    );
  }
}


