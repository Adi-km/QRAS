// success.dart
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';



class SuccessPage extends StatelessWidget {
  final bool attendanceMarked;

  const SuccessPage({required this.attendanceMarked, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Lottie.asset(
              attendanceMarked? 'assets/images/tick.json':'assets/images/notick.json',
              repeat: false,
              width: MediaQuery.of(context).size.width/1.5,
              height: MediaQuery.of(context).size.width/1.5,

            ),
            Text(
              attendanceMarked ? 'Attendance Marked' : 'Error in Marking Attendance',
              style:
              TextStyle(fontSize: 25, color: Colors.grey[900]),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Homepage(),
                    ),
                  );
                },
                
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple[900]!),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  elevation: MaterialStateProperty.all<double>(5),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder> (
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  )
                ),
                child: const Text("RETURN", style: TextStyle(letterSpacing: 2, fontSize: 20),),
              ),
            ),
          ],
        ),
      ),

    );
  }
}