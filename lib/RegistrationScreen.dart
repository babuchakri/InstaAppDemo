import 'package:flutter/material.dart';
import 'package:login_form_one/LoginScreen.dart';
import 'BirthGenderScreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Back arrow icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen()
              ),
            ); // Navigate back when pressed
          },
        ),
        title: const Text('Registration',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
      ),


      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 220,

              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name Text

                    const SizedBox(height: 8.0),
                    // Box for First Name Input
                    Container(

                      ),
                    Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16.0),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          String name = _nameController.text;
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name is required'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BirthGenderScreen(name: name),
                              ),
                            );
                          }
                        },

                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adjust border radius
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text('Continue',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),),
                        ),
                      ),
                    ),

                ]),
              ),
            ),
          ),
        ),

    );

  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
