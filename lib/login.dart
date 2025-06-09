import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  var key = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;

  login() async {
    if (!key.currentState!.validate()) return;
    key.currentState!.save();
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in Successfully")),
      );
      Navigator.of(context).pushReplacementNamed("home");
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${err.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome Back"),
      ),
      body: Form(
        key: key,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Email is required" : null,
                onSaved: (newValue) => email = newValue!,
              ),
              TextFormField(
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Password is required" : null,
                onSaved: (newValue) => password = newValue!,
              ),
              SizedBox(height: 50),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: login,
                      child: Text("Login"),
                    ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("register");
                },
                child: Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
