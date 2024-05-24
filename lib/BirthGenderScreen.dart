import 'package:flutter/material.dart';
import 'EmailPasswordScreen.dart';

class BirthGenderScreen extends StatefulWidget {
  final String name;

  const BirthGenderScreen({super.key, required this.name});

  @override
  State<BirthGenderScreen> createState() => _BirthGenderScreenState();
}

class _BirthGenderScreenState extends State<BirthGenderScreen> {
  String selectedGender = '';
  String selectedDate = '';
  final TextEditingController _birthDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use leading property to add the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registration',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 310,
            child: Container(

              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked.toString().split(' ')[0];
                            _birthDateController.text = selectedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Gender',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          DropdownButton<String>(
                            value: selectedGender.isEmpty ? null : selectedGender,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onChanged: (String? value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () {
                        String birth = _birthDateController.text;
                        if (birth.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Date of birth is required'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (selectedGender.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select gender'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailPasswordScreen(
                                name: widget.name,
                                birth: birth,
                                gender: selectedGender,
                              ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: const Text('Continue',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),),
                      ),
                    ),
                )],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
