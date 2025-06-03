import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = "";
  String password = "";
  var key = GlobalKey<FormState>();

  register(){
    key.currentState!.save();
    
    FirebaseAuth.
    instance.
    createUserWithEmailAndPassword(email: email, password: password)
    .then((data){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your Account Added Successfully"))
      );
      Navigator.of(context).pushNamed("login");
    })
    .catchError((err){
      // print("Sorry Something went Wrong ${err}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sorry Something went Wrong ${err} "))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Us"),
      ),
      body: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: ListView(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  setState(() {
                    email = newValue!;
                  });
                },
              ),
              TextFormField(
                obscureText: true,
                onSaved: (newValue) {
                  setState(() {
                    password = newValue!;
                  });
                },
              ),
              SizedBox(height: 50,),
              ElevatedButton(onPressed: register, child: Text("Register")),
              SizedBox(height: 20,),
              TextButton(onPressed: (){
                Navigator.of(context).popAndPushNamed("login");
              }, child: Text("Login"))
            ],
          ),
        ),
      ),
    );
  }
}