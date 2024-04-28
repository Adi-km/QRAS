import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'qr_page.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });

      if (_user != null && !_user!.email!.endsWith("students.iitmandi.ac.in")) {
        _signOut(); // Log out the user
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body:Stack(
    children:[
      Column(
        children: [Stack(

        children:[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.6,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
            Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.6,
            decoration: BoxDecoration(
            color: Colors.deepPurple[900],
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(MediaQuery.of(context).size.width) / 6),
            ),
            ),
            ]
        ),Stack(

            children:[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.7,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[900],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(MediaQuery.of(context).size.width) / 6),
                ),
              ),

            ]


        ),


  ]
    ),_user != null ? _userDetails() : _signinButton(),]
      ),
    );
  }
  Widget _signinButton() {
    return Center(
        child:
            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [

              Image.asset('assets/images/logo_dark.png',
              height: MediaQuery.of(context).size.height/1.5,
              scale: 1),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                          onPressed: _handleLoginIn,
                          style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple[900]!), // Background color
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                elevation: MaterialStateProperty.all<double>(5), // Elevation (shadow)

                          ),
                          child: const Text(
                'SIGN IN',
                style: TextStyle(fontSize: 20, letterSpacing: 2),
                          ),
                        ),
              ),
            ),
      ]
        )


    );
  }

  Widget _userDetails() {
    return Container(

      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height/3.9),
          CircleAvatar(
            radius: MediaQuery.of(context).size.width/3.5,
            backgroundImage: NetworkImage(_user?.photoURL ?? ""),
          ),
          const SizedBox(height:20),
          Text(
              _user!.email!.split('@').first.toUpperCase(),
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height/3.9),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(


                onPressed: (){
                  // Navigate to QR page and pass the roll number
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => QRPage(rollNo: _user!.email!.split('@').first),
                  ));
                },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple[900]!), // Background color
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                elevation: MaterialStateProperty.all<double>(5), // Elevation (shadow)

              ),
                child: const Text("SCAN QR", style: TextStyle(letterSpacing: 2, fontSize: 20),),

            ),
          )


        ],
      )
    );
  }

  void _handleLoginIn(){
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(googleAuthProvider);
    }
    catch (error){
      debugPrint("$error");
    }
  }

  void _signOut() async {
    await _auth.signOut();
  }

}
