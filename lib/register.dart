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
  bool isLoading = false;
  bool obscurePassword = true;

  register() async {
    if (!key.currentState!.validate()) return;
    key.currentState!.save();
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your Account Added Successfully"))
      );
      Navigator.of(context).pushReplacementNamed("login");
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${err.toString()}"))
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join Us")),
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
                    icon: Icon(obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                  value!.length < 6 ? "Min 6 characters" : null,
                onSaved: (newValue) => password = newValue!,
              ),
              SizedBox(height: 50),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: register, child: Text("Register")),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed("login");
                },
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
